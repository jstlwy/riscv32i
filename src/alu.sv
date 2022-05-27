`include "definitions.svh"
import definitions::*;

module alu #(
	parameter BitWidth = 32
)(
	output reg [BitWidth-1:0] y,
	input wire [BitWidth-1:0] a,
	input wire [BitWidth-1:0] b,
	input wire [4:0] opcode,
	input wire [2:0] funct3,
	input wire funct7_b5
);

localparam ShiftAmt = $clog2(BitWidth);

wire [BitWidth-1:0] b_ext;
assign b_ext = {{(BitWidth-12){b[11]}}, b[11:0]};

wire is_imm_instr;
assign is_imm_instr = (opcode[3] == 1'b0);

wire [BitWidth-1:0] b_in;
assign b_in = is_imm_instr ? b_ext : b;

wire [BitWidth-1:0] adder_out;
wire cout;
add_sub #(
		.BitWidth(BitWidth)
	)
	adder (
		.y(adder_out),
		.cout(cout),
		.a(a),
		.b(b_in),
		.sub1_add0(funct7_b5)
	);

wire [BitWidth-1:0] shifter_out;
wire left1_right0;
assign left1_right0 = (funct3 == F3_SRL_SRA);
barrel_shifter #(
		.BitWidth(BitWidth)
	)
	shifter (
		.out(shifter_out),
		.in(a),
		.amount(b[ShiftAmt-1:0]),
		.arith1_logic0(funct7_b5),
		.left1_right0(left1_right0),
		.shift1_rotate0(1'b1)
	);

wire is_less_than;
assign is_less_than = (funct3 == F3_SLT) ? ($signed(a) < $signed(b_in)) : (a < b_in);
wire [BitWidth-1:0] less_than_out;
assign less_than_out = {{(BitWidth-1){1'b0}}, is_less_than};

always_comb begin
	case (funct3)
		F3_ADD_SUB 	: y = adder_out;
		F3_SLL 		: y = shifter_out;
		F3_SLT 		: y = less_than_out;
		F3_SLTU 	: y = less_than_out;
		F3_XOR 		: y = a ^ b_in;
		F3_SRL_SRA 	: y = shifter_out;
		F3_OR 		: y = a | b_in;
		F3_AND 		: y = a & b_in;
		default 	: y = BitWidth'(0);
	endcase
end

endmodule
