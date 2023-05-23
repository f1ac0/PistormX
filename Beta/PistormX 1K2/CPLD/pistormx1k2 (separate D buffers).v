/*
 * Pistorm'X for Xilinx CPLD, with integrated buffers and without 200MHz clock
 * 68K flavour, that can cohabit with the host original 68000 and can switch which one is activated by maintaining reset during at least 6 seconds
 * 2022 FLACO CC-BY-NC-SA
 * Inspired by original Pistorm, Copyright 2020 Claude Schwarz and Niklas Ekström, https://github.com/captain-amygdala/pistorm
 */

module pistormx1k2(
	output          PI_TXN_IN_PROGRESS, // GPIO0 //AUX0
//	output          PI_IPL_ZERO,        // GPIO1 //AUX1
	output  [2:0]   PI_IPL,        // GPIO1 //AUX1
	input   [2:0]   PI_A,       // GPIO[3..2]
	input           PI_RD,      // GPIO6
	input           PI_WR,      // GPIO7
	inout   [15:0]  PI_D,       // GPIO[23..8]
	output          PI_RESET_n, // GPIO5
   input           PI_SER_DAT,
   input           PI_SER_CLK,
	 
	output  [23:0]	 M68K_A,
	inout   [31:0]	 M68K_D,
	input           M68K_CLK,
	output  [1:0]   M68K_FC,   // PU on Amiga MB ; FC2 not connected inside A1200
	
	inout           M68K_AS_n,  // PU on Amiga MB
	output          M68K_DS_n,  // PU on Amiga MB
	output  [1:0]   M68K_SIZ, // PU on Amiga MB
	output          M68K_RW,    // PU on Amiga MB

	input   [1:0]   M68K_DSACK_n,
	input           M68K_BERR_n,

//	input           M68K_E,     //  clock 1 tick is 1.41 microseconds

	input   [2:0]   M68K_IPL_n,

	inout           M68K_RESET_n, // PU on Amiga MB
	inout           M68K_HALT_n, // PU on Amiga MB

// These are dealing with the host original 68k, so their directions are those of a device, not a CPU
	output          M68K_BR_n, // PU on Amiga MB
	input           M68K_BG_n, // No PU on Amiga MB : need PD on expansion in case host original 68k is absent
//	inout           M68K_BGACK_n, // PU on Amiga MB

// EXT
   output          OVR_n,
	output          INT2_n,
	output          INT6_n,
	input           KB_RESET_n,
	output   [10:0] SPARE
 );


  localparam REG_DATA_LO = 3'd0;
  localparam REG_DATA_HI = 3'd1;
  localparam REG_ADDR_LO = 3'd2;
  localparam REG_ADDR_HI = 3'd3;
  localparam REG_STATUS = 3'd4;

  reg pistorm_off = 1'b0; //User has turned off the Pistorm using a long reset
  reg pistorm_alive = 1'b0; //The Pistorm has been detected on the bus since the last manual reset (it is kept active when reset by the Pi)
  wire pistorm_active = pistorm_alive & !pistorm_off;
  reg bus_requested = 1'b0; //When the Pistorm is active, we request is bus to the 68k ; it is relinquished at every system reset, and requested again if Pistorm is still active
  reg bus_granted = 1'b0; //The 68k has granted its bus to the Pistorm

  wire c14m = M68K_CLK;
  
  wire manual_reset; //pulse when reset by the system, not by the Pi
  wire oor; //pulse when out of reset, delayed by one clock pulse (required to prevent lock after reset)

  reg [31:0] data_in;
  reg [31:0] data_out;
  reg [23:0] addr;
  
  reg s2 = 1'd0;
  reg s3 = 1'd0;
  reg s4 = 1'd0;
  reg s7 = 1'd1; //M68K waiting bus state

  reg [2:0] ipl;
  reg [2:0] ipl_a;

  reg bm_out = 1'b0;
  reg reset_out = 1'b0; //1=reset by the Pi, 0=run //was 1 but we must not maintain reset in case pistorm is not alive and to be able to switch using Ctrl+A+A
  reg halt_out = 1'b0;
  reg int2_out = 1'b0;
  reg int6_out = 1'b0;

  reg op_req = 1'b0; //1=operation pending
  reg rw = 1'b1; //1=read, 0=write
//  reg [1:0] op_size = 2'b0; //0=byte, 1=word, 3=longword, (2=3 bytes)
  reg [2:0] fc;

  reg [1:0] size = 2'b0; //0=byte, 1=word, 3=longword, //operation size
  wire [1:0] port_width; // 0=8b, 1=16b, 3=32b //reply from the device ; valid only during s4 !
  wire [1:0] left_shift = addr[1:0] & port_width; // valid only during s4 !
  wire [1:0] transfered = port_width - left_shift; // valid only during s4 !

  wire [7:0] op0_wr=data_out[31:24];
  wire [7:0] op1_wr=data_out[23:16];
  wire [7:0] op2_wr=data_out[15:8];
  wire [7:0] op3_wr=data_out[7:0];
  wire [7:0] op0_rd=M68K_D[31:24];
  wire [7:0] op1_rd=M68K_D[23:16];
  wire [7:0] op2_rd=M68K_D[15:8];
  wire [7:0] op3_rd=M68K_D[7:0];

  assign SPARE[0] = PI_SER_DAT;
  assign SPARE[1] = PI_SER_CLK;


// Pistorm activation, ON/OFF reset timer
//hold Ctrl+A+A during few seconds to toggle pistorm / 68k
  reg [22:0] rst_timer = 23'd0;
//  wire rst_overflow= rst_timer[21]; //3s
  wire rst_pistorm_mode= rst_timer[22]; //6s
//  wire rst_overflow= rst_timer[22] & rst_timer[21] & rst_timer[20]; //10s
  always @(posedge c14m) begin //1 tick is 71ns
    if(M68K_RESET_n)
      rst_timer <= 23'd0;
    else if(!rst_pistorm_mode)
      rst_timer <= rst_timer+1;
  end
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
// each time we pull M68K_RESET_n we need to acquire again the bus from the host 68k (need confirmation)
  wire brset = pistorm_active & bm_out & M68K_RESET_n;
  always @(posedge brset, negedge M68K_RESET_n) begin
    if(!M68K_RESET_n)
      bus_requested <= 1'b0;
    else
      bus_requested <= 1'b1;
  end
  wire bgset = bus_requested & M68K_RESET_n & !M68K_BG_n & M68K_AS_n & &M68K_DSACK_n; // & M68K_BGACK_n;
  always @(posedge bgset, negedge M68K_RESET_n) begin
    if(!M68K_RESET_n)
      bus_granted <= 1'b0;
    else
      bus_granted <= 1'b1;
  end


// RESET
// generate the reset signals for our logic, for the host, and for the Pi
  reg [1:0] resetfilter = 2'b11;
  assign oor = resetfilter==2'b01; //pulse when out of reset. delay by one clock pulse is required to prevent lock after reset
  always @(negedge M68K_CLK) begin
    resetfilter <= {resetfilter[0],M68K_RESET_n};
  end
  assign manual_reset = !M68K_RESET_n & !(pistorm_active & reset_out);
//  assign PI_RESET_n = pistorm_off | M68K_RESET_n | reset_out; //Reset the Pi on m68kreset not requested by the pi, only when pistorm is active (otherwise emu68 boot loop)
  assign PI_RESET_n = KB_RESET_n;
  assign M68K_RESET_n = (pistorm_active & reset_out) ? 1'b0 : 1'bz; //Prevent the Pistorm when it is off from resetting the system
  assign M68K_HALT_n = (pistorm_active & halt_out) ? 1'b0 : 1'bz; //To reset both the processor and the external devices, the RESET and HALT input signals must be asserted at the same time


// INTERRUPT CONTROL
  always @(negedge c14m) begin
    ipl_a <= M68K_IPL_n;
    if (ipl_a == M68K_IPL_n) //filter unstable signals
      ipl <= M68K_IPL_n;
  end
//  assign PI_IPL_ZERO = (ipl == 3'd0) & bus_granted;
  assign PI_IPL = ipl & bus_granted;

// PI SIDE

// PI READ CYCLE
// place the required data word on the bus when PI_RD is set. In a REG_DATA cycle, Data is latched after the falling edge of PI_TXN_IN_PROGRESS
  assign PI_D = ((PI_A == REG_STATUS) & PI_RD) ? {ipl, 13'd0} : ((PI_A == REG_DATA_HI & PI_RD) ? data_in[31:16] : ((PI_A == REG_DATA_LO & PI_RD) ? data_in[15:0] : 16'bz));

// PI WRITE CYCLE
  always @(posedge PI_WR) begin
    case (PI_A)
      REG_ADDR_LO: begin
//        addr[15:0] <= PI_D[15:0];
      end
      REG_ADDR_HI: begin
//        addr[23:16] <= PI_D[7:0];
//        size <= PI_D[9:8];
        rw <= PI_D[10];
		  fc <= PI_D[13:11];
      end
      REG_STATUS: begin
        bm_out <= PI_D[0];
//        st_reset_out <= !PI_D[1];
        reset_out <= PI_D[1];
        halt_out <= PI_D[2];
        int2_out <= PI_D[3];
        int6_out <= PI_D[4];
      end
    endcase
  end

// Sync with 68K bus operations
  assign PI_TXN_IN_PROGRESS = op_req;


  wire any_termination = |(~{M68K_DSACK_n, M68K_BERR_n, M68K_RESET_n});
  wire terminated_normally = M68K_BERR_n && M68K_RESET_n;
  wire terminate_req = (!terminated_normally | terminated_normally & size <= transfered);
  wire continue_req = !(!terminated_normally | terminated_normally & size <= transfered);
  
/*  always @(posedge s4) begin
    if (!terminated_normally || terminated_normally && size <= transfered) begin
      //end of request
		op_req <= 1'b0;
    end else begin
      // Perform another bus cycle for this access.
      addr <= addr + {22'd0, transfered + 2'd1};
      size <= size - (transfered + 2'd1);
    end
  end
*/

  wire addr_ck = PI_WR | (s4 & continue_req);
  always @(posedge addr_ck) begin
    if(s4 & continue_req)
	   addr <= addr + {22'd0, transfered + 2'd1};
    else if(PI_A==REG_ADDR_LO)
	   addr[15:0] <= PI_D[15:0];
	 else if(PI_A==REG_ADDR_HI)
	   addr[23:16] <= PI_D[7:0];
  end
  
  wire size_ck = (PI_WR & PI_A==REG_ADDR_HI) | (s4 & continue_req);
  always @(posedge size_ck) begin
    if(PI_WR & PI_A==REG_ADDR_HI)
	   size <= PI_D[9:8];
	 else
	   size <= size - (transfered + 2'd1);
  end


//release Pi bus in s4 because read and write are not buffered.
  wire op_req_ck = (PI_WR & PI_A==REG_ADDR_HI) | s4 | oor;
  wire op_reqrst= (s4 & terminate_req) | oor;
  wire op_reqset= PI_WR & PI_A==REG_ADDR_HI;
  always @(posedge op_req_ck) begin
    if (op_reqrst)
      op_req <= 1'b0;
    else if (op_reqset)
      op_req <= 1'b1;
  end

//data buffer management
  //Table 5-4 for read operation sizing and alignment
  function [7:0] getDataIn3(input [1:0] sz, input [1:0] shift);
    case (size)
      2'd0:
        case (left_shift)
          2'd0: getDataIn3 = op0_rd;
          2'd1: getDataIn3 = op1_rd;
          2'd2: getDataIn3 = op2_rd;
          2'd3: getDataIn3 = op3_rd;
        endcase
      2'd1:
        case (left_shift)
          2'd0: getDataIn3 = op1_rd;
          2'd1: getDataIn3 = op2_rd;
          2'd2: getDataIn3 = op3_rd;
          default: getDataIn3 = 8'bx;
        endcase
      2'd2:
        case (left_shift)
          2'd0: getDataIn3 = op2_rd;
          2'd1: getDataIn3 = op3_rd;
          default: getDataIn3 = 8'bx;
        endcase
      2'd3:
        case (left_shift)
          2'd0: getDataIn3 = op3_rd;
          default: getDataIn3 = 8'bx;
        endcase
    endcase
  endfunction

  function [7:0] getDataIn2(input [1:0] sz, input [1:0] shift);
    case (size)
      2'd1:
        case (left_shift)
          2'd0: getDataIn2 = op0_rd;
          2'd1: getDataIn2 = op1_rd;
          2'd2: getDataIn2 = op2_rd;
          2'd3: getDataIn2 = op3_rd;
        endcase
      2'd2:
        case (left_shift)
          2'd0: getDataIn2 = op1_rd;
          2'd1: getDataIn2 = op2_rd;
          2'd2: getDataIn2 = op3_rd;
          default: getDataIn2 = 8'bx;
        endcase
      2'd3:
        case (left_shift)
          2'd0: getDataIn2 = op2_rd;
          2'd1: getDataIn2 = op3_rd;
          default: getDataIn2 = 8'bx;
        endcase
		default: getDataIn2 = data_in[15:8];
    endcase
  endfunction

  function [7:0] getDataIn1(input [1:0] sz, input [1:0] shift);
    case (size)
      2'd2:
        case (left_shift)
          2'd0: getDataIn1 = op0_rd;
          2'd1: getDataIn1 = op1_rd;
          2'd2: getDataIn1 = op2_rd;
          2'd3: getDataIn1 = op3_rd;
        endcase
      2'd3:
        case (left_shift)
          2'd0: getDataIn1 = op1_rd;
          2'd1: getDataIn1 = op2_rd;
          2'd2: getDataIn1 = op3_rd;
          default: getDataIn1 = 8'bx;
        endcase
		default: getDataIn1 = data_in[23:16];
    endcase
  endfunction

  function [7:0] getDataIn0(input [1:0] sz, input [1:0] shift);
    case (size)
      2'd3:
        case (left_shift)
          2'd0: getDataIn0 = op0_rd;
          2'd1: getDataIn0 = op1_rd;
          2'd2: getDataIn0 = op2_rd;
          2'd3: getDataIn0 = op3_rd;
        endcase
		default: getDataIn0 = data_in[31:24];
    endcase
  endfunction

  wire din_ck = (s4 & rw);
  always @(posedge din_ck) begin
    data_in <= {getDataIn0(size,left_shift), getDataIn1(size,left_shift), getDataIn2(size,left_shift), getDataIn3(size,left_shift)};
  end
  
  wire dout_ck = PI_WR & (PI_A==REG_DATA_LO || PI_A==REG_DATA_HI);
  always @(posedge dout_ck) begin
	 if(PI_A==REG_DATA_LO)
      data_out[15:0] <= PI_D;
    else
      data_out[31:16] <= PI_D;
  end
  

// Dynamic Bus Sizing
/*  always @(posegde s4) begin
    // Table 5-1 for dynamic bus sizing
    case (M68K_DSACK_n)
      2'b11: port_width <= 2'bx; // Unused.
      2'b10: port_width <= 2'd0;
      2'b01: port_width <= 2'd1;
      2'b00: port_width <= 2'd3;
    endcase
  end*/
  function [1:0] getPortWidth(input [1:0] dsack);
    case (M68K_DSACK_n)
        2'b11: getPortWidth = 2'bx; // Unused
        2'b10: getPortWidth = 2'd0;
        2'b01: getPortWidth = 2'd1;
        2'b00: getPortWidth = 2'd3;
    endcase
  endfunction
  assign port_width = getPortWidth(M68K_DSACK_n);


//68K BUS SIDE

// BUS TRANSFER STATE MACHINE
  wire s2rst= s3 | oor;
  wire s3rst= s4 | oor;
  wire s4rst= s7 | oor;
  wire s7rst= s2;
  always @(posedge c14m, posedge s2rst) begin
    if(s2rst)
      s2<=1'd0;
    else if(s7 & op_req & bus_granted)
      s2<=1'd1;
  end
  always @(negedge c14m, posedge s3rst) begin
    if(s3rst)
      s3<=1'd0;
    else if(s2)
      s3<=1'd1;
  end
  always @(posedge c14m, posedge s4rst) begin
    if(s4rst)
      s4<=1'd0;
    else if(s3 && !(&M68K_DSACK_n))
      s4<=1'd1;
  end
  always @(negedge c14m, posedge s7rst) begin
    if(s7rst)
      s7<=1'd0;
    else if(s4 | oor)
      s7<=1'd1;
  end


// 68K OUTPUTS

//	output [23:0]	M68K_A,
// Entering S1, the processor drives a valid address on the address bus.
// As the clock rises at the end of S7, the processor places the address and data buses in the high-impedance state
  assign M68K_A = (!bus_granted | (s7&!op_req)) ? 24'bz : addr; //Z in s7 since it is the state where the Pistorm is waiting

//	inout [32:0]	M68K_D,
// READ : On the falling edge of the clock entering state 7 (S7), the processor latches data from the addressed device
// WRITE : During S3, the data bus is driven out of the high-impedance state as the data to be written is placed on the bus.
// As the clock rises at the end of S7, the processor places the address and data buses in the high-impedance state
  //Table 5-5 for write operation sizing and alignment
  function [31:0] getDataOut(input [1:0] sz, input [1:0] a);
    case (size)
      2'd0: begin
        getDataOut = {op3_wr, op3_wr, op3_wr, op3_wr};
      end
      2'd1: begin
        case (addr[0])
          1'b0: getDataOut = {op2_wr, op3_wr, op2_wr, op3_wr};
          1'b1: getDataOut = {op2_wr, op2_wr, op3_wr, op2_wr};
        endcase
      end
      2'd2: begin
        case (addr[1:0])
          2'd0: getDataOut = {op1_wr, op2_wr, op3_wr, 8'bx};
          2'd1: getDataOut = {op1_wr, op1_wr, op2_wr, op3_wr};
          2'd2: getDataOut = {op1_wr, op2_wr, op1_wr, op2_wr};
          2'd3: getDataOut = {op1_wr, op1_wr, 8'bx, op1_wr};
        endcase
      end
      2'd3: begin
        case (addr[1:0])
          2'd0: getDataOut = {op0_wr, op1_wr, op2_wr, op3_wr};
          2'd1: getDataOut = {op0_wr, op0_wr, op1_wr, op2_wr};
          2'd2: getDataOut = {op0_wr, op1_wr, op0_wr, op1_wr};
          2'd3: getDataOut = {op0_wr, op0_wr, 8'bx, op0_wr};
        endcase
      end
    endcase
  endfunction
  assign M68K_D = bus_granted & !((s7&!op_req)|s2|rw) ? getDataOut(size, addr[1:0]) : 32'bz;

//	output  reg [2:0] M68K_FC,
  assign M68K_FC = bus_granted ? fc[1:0] : 2'bz;

//	output      M68K_AS,
// On the rising edge of S2, the processor asserts AS and drives R/W low.
// On the falling edge of the clock entering S7, the processor negates AS, UDS, or LDS
  assign M68K_AS_n = bus_granted ? ( (s7) ? 1'b1:1'b0 ) : 1'bz;

//	output      M68K_DS,
// READ : On the rising edge of state 2 (S2), the processor asserts AS and UDS, LDS, or DS
// WRITE : At the rising edge of S4, the processor asserts UDS, or LDS // wrong: DS should be set in s3
// On the falling edge of the clock entering S7, the processor negates AS, UDS, or LDS
  assign M68K_DS_n = bus_granted ? ( ((s2&!rw)|s7) ? 1'b1:1'b0 ) : 1'bz;

// output [1:0]   M68K_SIZ,
// The SIZ1 and SIZ0 signals indicate the number of bytes remaining to be transferred
// during an operand cycle (consisting of one or more bus cycles)
// SIZ1 and SIZ0 are valid while AS is asserted
  //Table 5-2
  function [1:0] getSize(input [1:0] sz);
    case (sz)
        2'd0: getSize = 2'b01;
        2'd1: getSize = 2'b10;
        2'd2: getSize = 2'b11;
        2'd3: getSize = 2'b00;
    endcase
  endfunction
  assign M68K_SIZ = bus_granted ? getSize(size) : 2'bz;

//	output      M68K_RW,
// On the rising edge of S2, the processor asserts AS and drives R/W low.
// As the clock rises at the end of S7, the processor drives R/W high
  assign M68K_RW = bus_granted ? ( (rw) ? 1'b1:1'b0 ) : 1'bz;

//	output      M68K_BR,
// indicates to the host processor that our device needs to become the bus master
  assign M68K_BR_n = bus_requested ? 1'b0:1'bz;

//	output      M68K_BGACK,
// indicates that our device has become the bus master
//  assign M68K_BGACK_n = bus_granted ? 1'b0:1'bz;

  assign INT2_n = (bus_granted & int2_out) ? 1'b0 : 1'bz;
  assign INT6_n = (bus_granted & int6_out) ? 1'b0 : 1'bz;

endmodule
