/*
 * Pistorm'X for Xilinx CPLD, with integrated buffers and without 200MHz clock
 * Amiga 500 DIP flavour, that can cohabit with the host original 68000 and can switch which one is activated by maintaining reset during at least 6 seconds
 * 2022 FLACO CC-BY-NC-SA
 * Inspired by original Pistorm, Copyright 2020 Claude Schwarz and Niklas Ekström, https://github.com/captain-amygdala/pistorm
 */

`define RAM_AUTOCONFIG 1
//`define RAM_NONE 1

module clkdiv(
	input clk_in,
	output clk_out,
	input _rst_in
	);
	(* PWR_MODE = "LOW" *) reg b = 0;
	assign clk_out = b;
	always @(negedge clk_in, posedge _rst_in)
		if(_rst_in)
			b <= 1'b0;
		else
			b <= !b;
endmodule

module pistormx500(
	output          PI_TXN_IN_PROGRESS, // GPIO0 //AUX0
	(* PWR_MODE = "LOW" *) output          PI_IPL_ZERO,        // GPIO1 //AUX1
	input   [1:0]   PI_A,       // GPIO[3..2]
//	input           PI_CLK,     // GPIO4 // Not used
	(* PWR_MODE = "LOW" *) output          PI_RESET_n, // GPIO5
	input           PI_RD,      // GPIO6
	input           PI_WR,      // GPIO7
	inout   [15:0]  PI_D,       // GPIO[23..8]

	inout   [23:1]	 M68K_A,
	inout   [15:0]	 M68K_D,
	input           M68K_CLK,
//	output  [2:0]   M68K_FC,   // PU on Amiga MB // Not used

	inout           M68K_AS_n,  // PU on Amiga MB
	inout           M68K_UDS_n, // PU on Amiga MB
	output          M68K_LDS_n, // PU on Amiga MB
	inout           M68K_RW,    // PU on Amiga MB

	inout           M68K_DTACK_n,
//	input           M68K_BERR_n, // Not used

	input           M68K_VPA_n,
	(* PWR_MODE = "LOW" *) inout           M68K_E,     // the host original 68k, if present, will generate this E clock. No PU on Amiga MB : need PU on expansion to detect if we need to generate this clock
	(* PWR_MODE = "LOW" *) output          M68K_VMA_n, // PU on Amiga MB

	input   [2:0]   M68K_IPL_n,

	(* PWR_MODE = "LOW" *) inout           M68K_RESET_n, // PU on Amiga MB
	(* PWR_MODE = "LOW" *) inout           M68K_HALT_n, // PU on Amiga MB

// These are dealing with the host original 68k, so their directions are those of a device, not a CPU
	(* PWR_MODE = "LOW" *) output          M68K_BR_n, // PU on Amiga MB
	input           M68K_BG_n, // No PU on Amiga MB : need PD on expansion in case host original 68k is absent
//	inout           M68K_BGACK_n, // PU on Amiga MB // Not used

// RAM
	output          RAMCE

 );


//RAM
	wire ram_d_OE;
	wire [15:12] ram_d;
	wire ram_dtack_range;
	wire _configin = 1'b0;
	wire _configout;
	
`ifdef RAM_AUTOCONFIG
	//ram_autoconfig
	ram_autoconfig ram(
		M68K_A[23:16],
		M68K_A[6:1],
		M68K_D[15:13],
		M68K_RESET_n,
		M68K_UDS_n,
		M68K_RW,
		_configin,
		_configout,
		ram_d,
		ram_d_OE,
		ram_dtack_range,		
		RAMCE
	);
`endif
`ifdef RAM_NONE
	assign _configout=1'b0;
	assign ram_dtack_range=1'b0;
	assign RAMCE=1'b0;
	assign ram_d_OE=1'b0;
`endif


//PISTORM
	localparam REG_DATA = 2'd0; //Pi 'A' commands to control transfer
	localparam REG_ADDR_LO = 2'd1;
	localparam REG_ADDR_HI = 2'd2;
	localparam REG_STATUS = 2'd3;

	(* PWR_MODE = "LOW" *) reg pistorm_off = 1'b0; //User has turned off the Pistorm using a long reset
	(* PWR_MODE = "LOW" *) reg pistorm_alive = 1'b0; //The Pistorm has been detected on the bus since the last manual reset (it is kept active when reset by the Pi)
	wire pistorm_active = pistorm_alive & !pistorm_off;
	(* PWR_MODE = "LOW" *) reg bus_requested = 1'b0; //When the Pistorm is active, we request is bus to the 68k ; it is relinquished at every system reset, and requested again if Pistorm is still active
	(* PWR_MODE = "LOW" *) reg bus_granted = 1'b0; //The 68k has granted its bus to the Pistorm and released AS
  
	wire manual_reset; //pulse when reset by the system, not by the Pi
	wire oor; //pulse when out of reset, delayed by one clock pulse (required to prevent lock after reset)

	reg [15:0] d_inout; //data register for transfer between Pi and 68k bus
	reg [23:1] a_out; //address register from Pi to 68k bus

	reg s2 = 1'd0; //68k bus states for the state machine
	reg s3 = 1'd0;
	reg s4 = 1'd0;
	reg s7 = 1'd1; //M68K waiting bus state

	wire e_clock; //synced with the 68K E clock or replace it
	(* PWR_MODE = "LOW" *) reg e_is_output = 1'b0; //no 68k E clock detected so we output our own
	(* PWR_MODE = "LOW" *) reg [3:0] e_counter = 4'd0;
	reg vma = 1'b0;

	(* PWR_MODE = "LOW" *) reg [2:0] ipl;
	(* PWR_MODE = "LOW" *) reg [2:0] ipl_a;

//	reg st_init = 1'b0; //1=reset, 0=run
	reg st_reset_out = 1'b0; //1=reset by the Pi, 0=run //was 1 but we must not maintain reset in case pistorm is not alive and to be able to switch using Ctrl+A+A
	reg op_req = 1'b0; //1=bus operation pending
	reg op_rw = 1'b1; //1=read, 0=write
	reg op_a0 = 1'b0; //1=lds, 0=uds, when sz=byte
	reg op_sz = 1'b0; //1=byte, 0=word


// PISTORM ACTIVATION, ON/OFF reset timer
//hold Ctrl+A+A during few seconds to toggle pistorm / 68k
	//reg [22:0] rst_timer = 23'd0;
	wire [22:0] rst_timer;
	clkdiv clkdiv0 (e_clock, rst_timer[0], M68K_RESET_n);
	clkdiv clkdiv1 (rst_timer[0], rst_timer[1], M68K_RESET_n);
	clkdiv clkdiv2 (rst_timer[1], rst_timer[2], M68K_RESET_n);
	clkdiv clkdiv3 (rst_timer[2], rst_timer[3], M68K_RESET_n);
	clkdiv clkdiv4 (rst_timer[3], rst_timer[4], M68K_RESET_n);
	clkdiv clkdiv5 (rst_timer[4], rst_timer[5], M68K_RESET_n);
	clkdiv clkdiv6 (rst_timer[5], rst_timer[6], M68K_RESET_n);
	clkdiv clkdiv7 (rst_timer[6], rst_timer[7], M68K_RESET_n);
	clkdiv clkdiv8 (rst_timer[7], rst_timer[8], M68K_RESET_n);
	clkdiv clkdiv9 (rst_timer[8], rst_timer[9], M68K_RESET_n);
	clkdiv clkdiv10 (rst_timer[9], rst_timer[10], M68K_RESET_n);
	clkdiv clkdiv11 (rst_timer[10], rst_timer[11], M68K_RESET_n);
	clkdiv clkdiv12 (rst_timer[11], rst_timer[12], M68K_RESET_n);
	clkdiv clkdiv13 (rst_timer[12], rst_timer[13], M68K_RESET_n);
	clkdiv clkdiv14 (rst_timer[13], rst_timer[14], M68K_RESET_n);
	clkdiv clkdiv15 (rst_timer[14], rst_timer[15], M68K_RESET_n);
	clkdiv clkdiv16 (rst_timer[15], rst_timer[16], M68K_RESET_n);
	clkdiv clkdiv17 (rst_timer[16], rst_timer[17], M68K_RESET_n);
	clkdiv clkdiv18 (rst_timer[17], rst_timer[18], M68K_RESET_n);
	clkdiv clkdiv19 (rst_timer[18], rst_timer[19], M68K_RESET_n);
	clkdiv clkdiv20 (rst_timer[19], rst_timer[20], M68K_RESET_n);
	clkdiv clkdiv21 (rst_timer[20], rst_timer[21], M68K_RESET_n);
	clkdiv clkdiv22 (rst_timer[21], rst_timer[22], M68K_RESET_n);

//	wire rst_overflow= rst_timer[21]; //3s
	wire rst_pistorm_mode= rst_timer[22]; //6s
//	wire rst_overflow= rst_timer[22] & rst_timer[21] & rst_timer[20]; //10s
	//always @(posedge e_clock) begin //use E_clock to spare some registers compared to 7M clock. 1 tick is 1.41 microseconds
	//	if(M68K_RESET_n)
	//		rst_timer <= 23'd0;
	//	else if(!rst_pistorm_mode)
	//		rst_timer <= rst_timer+1;
	//end
	always @(posedge rst_pistorm_mode)
		pistorm_off <= !pistorm_off;
//Pistorm is alive when it has some activity on its bus, until next reset by the user
	wire pistorm_alive_set = (PI_WR ^ PI_RD) & M68K_RESET_n; // if PI_WR and PI_RD are both up, these are the Pi pullups, there is either no emulator started or no SD
	always @(posedge pistorm_alive_set, posedge manual_reset) begin
		if(manual_reset)
			pistorm_alive <= 1'b0;
		else
			pistorm_alive <= 1'b1;
	end


// BUS ARBITRATION CONTROL
//each time we pull M68K_RESET_n we need to acquire again the bus from the host 68k (need confirmation)
	wire brset = pistorm_active & M68K_RESET_n;
	always @(posedge brset, negedge M68K_RESET_n) begin
		if(!M68K_RESET_n)
			bus_requested <= 1'b0;
		else
			bus_requested <= 1'b1;
	end
	wire bgset = bus_requested & M68K_RESET_n & !M68K_BG_n & M68K_AS_n & M68K_DTACK_n; // & M68K_BGACK_n;
	always @(posedge bgset, negedge M68K_RESET_n) begin
		if(!M68K_RESET_n)
			bus_granted <= 1'b0;
		else
			bus_granted <= 1'b1;
	end


// RESET
//generate the reset signals for our logic, for the host, and for the Pi
	(* PWR_MODE = "LOW" *) reg [1:0] resetfilter = 2'b11;
	assign oor = resetfilter==2'b01; //pulse when out of reset. delay by one clock pulse is required to prevent lock after reset
	always @(negedge M68K_CLK) begin
		resetfilter <= {resetfilter[0],M68K_RESET_n};
	end
	assign manual_reset = !M68K_RESET_n & !(pistorm_active & st_reset_out);
	assign PI_RESET_n = pistorm_off | M68K_RESET_n | st_reset_out; //Reset the Pi on m68kreset not requested by the pi, only when pistorm is active (otherwise emu68 boot loop)
	assign M68K_RESET_n = (pistorm_active & st_reset_out) ? 1'b0 : 1'bz; //Prevent the Pistorm when it is off from resetting the system
	assign M68K_HALT_n = (pistorm_active & st_reset_out) ? 1'b0 : 1'bz; //To reset both the processor and the external devices, the RESET and HALT input signals must be asserted at the same time


// M6800 - E CLOCK
//detect an external E clock, and if not output our own clock
//there is a pullup on M68K_E, so it stays up when no 68K is present
	(* PWR_MODE = "LOW" *) reg [1:0] e_input_detector = 2'd0;
	wire e_input_detected = &e_input_detector; //3 or more falling edges
	always @(negedge M68K_E) begin
		if(!e_input_detected)
			e_input_detector <= e_input_detector + 2'd1;
	end
	always @(posedge M68K_RESET_n) begin
		e_is_output <= e_is_output | !e_input_detected; //if no clock detected, output our own clock
	end
//sync our internal clock to the falling edge of the clock input if any
//	reg [1:0] e_input_filter=2'b00; //detect state change between clock ticks to sync the internal e_counter
//	wire e_fall_detected = e_input_filter == 2'b10;
//	always @(posedge M68K_CLK) begin
//		e_input_filter <= {e_input_filter[0],M68K_E};
	(* PWR_MODE = "LOW" *) reg e_input_filter=1'b0; //detect state change between clock ticks to sync the internal e_counter
	wire e_fall_detected = e_input_filter & !M68K_E;
	always @(negedge M68K_CLK) begin
		e_input_filter <= M68K_E;
	end
//generate internal E clock. A single period of clock E consists of 10 MC68000 clock periods (six clocks low, four clocks high)
	always @(negedge M68K_CLK) begin
		if (!e_is_output & e_fall_detected)
			e_counter <= 4'd1; //the external E clock falled last cycle, must sync
		else if (e_counter == 4'd9)
			e_counter <= 4'd0;
		else
			e_counter <= e_counter + 4'd1;
	end
	assign e_clock = (e_counter > 4'd5); //six clocks low (0-5), four clocks high (6-9)


// M6800 - VMA
//	wire vmarst= s7 | oor;
	wire vmarst= (M68K_VPA_n & M68K_CLK) | oor;
	always @(negedge M68K_CLK, posedge vmarst) begin
		if(vmarst)
			vma <= 1'b0;
		else if(s3 & !M68K_VPA_n & e_counter == 4'd3)
			vma <= 1'b1;
	end


// INTERRUPT CONTROL
	always @(negedge M68K_CLK) begin
		ipl_a <= ~M68K_IPL_n;
		if (ipl_a == ~M68K_IPL_n) //filter unstable signals
			ipl <= ~M68K_IPL_n;
	end
	assign PI_IPL_ZERO = (ipl == 3'd0) & bus_granted;


//PI SIDE

// PI WRITE CYCLE
	always @(posedge PI_WR) begin
		case (PI_A)
			REG_ADDR_LO: begin
				op_a0 <= PI_D[0];
				a_out[15:1] <= PI_D[15:1];
			end
			REG_ADDR_HI: begin
				a_out[23:16] <= PI_D[7:0];
				op_sz <= PI_D[8];
				op_rw <= PI_D[9];
			end
			REG_STATUS: begin
//				st_init <= PI_D[0];
				st_reset_out <= !PI_D[1];
			end
		endcase
	end

// PI OPERATION IN PROGRESS
	wire op_reqrst= s4 | oor; //release Pi bus in s4 because read and write are not buffered.
	wire op_reqset= PI_WR & PI_A==REG_ADDR_HI;
	always @(posedge op_reqset, posedge op_reqrst) begin
		if (op_reqset)
			op_req <= 1'b1;
		else
			op_req <= 1'b0;
	end

// DATA BUFFER
	wire d_ck = (PI_WR & PI_A==REG_DATA) | (s4 & op_rw) ;
	always @(posedge d_ck) begin
		if(op_rw & (s3|s4))
			d_inout <= M68K_D;
		else
			d_inout <= PI_D;
	end


// PI OUTPUTS

// SYNC WITH 68K BUS OPERATIONS
	assign PI_TXN_IN_PROGRESS = op_req;

// PI READ CYCLE
// place the required data word on the bus when PI_RD is set. In a REG_DATA cycle, Data is latched after the falling edge of PI_TXN_IN_PROGRESS
	assign PI_D = ((PI_A == REG_STATUS) && PI_RD) ? {ipl, 13'd0} : ((PI_A == REG_DATA && PI_RD) ? d_inout : 16'bz);



//68K BUS SIDE

// BUS TRANSFER STATE MACHINE
	wire s2rst= s3 | oor;
	wire s3rst= s4 | oor;
	wire s4rst= s7 | oor;
	wire s7rst= s2;
	always @(posedge M68K_CLK, posedge s2rst) begin
		if(s2rst)
			s2<=1'd0;
		else if(s7 & op_req & bus_granted)
			s2<=1'd1;
	end
	always @(negedge M68K_CLK, posedge s3rst) begin
		if(s3rst)
			s3<=1'd0;
		else if(s2)
			s3<=1'd1;
	end
	always @(posedge M68K_CLK, posedge s4rst) begin
		if(s4rst)
			s4<=1'd0;
		else if(s3 && (!M68K_DTACK_n | (vma & e_counter == 4'd9)) ) //S7 rise and E fall must match
			s4<=1'd1;
	end
	always @(negedge M68K_CLK, posedge s7rst) begin
		if(s7rst)
			s7<=1'd0;
		else if(s4 | oor)
			s7<=1'd1;
	end


// 68K BUS OUTPUTS

//	output [23:1]	M68K_A,
// Entering S1, the processor drives a valid address on the address bus.
// As the clock rises at the end of S7, the processor places the address and data buses in the high-impedance state
	assign M68K_A = (!bus_granted | (s7&!op_req)) ? 23'bz : a_out; //Z in s7 since it is the state where the Pistorm is waiting

//	inout [15:0]	M68K_D,
// READ : On the falling edge of the clock entering state 7 (S7), the processor latches data from the addressed device
// WRITE : During S3, the data bus is driven out of the high-impedance state as the data to be written is placed on the bus.
// As the clock rises at the end of S7, the processor places the address and data buses in the high-impedance state
	assign M68K_D[15:12] = ram_d_OE ? ram_d[15:12] : ( (!bus_granted | (s7|op_rw)) ? 4'bz : d_inout[15:12] ); //ram autoconfig data
	assign M68K_D[11:0] = (!bus_granted | (s7|op_rw)) ? 12'bz : d_inout[11:0] ;

//	output [2:0] M68K_FC,
//not supported

//	output      M68K_AS,
// On the rising edge of S2, the processor asserts AS and drives R/W low.
// On the falling edge of the clock entering S7, the processor negates AS, UDS, or LDS
	assign M68K_AS_n = bus_granted ? ( (s7) ? 1'b1:1'b0 ) : 1'bz;

//	output      M68K_UDS,
//	output      M68K_LDS,
// READ : On the rising edge of state 2 (S2), the processor asserts AS and UDS, LDS, or DS
// WRITE : At the rising edge of S4, the processor asserts UDS, or LDS // wrong: DS should be set in s3
// On the falling edge of the clock entering S7, the processor negates AS, UDS, or LDS
	wire op_ds_n = (s2&!op_rw)|s7;
	assign M68K_UDS_n = bus_granted ? ( (op_ds_n|(op_sz & op_a0)) ? 1'b1:1'b0 ) : 1'bz; //disable uds when byte operation on odd address
	assign M68K_LDS_n = bus_granted ? ( (op_ds_n|(op_sz & !op_a0)) ? 1'b1:1'b0 ) : 1'bz; //disable lds when byte operation on even address

//	output      M68K_RW,
// On the rising edge of S2, the processor asserts AS and drives R/W low.
// As the clock rises at the end of S7, the processor drives R/W high
	assign M68K_RW = bus_granted ? ( (op_rw) ? 1'b1:1'b0 ) : 1'bz;

// output      M68K_E,
	assign M68K_E = e_is_output ? e_clock : 1'bz;

//	output      M68K_VMA_n,
	assign M68K_VMA_n = bus_granted ? ( vma ? 1'b0:1'b1 ) : 1'bz;

//	output      M68K_BR,
// indicates to the processor that some other device needs to become the bus master
	assign M68K_BR_n = bus_requested ? 1'b0:1'bz;
//	output      M68K_BGACK,
// indicates that some other device has become the bus master
//	assign M68K_BGACK_n = bus_granted ? 1'b0:1'bz;

//	output      M68K_DTACK_n,
// This input signal indicates the completion of the data transfer. When the processor
// recognizes DTACK during a read cycle, data is latched, and the bus cycle is terminated.
// When DTACK is recognized during a write cycle, the bus cycle is terminated.
	assign M68K_DTACK_n = (!M68K_AS_n & (ram_dtack_range)) ? 1'b0 : 1'bz;

endmodule
