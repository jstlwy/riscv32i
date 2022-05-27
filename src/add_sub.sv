module add_sub #(
	parameter BitWidth = 64
)(
	output wire [BitWidth-1:0] y,
	output wire cout,
	input wire [BitWidth-1:0] a,
	input wire [BitWidth-1:0] b,
	input wire sub1_add0
);

wire [BitWidth-1:0] b_in, b_neg;
assign b_neg = ~b;
assign b_in = sub1_add0 ? b_neg : b;

add #(
		.BitWidth(BitWidth)
	)
	adder (
		.y(y),
		.cout(cout),
		.a(a),
		.b(b_in),
		.cin(sub1_add0)
	);

endmodule
