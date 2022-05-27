`timescale 1ns/1ps
module dff_rst_hi_tb ();
integer clk_period = 100;
integer clk_half_period = clk_period / 2;

logic q, d, clk, rst;
dff_rst_hi proto_dffrh (	
	.q(q),  
	.d(d), 
	.clk(clk),
	.rst(rst)
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
	repeat(5) #clk_period;
	rst = 1'b0;
	repeat(5) #clk_period;
	rst = 1'b1;
	repeat(5) #clk_period;
	$finish(1);
end

always @(posedge clk) begin
	$write("rst = %b, d = %b, q = %b\n", rst, d, q);
end

endmodule