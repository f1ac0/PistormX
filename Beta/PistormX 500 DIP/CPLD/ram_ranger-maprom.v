
module ram_rangermaprom(
	input [23:12] AH,
//	input [6:1] AL,
	input [15:13] D_i,
	input _RST,
	input _UDS,
	input RW,
//	input _configin,
//	output _configout,
	output [15:12] D_o,
	output config_oe,
	output OVR, //positive logic here !
	output DTACK, //positive logic here !
	output ram1ce,
//	output ram2ce
	input rst_maprom_rst,
	input rst_maprom_off
	);

//maprom
	reg [1:0] maprom_written = 2'b0;
	reg maprom_on = 1'b0;
	wire ram9_range = ( AH[23:20]==4'b1100 | AH[23:19]==5'b11010 ); //C00000-D7FFFF, 1.5M
	wire rom9_range = ( AH[23:19]==5'b11111 ); //F80000-FFFFFF, .5M
	wire maprom_write = rom9_range & !RW & !maprom_on; //write protect when active
	wire maprom_read = rom9_range & maprom_on;

//control register
	wire control_access = AH[23:12] == 12'hE9C;
	wire control_read = control_access & RW;
	wire control_write = control_access & !RW;
	wire [3:0] control_d = {maprom_on, 1'b1, &(maprom_written), 1'b1};

//control commands and mode/maprom activation
	// maprom set = when ROM written
	// maprom reset = write in control or 6s reset
	wire maprom_rst = !_UDS & control_write & !D_i[15] | rst_maprom_rst;
	always @(negedge _UDS or posedge maprom_rst)
	begin
		if(maprom_rst) begin
			maprom_written <= 2'b0;
		end else	begin
			if( maprom_write ) begin // maprom write
				if(~&(maprom_written)) //sample multiple writes otherwise false positives during power up
					maprom_written <= maprom_written+1;
			end
		end
	end
	//maprom activate at reset
	//maprom deactivate at 3s reset
	always @(negedge _RST or posedge rst_maprom_off) begin
		if(rst_maprom_off)
			maprom_on <= 0;
		else
			maprom_on <= &(maprom_written);
	end

//response from our device
	assign D_o[15:12] = control_read ? {control_d} : 4'bzzzz; //control registers
	assign config_oe = control_read;
	assign ram1ce = ram9_range | maprom_write | maprom_read; //Lower 2MB
	assign OVR = (ram9_range | maprom_write | maprom_read | control_access); //chipset override, positive logic here !
	assign DTACK = control_access | ram1ce; // | ram2ce;

endmodule
