
module ram_autoconfig(
	input [23:16] AH,
	input [6:1] AL,
	input [15:13] D_i,
	input _RST,
	input _UDS,
	input RW,
	input _configin,
	output _configout,
	output [15:12] D_o,
	output config_oe,
	output DTACK, //positive logic here !
	output ramce
	);
	
//autoconfig
	(* PWR_MODE = "LOW" *) reg configured = 1'b0;
	(* PWR_MODE = "LOW" *) reg shutup = 1'b0;
	(* PWR_MODE = "LOW" *) reg [23:21] base_address;
	wire autoconfig_access = (AH[23:16] == 8'hE8) & !configured & !shutup & !_configin; //accessing autoconfig space
	wire autoconfig_read = autoconfig_access & RW;
	wire autoconfig_write = autoconfig_access & !RW;

	function [3:0] autoconfig_f(input [5:0] adr);
		case (adr)
			'h00: autoconfig_f = 4'b1110; // $00 : Current style board, load into memory free list
			'h01: autoconfig_f = 4'b0110; // $02 : 0110 for 2MB, 0111 for 4MB, 0000 for 8MB
			'h02: autoconfig_f = 4'hC; // $04 : Product number
			'h03: autoconfig_f = 4'hF; // $06 : Product number
			'h04: autoconfig_f = 4'h7; // $08 : Can be shut up, in 8Meg space
//			'h0a: autoconfig_f = 4'hF; // $0a : reserved
			'h08: autoconfig_f = 4'hA; // $10 : Mfg # high byte
			'h09: autoconfig_f = 4'hF; // $12 : Mfg # high byte
			'h0a: autoconfig_f = 4'hF; // $14 : Mfg # low byte
			'h0b: autoconfig_f = 4'hF; // $16 : Mfg # low byte
//			'h11: autoconfig_f = 4'he; // $22 : serial number
//			'h12: autoconfig_f = 4'hb; // $24 : serial number
//			'h13: autoconfig_f = 4'h7; // $26 : serial number
			'h20: autoconfig_f = 4'h0; // $40 : Control status register
			'h21: autoconfig_f = 4'h0; // $42 : Control status register
			default: autoconfig_f = 4'hF;
		endcase
	endfunction

always @(negedge _UDS or negedge _RST) begin
	if (!_RST) begin
		configured <= 1'b0;
		shutup <= 1'b0;
	end else begin
		if (autoconfig_write) begin
			case ( AL[6:1] )
				'h24: begin // $48 : Base address register, upper half
						base_address[23:21] <= D_i[15:13]; //use only the 3 upper bits
						configured <= 1'b1;
					end
				//'h25: base_address[19:16] <= D[15:12]; // $4a  : Base address register, lower half
				'h26: shutup <= 1'b1; // $4c : Optional "shut up" address
			endcase
		end
	end
end

//response from our device
	assign D_o[15:12] = autoconfig_f(AL[6:1]); //autoconfig data
	assign config_oe = autoconfig_read; //autoconfig data output enable
	assign _configout = !(configured | shutup); //autoconfig chain
	assign ramce = configured & (AH[23:21]==base_address[23:21]); //ram chip enable
	assign DTACK = autoconfig_access | ramce; //68K DTACK, positive logic here !

endmodule
