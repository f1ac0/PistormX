/*
 * Pistorm'X for Xilinx CPLD, with integrated buffers and without 200MHz clock
 * 68K flavour, that cohabit with the host original 68000 and can switch which one is activated by maintaining reset during at least 10 seconds
 * 2022 FLACO CC-BY-NC-SA
 * Inspired by original Pistorm, Copyright 2020 Claude Schwarz and Niklas Ekström, https://github.com/captain-amygdala/pistorm
 */

module pistormx68k(
	output          PI_TXN_IN_PROGRESS, // GPIO0 //AUX0
	output          PI_IPL_ZERO,        // GPIO1 //AUX1
	input   [1:0]   PI_A,       // GPIO[3..2]
//	input           PI_CLK,     // GPIO4 // Not used
	output          PI_RESET_n, // GPIO5
	input           PI_RD,      // GPIO6
	input           PI_WR,      // GPIO7
	inout   [15:0]  PI_D,       // GPIO[23..8]

	output  [23:1]	 M68K_A,
	inout   [15:0]	 M68K_D,
	input           M68K_CLK,
//	output  [2:0]   M68K_FC,   // PU on Amiga MB // Not used

	inout           M68K_AS_n,  // PU on Amiga MB
	output          M68K_UDS_n, // PU on Amiga MB
	output          M68K_LDS_n, // PU on Amiga MB
	output          M68K_RW,    // PU on Amiga MB

	input           M68K_DTACK_n,
//	input           M68K_BERR_n, // Not used

	input           M68K_VPA_n,
	inout           M68K_E,     // the host original 68k, if present, will generate this E clock. No PU on Amiga MB : need PU on expansion to detect if we need to generate this clock
	output          M68K_VMA_n, // PU on Amiga MB

	input   [2:0]   M68K_IPL_n,

	inout           M68K_RESET_n, // PU on Amiga MB
	inout           M68K_HALT_n, // PU on Amiga MB

// These are dealing with the host original 68k, so their directions are those of a device, not a CPU
	output          M68K_BR_n, // PU on Amiga MB
	input           M68K_BG_n, // No PU on Amiga MB : need PD on expansion in case host original 68k is absent
	inout           M68K_BGACK_n // PU on Amiga MB
 );


  localparam REG_DATA = 2'd0;
  localparam REG_ADDR_LO = 2'd1;
  localparam REG_ADDR_HI = 2'd2;
  localparam REG_STATUS = 2'd3;

  reg pistorm_off=1'b0; //User is turning off the Pistorm
  reg bus_requested=1'b0; //68k bus is requested by Pistorm
  reg bus_granted=1'b0; //68k bus is granted to Pistorm

  wire c7m = bus_granted & M68K_CLK; //filtered clock when inactive
  reg vma = 1'b0;
  wire oor; //pulse when out of reset, delayed by one clock pulse (required to prevent lock after reset)

  reg [15:0] d_inout;
  reg [23:1] a_out;

  reg s2=1'd0;
  reg s3=1'd0;
  reg s4=1'd0;
  reg s7=1'd1; //M68K waiting bus state

  reg e_is_output=1'd0;
  reg [3:0] e_counter = 4'd0;

  reg [2:0] ipl;
  reg [2:0] ipl_a;

//  reg st_init = 1'b0; //1=reset, 0=run
  reg st_reset_out = 1'b0; //1=reset, 0=run //was 1 but we must not maintain reset in case pistorm is not alive and to be able to switch using Ctrl+A+A
  reg op_req = 1'b0; //1=bus operation pending
  reg op_rw = 1'b1; //1=read, 0=write
  reg op_a0 = 1'b0; //1=lds, 0=uds, when sz=byte
  reg op_sz = 1'b0; //1=byte, 0=word


// ON/OFF reset timer
//hold Ctrl+A+A during few seconds to toggle pistorm / 68k
  reg [26:0] rst_timer;
//  wire rst_3s= rst_timer[24] & rst_timer[22];
//  wire rst_6s= rst_timer[25] & rst_timer[23];
  wire rst_10s= rst_timer[26];
  always @(posedge M68K_CLK)
  begin
    if(M68K_RESET_n)
      rst_timer <= 27'b0;
    else
      rst_timer <= rst_timer+1;
  end
  always @(posedge rst_10s)
    pistorm_off <= !pistorm_off;


// BUS ARBITRATION CONTROL
// each time we pull M68K_RESET_n we need to acquire again the bus from the host 68k (need confirmation)
  wire brset = !pistorm_off & (PI_WR | PI_RD) & M68K_RESET_n;
  always @(posedge brset, negedge M68K_RESET_n) begin
    if(!M68K_RESET_n)
      bus_requested <= 1'b0;
    else
      bus_requested <= 1'b1;
  end
  wire bgset = bus_requested & M68K_RESET_n & !M68K_BG_n & M68K_AS_n & M68K_DTACK_n & M68K_BGACK_n;
  always @(posedge bgset, negedge M68K_RESET_n) begin
    if(!M68K_RESET_n)
      bus_granted <= 1'b0;
    else
      bus_granted <= 1'b1;
  end


// RESET
// generate the reset signals for our logic, for the host, and for the Pi
  reg [1:0] resetfilter=2'b11;
  assign oor = resetfilter==2'b01; //pulse when out of reset. delay by one clock pulse is required to prevent lock after reset
  always @(negedge M68K_CLK) begin
    resetfilter <= {resetfilter[0],M68K_RESET_n};
  end
  assign PI_RESET_n = pistorm_off | M68K_RESET_n | st_reset_out; //Reset the Pi on m68kreset not requested by the pi, only when pistorm is active (otherwise emu68 boot loop)
  assign M68K_RESET_n = (!pistorm_off & st_reset_out) ? 1'b0 : 1'bz; //Prevent the Pistorm when it is off from resetting the system
  assign M68K_HALT_n = (!pistorm_off & st_reset_out) ? 1'b0 : 1'bz; //To reset both the processor and the external devices, the RESET and HALT input signals must be asserted at the same time


// E CLOCK
// detect an external E clock and sync our internal clock to it, or output our own clock
  wire e_input = M68K_E | e_is_output; //prevent e_input falling edge from being detected when e_is_output
  reg [1:0] e_input_filter=2'b00; //detect state change between clock ticks to sync the internal e_counter
  reg [1:0] e_input_detected=2'b00; //bit 0=low state detected during current E cycle ; bit 1=previous E cycle
  always @(posedge M68K_CLK) begin
    e_input_filter <= {e_input_filter[0],e_input};
    e_input_detected[0] <= (e_input_detected[0] & |e_counter) | !e_input;
	 e_input_detected[1] <= (|e_counter)?e_input_detected[1]:e_input_detected[0];
  end
  always @(posedge M68K_RESET_n)
	 e_is_output <= !(|e_input_detected); //if no clock detected, output our own clock
// internal E generation. A single period of clock E consists of 10 MC68000 clock periods (six clocks low, four clocks high)
  always @(negedge M68K_CLK) begin
    if (e_input_filter == 2'b10)
	   e_counter <= 4'd1; //the external E clock falled last cycle, must sync
	 else if (e_counter == 4'd9)
      e_counter <= 4'd0;
    else
      e_counter <= e_counter + 4'd1;
  end
  assign M68K_E = e_is_output ? ((e_counter > 4'd5) ? 1'b1:1'b0) : 1'bz; //six clocks low (0-5), four clocks high (6-9)


// INTERRUPT CONTROL
  always @(negedge c7m) begin
    ipl_a <= ~M68K_IPL_n;
    if (ipl_a == ~M68K_IPL_n) //filter unstable signals
      ipl <= ~M68K_IPL_n;
  end
  assign PI_IPL_ZERO = ipl == 3'd0;


// PI SIDE

// PI READ CYCLE
// place the required data word on the bus when PI_RD is set. In a REG_DATA cycle, Data is latched after the falling edge of PI_TXN_IN_PROGRESS
  assign PI_D = ((PI_A == REG_STATUS) && PI_RD) ? {ipl, 13'd0} : ((PI_A == REG_DATA && PI_RD) ? d_inout : 16'bz);

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
//		  st_init <= PI_D[0];
        st_reset_out <= !PI_D[1];
      end
    endcase
  end


// Sync with 68K bus operations
  assign PI_TXN_IN_PROGRESS = op_req;

//release Pi bus in s4 because read and write are not buffered.
  wire op_reqrst= s4 | oor;
  wire op_reqset= PI_WR & PI_A==REG_ADDR_HI;
  always @(posedge op_reqset, posedge op_reqrst) begin
    if (op_reqset)
      op_req <= 1'b1;
    else
      op_req <= 1'b0;
  end

  wire d_ck = (PI_WR & PI_A==REG_DATA) | (s4 & op_rw) ;
  always @(posedge d_ck) begin
    if(op_rw & (s3|s4))
      d_inout <= M68K_D;
	else
	  d_inout <= PI_D;
  end


//68K BUS SIDE

// BUS TRANSFER STATE MACHINE
  wire s2rst= s3 | oor;
  wire s3rst= s4 | oor;
  wire s4rst= s7 | oor;
  wire s7rst= s2;
  always @(posedge c7m, posedge s2rst) begin
    if(s2rst)
      s2<=1'd0;
    else if(s7 && op_req)
      s2<=1'd1;
  end
  always @(negedge c7m, posedge s3rst) begin
    if(s3rst)
      s3<=1'd0;
    else if(s2)
      s3<=1'd1;
  end
  always @(posedge c7m, posedge s4rst) begin
    if(s4rst)
      s4<=1'd0;
    else if(s3 && (!M68K_DTACK_n || (vma && e_counter == 4'd9)) ) //S7 rise and E fall must match
      s4<=1'd1;
  end
  always @(negedge c7m, posedge s7rst) begin
    if(s7rst)
      s7<=1'd0;
    else if(s4 | oor)
      s7<=1'd1;
  end

//	output [23:1]	M68K_A,
// Entering S1, the processor drives a valid address on the address bus.
// As the clock rises at the end of S7, the processor places the address and data buses in the high-impedance state
  assign M68K_A = (!bus_granted | (s7&!op_req)) ? 23'bz : a_out; //Z in s7 since it is the state where the Pistorm is waiting

//	inout [15:0]	M68K_D,
// READ : On the falling edge of the clock entering state 7 (S7), the processor latches data from the addressed device
// WRITE : During S3, the data bus is driven out of the high-impedance state as the data to be written is placed on the bus.
// As the clock rises at the end of S7, the processor places the address and data buses in the high-impedance state
  assign M68K_D = (!bus_granted | ((s7&!op_req)|s2|op_rw)) ? 16'bz : d_inout;

//	output  reg [2:0] M68K_FC,
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

//	output reg      M68K_VMA_n,
  wire vmarst= s7 | oor;
  always @(posedge c7m,posedge vmarst) begin
    if(vmarst)
      vma <= 1'b0;
    else if(s3 && !M68K_VPA_n && e_counter == 4'd2)
      vma <= 1'b1;
  end
  assign M68K_VMA_n = bus_granted ? ( vma ? 1'b0:1'b1 ) : 1'bz;


//	output      M68K_BR,
// indicates to the processor that some other device needs to become the bus master
  assign M68K_BR_n = bus_requested ? 1'b0:1'bz;
//	output      M68K_BGACK,
// indicates that some other device has become the bus master
  assign M68K_BGACK_n = bus_granted ? 1'b0:1'bz;

endmodule
