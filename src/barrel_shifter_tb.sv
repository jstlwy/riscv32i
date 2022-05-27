`timescale 1ns/1ps
module barrel_shifter_tb();
integer clk_period = 100;
integer i;

localparam BitWidth = 32;
localparam log_bw = $clog2(BitWidth);

logic [BitWidth-1:0] out;
logic [BitWidth-1:0] in;
logic [log_bw-1:0] amount;
logic arith1_logic0, left1_right0, shift1_rotate0;

barrel_shifter #(
		.BitWidth(BitWidth)
	)
	bs (
		.out(out),
		.in(in),
		.amount(amount),
		.arith1_logic0(arith1_logic0),
		.left1_right0(left1_right0),
		.shift1_rotate0(shift1_rotate0)
	);

initial begin
	in = BitWidth'(15);
	left1_right0 = 1'b0;
	shift1_rotate0 = 1'b0;
	$write("RIGHT ROTATE\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		arith1_logic0 = 1'b0;
		#clk_period;
		arith1_logic0 = 1'b1;
		#clk_period;
	end

	left1_right0 = 1'b1;
	$write("\nLEFT ROTATE\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		arith1_logic0 = 1'b0;
		#clk_period;
		arith1_logic0 = 1'b1;
		#clk_period;
	end
	
	arith1_logic0 = 1'b1;
	left1_right0 = 1'b0;
	shift1_rotate0 = 1'b1;
	in = BitWidth'((2**(BitWidth-1)) + (2**(BitWidth-3)));
	$write("\nARITHMETIC RIGHT SHIFT\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		#clk_period;
	end

	arith1_logic0 = 1'b0;
	$write("\nLOGICAL RIGHT SHIFT\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		#clk_period;
	end


	left1_right0 = 1'b1;
	in = BitWidth'(10);
	$write("\nLEFT SHIFT\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		arith1_logic0 = 1'b0;
		#clk_period;
		arith1_logic0 = 1'b1;
		#clk_period;
	end
end

initial begin
	$monitor("amount: %d, arith1logic0: %b, %b --> %b", amount, arith1_logic0, in, out);
end

endmodule