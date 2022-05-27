module pipe_reg_rst_nop #(
	parameter BitWidth = 32
)(
	output wire [BitWidth-1:0] out,
	input wire [BitWidth-1:0] in,
	input wire clk,
	input wire rst
);

// NOP = 32'h0000_0013
// NOP = 32'b0000_0000_0000_0000_0000_0000_0001_0011

genvar i;
generate
	for (i = 0; i < BitWidth; i++) begin : create_flops
		if ((i < 2) || (i == 4)) begin
			dff_rst_hi dff_i (
				.q(out[i]),
				.d(in[i]),
				.clk(clk),
				.rst(rst)
			);
		end
		else begin
			dff_rst dff_i (
				.q(out[i]),
				.d(in[i]),
				.clk(clk),
				.rst(rst)
			);
		end
	end
endgenerate

endmodule
