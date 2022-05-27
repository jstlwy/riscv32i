`include "definitions.svh"
import definitions::*;

module data_mem_rv64 #(
	parameter AddrWidth = 14
)(
	output reg [63:0] read_data,
	input wire [AddrWidth-1:0] addr,
	input wire [63:0] write_data,
	input wire write_en,
	input wire [2:0] funct3
);

localparam NumEntries = 2**AddrWidth;
reg [7:0] mem [NumEntries-1:0];

always_comb begin
	if (write_en == 1'b1) begin
		case (funct3)
			F3_SB	: mem[addr] = write_data[7:0];
			F3_SH	: {mem[addr+1], mem[addr]} = write_data[15:0];
			F3_SW	: {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]} = write_data[31:0];
			F3_SD	: {mem[addr+7], mem[addr+6], mem[addr+5], mem[addr+4], mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]} = write_data[63:0];
			default	: mem[addr] = mem[addr];
		endcase
	end
end

always_comb begin
	case (funct3)
		F3_LB	: read_data = {{56{mem[addr][7]}}, mem[addr]};
		F3_LH	: read_data = {{48{mem[addr+1][7]}}, mem[addr+1], mem[addr]};
		F3_LW	: read_data = {{32{mem[addr+3][7]}}, mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
		F3_LD	: read_data = {mem[addr+7], mem[addr+6], mem[addr+5], mem[addr+4], mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
		F3_LBU	: read_data = {56'd0, mem[addr]};
		F3_LHU	: read_data = {48'd0, mem[addr+1], mem[addr]};
		F3_LWU	: read_data = {32'd0, mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
		default	: read_data = 64'd0;
	endcase
end

endmodule
