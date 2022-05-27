`timescale 1ns/1ps
module barrel_masker_tb ();
integer clk_period = 100;
integer i;

localparam BitWidth = 32;
localparam log_bw = $clog2(BitWidth);

logic [BitWidth-1:0] out, in;
logic [log_bw-1:0] amount;
logic sign, arith1_logic0, left1_right0, shift1_rotate0;
barrel_masker #(
		.BitWidth(BitWidth)
	)
	bm (
		.out(out),
		.in(in),
		.amount(amount),
		.sign(sign),
		.arith1_logic0(arith1_logic0),
		.left1_right0(left1_right0),
		.shift1_rotate0(shift1_rotate0)
	);

initial begin
	void'(std::randomize(in));
	$write("INPUT: %b\n", in);
	sign = 1'b1;
	
	left1_right0 = 1'b0;
	shift1_rotate0 = 1'b0;
	$write("\nRIGHT ROTATE\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		arith1_logic0 = 1'b0;
		#clk_period;
		arith1_logic0 = 1'b1;
		#clk_period;
	end
	$write("END RIGHT ROTATE\n");
	
	left1_right0 = 1'b1;
	$write("\nLEFT ROTATE\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		arith1_logic0 = 1'b0;
		#clk_period;
		arith1_logic0 = 1'b1;
		#clk_period;
	end
	$write("END LEFT ROTATE\n");
	
	arith1_logic0 = 1'b1;
	left1_right0 = 1'b0;
	shift1_rotate0 = 1'b1;
	$write("\nARITHMETIC RIGHT SHIFT\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		sign = 1'b0;
		#clk_period;
		sign = 1'b1;
		#clk_period;
	end
	$write("END ARITHMETIC RIGHT SHIFT\n");
	
	arith1_logic0 = 1'b0;
	sign = 1'b1;
	$write("\nLOGICAL RIGHT SHIFT\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		#clk_period;
	end
	$write("END LOGICAL RIGHT SHIFT\n");
	
	left1_right0 = 1'b1;
	$write("\nLEFT SHIFT\n");
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		arith1_logic0 = 1'b0;
		#clk_period;
		arith1_logic0 = 1'b1;
		#clk_period;
	end
	$write("END LEFT SHIFT\n");
end

initial begin
	$monitor("arith: %b, left: %b, shift: %b, sign: %b, amount: %d, out: %b", arith1_logic0, left1_right0, shift1_rotate0, sign, amount, out);
end

endmodule