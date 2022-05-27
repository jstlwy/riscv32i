`timescale 1ns/1ps
module dff_rst_hi_en_tb ();
integer clk_period = 100;
integer clk_half_period = clk_period / 2;

logic q, d, clk, rst, en;
dff_rst_hi_en proto_dffrhe (
	.q(q),
	.d(d),
	.clk(clk),
	.rst(rst),
	.en(en)
);

bit rand_bit;

initial begin
	clk = 1'b0;
	forever begin
		#clk_half_period clk = 1'b0;
		#clk_half_period clk = 1'b1;
	end
end

always @(negedge clk) begin
	void'(std::randomize(rand_bit));
	d = rand_bit;
end

initial begin
	rst = 1'b1;
	en = 1'b0;
	$write("ENABLE OFF\n");
	repeat(5) @(posedge clk);
	en = 1'b1;
	$write("ENABLE ON\n");
	repeat(5) @(posedge clk);
	rst = 1'b0;
	$write("RESET\n");
	repeat(5) @(posedge clk);
	rst = 1'b1;
	$write("RESET FINISHED\n");
	repeat(5) @(posedge clk);
	$finish(1);
end

always @(posedge clk) begin
	$write("rst = %b, en = %b, d = %b, q = %b\n", rst, en, d, q);
end

endmodule