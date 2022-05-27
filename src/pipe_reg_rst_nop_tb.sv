`timescale 1ns/1ps
module pipe_reg_rst_nop_tb ();
integer clk_period = 100;
integer clk_half_period = clk_period / 2;

localparam NOP = 32'h0000_0013;
localparam BitWidth = 32;

// Output
logic [BitWidth-1:0] out;
// Input
logic [BitWidth-1:0] in;
logic clk, rst;
	
pipe_reg_rst_nop #(
		.BitWidth(BitWidth)
	)
	pr (
		.out(out),
		.in(in),
		.clk(clk),
		.rst(rst)
	);

bit [BitWidth-1:0] rand_data;

initial begin
	clk = 1'b0;
	forever begin
		#clk_half_period clk = ~clk;
	end
end

always @(negedge clk) begin
	void'(std::randomize(rand_data));
	in = rand_data;
end

initial begin
	rst = 1'b0;
	repeat (5) @(posedge clk);
	rst = 1'b1;
	repeat (5) @(posedge clk);
	$finish(1);
end

always @(posedge clk) begin
	$write("rst = %b, in = %h, out = %h\n", rst, in, out);
end

endmodule
