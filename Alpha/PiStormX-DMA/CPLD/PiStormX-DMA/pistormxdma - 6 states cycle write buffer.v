/*
 * Pistorm'X for Xilinx CPLD, with integrated buffers and without 200MHz clock
 * 2022 FLACO CC-BY-NC-SA
 * Inspired by original Pistorm, Copyright 2020 Claude Schwarz and Niklas Ekström, https://github.com/captain-amygdala/pistorm
 */
module pistormxdma(
	output          PI_TXN_IN_PROGRESS, // GPIO0 //AUX0
	output          PI_IPL_ZERO,        // GPIO1 //AUX1
	input   [1:0]   PI_A,       // GPIO[3..2]
//	input           PI_CLK,     // GPIO4 // Not used
	output          PI_RESET,   // GPIO5
	input           PI_RD,      // GPIO6
	input           PI_WR,      // GPIO7
	inout   [15:0]  PI_D,       // GPIO[23..8]

	output  [23:1]	 M68K_A,
	inout   [15:0]	 M68K_D,
	input           M68K_CLK,
//	output  [2:0]   M68K_FC,   // PU on Amiga MB // Not used

	output          M68K_AS_n,  // PU on Amiga MB
	output          M68K_UDS_n, // PU on Amiga MB
	output          M68K_LDS_n, // PU on Amiga MB
	output          M68K_RW,    // PU on Amiga MB

	input           M68K_DTACK_n,
//	input           M68K_BERR_n, // Not used

	input           M68K_VPA_n,
	output          M68K_E,     // No PU on Amiga MB
	output          M68K_VMA_n, // PU on Amiga MB

	input   [2:0]   M68K_IPL_n,

	inout           M68K_RESET_n, // PU on Amiga MB
	inout           M68K_HALT_n, // PU on Amiga MB

	input           M68K_BR_n,
	output          M68K_BG_n,
	input           M68K_BGACK_n
 );

//  initial begin
//    M68K_BG_n <= 1'b1;
//  end

  localparam REG_DATA = 2'd0;
  localparam REG_ADDR_LO = 2'd1;
  localparam REG_ADDR_HI = 2'd2;
  localparam REG_STATUS = 2'd3;

  wire bus_requested = !M68K_BR_n;
  reg bus_granted = 1'b0;

  wire c7m = M68K_CLK;
  reg M68K_VMA_nr = 1'd1;

  reg [15:0] d_out;
  reg [23:1] a_out;

  reg s0=1'd1; //M68K bus states
  reg s1=1'd0;
  reg s2=1'd0;
  reg s3=1'd0;
  reg s4=1'd0;
  reg s7=1'd0;

  reg [3:0] e_counter = 4'd0;

  reg [2:0] ipl;
  reg [2:0] ipl_a;

//  reg st_init = 1'b0; //1=reset, 0=run
  reg st_reset_out = 1'b1; //1=reset, 0=run
  reg op_req = 1'b0; //1=bus operation pending
  reg op_rw = 1'b1; //1=read, 0=write
  reg op_a0 = 1'b0; //1=lds, 0=uds, when sz=byte
  reg op_sz = 1'b0; //1=byte, 0=word

//buffered write
  reg [15:0] buf_d;
  reg [23:1] buf_a;
  reg buf_rw;
  reg buf_a0;
  reg buf_sz;

// BUS ARBITRATION CONTROL
  wire bgset = bus_requested & s7;
  wire bgreset = !bus_requested & M68K_BGACK_n;
  always @(posedge bgset, posedge bgreset) begin
    if(bgreset)
      bus_granted <= 1'b0;
    else
      bus_granted <= 1'b1;
  end
  
// RESET
  reg [1:0] resetfilter=2'b11;
  wire oor = resetfilter==2'b01; //pulse when out of reset. delay by one clock pulse is required to prevent lock after reset
  always @(negedge c7m) begin
    resetfilter <= {resetfilter[0],M68K_RESET_n};
  end
  assign PI_RESET = st_reset_out ? 1'b1 : M68K_RESET_n;
  assign M68K_RESET_n = st_reset_out ? 1'b0 : 1'bz;
  assign M68K_HALT_n = st_reset_out ? 1'b0 : 1'bz;

// E CLOCK
// A single period of clock E consists of 10 MC68000 clock periods (six clocks low, four clocks high)
  always @(negedge c7m) begin
    if (e_counter == 4'd9)
      e_counter <= 4'd0;
    else
      e_counter <= e_counter + 4'd1;
  end
  assign M68K_E = (e_counter > 4'd5) ? 1'b1:1'b0; //six clocks low (0-5), four clocks high (6-9)

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
  assign PI_D = ((PI_A == REG_STATUS) && PI_RD) ? {ipl, 13'd0} : ((PI_A == REG_DATA && PI_RD) ? buf_d : 16'bz);

// PI WRITE CYCLE
  always @(posedge PI_WR) begin
    case (PI_A)
      REG_ADDR_LO: begin
        buf_a0 <= PI_D[0];
        buf_a[15:1] <= PI_D[15:1];
      end
      REG_ADDR_HI: begin
        buf_a[23:16] <= PI_D[7:0];
        buf_sz <= PI_D[8];
        buf_rw <= PI_D[9];
      end
      REG_STATUS: begin
//		  st_init <= PI_D[0];
        st_reset_out <= !PI_D[1];
      end
    endcase
  end
  

// Sync with 68K bus operations
  assign PI_TXN_IN_PROGRESS = op_req;

//release write early thanks to the buffer.
//release read in s4 because it is not buffered
  wire op_reqrst= (op_rw?s4:s3) | oor;
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
      buf_d <= M68K_D;
	 else
	   buf_d <= PI_D;
  end
  
  always @(posedge s2) begin
    a_out<=buf_a;
    d_out<=buf_d;
    op_a0<=buf_a0;
    op_sz<=buf_sz;
    op_rw<=buf_rw;
  end
  
  
//68K BUS SIDE

// BUS TRANSFER STATE MACHINE
  wire s1rst= s2 | oor;
  wire s2rst= s3 | oor;
  wire s3rst= s4 | oor;
  wire s4rst= s7 | oor;
  wire s7rst= s0 | oor;
  always @(negedge c7m, posedge s1rst) begin
    if(s1rst)
      s1<=1'd0;
    else if(s0)
      s1<=1'd1;
  end
  always @(posedge c7m, posedge s2rst) begin
    if(s2rst)
      s2<=1'd0;
    else if(s1 && op_req && !bus_granted)
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
    else if(s3 && (!M68K_DTACK_n || (!M68K_VMA_nr && e_counter == 4'd9)) ) //S7 rise and E fall must match
      s4<=1'd1;
  end
  always @(negedge c7m, posedge s7rst) begin
    if(s7rst)
      s7<=1'd0;
    else if(s4)
      s7<=1'd1;
  end
  always @(posedge c7m, posedge s1) begin
    if(s1)
      s0<=1'd0;
    else if(s7 | oor)
      s0<=1'd1;
  end

//	output [23:1]	M68K_A,
// Entering S1, the processor drives a valid address on the address bus.
// As the clock rises at the end of S7, the processor places the address and data buses in the high-impedance state
  assign M68K_A = (bus_granted | (s0|s1)) ? 23'bz : a_out; //Z also in s1 since it is the state where the Pistorm is waiting
  
//	inout [15:0]	M68K_D,
// READ : On the falling edge of the clock entering state 7 (S7), the processor latches data from the addressed device
// WRITE : During S3, the data bus is driven out of the high-impedance state as the data to be written is placed on the bus.
// As the clock rises at the end of S7, the processor places the address and data buses in the high-impedance state
  assign M68K_D = (bus_granted | (s0|s1|s2|op_rw)) ? 16'bz : d_out;

//	output  reg [2:0] M68K_FC,
//not supported

//	output      M68K_AS,
// On the rising edge of S2, the processor asserts AS and drives R/W low.
// On the falling edge of the clock entering S7, the processor negates AS, UDS, or LDS
  assign M68K_AS_n = bus_granted ? 1'bz : ((s0|s1|s7) ? 1'b1:1'b0);

//	output      M68K_UDS,
//	output      M68K_LDS,
// READ : On the rising edge of state 2 (S2), the processor asserts AS and UDS, LDS, or DS
// WRITE : At the rising edge of S4, the processor asserts UDS, or LDS // wrong: DS should be set in s3
// On the falling edge of the clock entering S7, the processor negates AS, UDS, or LDS
  wire op_ds_n = s0|s1|(s2&!op_rw)|s7;
  assign M68K_UDS_n = bus_granted ? 1'bz : ((op_ds_n|(op_sz & op_a0)) ? 1'b1:1'b0); //disable uds when byte operation on odd address
  assign M68K_LDS_n = bus_granted ? 1'bz : ((op_ds_n|(op_sz & !op_a0)) ? 1'b1:1'b0); //disable lds when byte operation on even address

//	output      M68K_RW,
// On the rising edge of S2, the processor asserts AS and drives R/W low.
// As the clock rises at the end of S7, the processor drives R/W high
  assign M68K_RW = bus_granted ? 1'bz : ((s0|s1|op_rw) ? 1'b1:1'b0);
  
//	output reg      M68K_VMA_n,
  wire vmarst= s7 | oor;
  always @(posedge c7m,posedge vmarst) begin
    if(vmarst)
      M68K_VMA_nr <= 1'b1;
    else if(s3 && !M68K_VPA_n && e_counter == 4'd2)
      M68K_VMA_nr <= 1'b0;
  end
  assign M68K_VMA_n = bus_granted ? 1'bz : (M68K_VMA_nr ? 1'b1:1'b0);

//	output      M68K_BG,
// indicates to all other potential bus master devices that the processor will relinquish bus control at the end of the current bus cycle.
  assign M68K_BG_n = bus_requested ? 1'b0:1'b1;


endmodule

