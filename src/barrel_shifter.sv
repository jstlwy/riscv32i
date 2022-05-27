module barrel_shifter #(
	parameter BitWidth
)(
	output logic [BitWidth-1:0] out,
	input logic [BitWidth-1:0] in,
	input logic [$clog2(BitWidth)-1:0] amount,
	input logic arith1_logic0,
	input logic left1_right0,
	input logic shift1_rotate0
);

logic [BitWidth-1:0] rotator_out;

barrel_rotate_bidir #(
		.BitWidth(BitWidth)
	)
	br (
		.out(rotator_out),
		.in(in),
		.amount(amount),
		.left1_right0(left1_right0)
	);

barrel_masker #(
		.BitWidth(BitWidth)
	)
	bm (
		.out(out),
		.in(rotator_out),
		.amount(amount),
		.sign(in[BitWidth-1]),
		.arith1_logic0(arith1_logic0),
		.left1_right0(left1_right0),
		.shift1_rotate0(shift1_rotate0)
	);

endmodule
