`timescale 1ns/1ps
module barrel_rotate_bidir_tb();
integer clk_period = 100;
integer i;

localparam BitWidth = 32;
localparam log_bw = $clog2(BitWidth);

logic [BitWidth-1:0] out, in;
logic [log_bw-1:0] amount;
logic left1_right0;

barrel_rotate_bidir #(
		.BitWidth(BitWidth)
	)
	proto_br (
		.out(out),
		.in(in),
		.amount(amount),
		.left1_right0(left1_right0)
	);

initial begin
	in = BitWidth'(15);
	$write("in: %b\n", in);
	
	// Right rotate
	$write("RIGHT ROTATE\n");
	left1_right0 = 1'b0;
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		#clk_period;
	end
	// Left rotate
	$write("LEFT ROTATE\n");
	left1_right0 = 1'b1;
	for(i = 0; i < BitWidth; i = i + 1) begin
		amount = log_bw'(i);
		#clk_period;
	end
end

initial begin
	$monitor("amount: %d, out: %b", amount, out);
end

endmodule