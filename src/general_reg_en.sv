module general_reg_en #(
	parameter BitWidth = 32
)(
	output wire [BitWidth-1:0] out,
	input wire [BitWidth-1:0] in,
	input wire clk,
	input wire en
);

genvar i;
generate
	for (i = 0; i < BitWidth; i++) begin : create_flops
		dff_en dff_i (
			.q(out[i]),
			.d(in[i]),
			.clk(clk),
			.en(en)
		);
	end
endgenerate

endmodule
