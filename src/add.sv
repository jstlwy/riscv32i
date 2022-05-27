module add #(
	parameter BitWidth = 64
)(
	output wire [BitWidth-1:0] y,
	output wire cout,
	input wire [BitWidth-1:0] a,
	input wire [BitWidth-1:0] b,
	input wire cin
);

localparam SumWidth = BitWidth + 1;

wire [SumWidth-1:0] sum;

assign sum = SumWidth'(a) + SumWidth'(b) + SumWidth'(cin);
assign y = sum[BitWidth-1:0];
assign cout = sum[SumWidth-1];

endmodule
