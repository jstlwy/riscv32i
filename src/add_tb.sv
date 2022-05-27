`timescale 1ns/1ps
module add_tb (); 
integer clk_period = 100;
integer i;

localparam BitWidth = 8;

// Output
logic [BitWidth-1:0] y;
logic cout;
// Input
logic [BitWidth-1:0] a, b;
logic cin;

add #(
		.BitWidth(BitWidth)
	)
	proto_adder (
		.y(y),
		.cout(cout),
		.a(a),
		.b(b),
		.cin(cin)
	);

initial begin
	cin = 1'b1;
	b = BitWidth'(0);
	for (i = 0; i < 16; i++) begin
		a = BitWidth'(i);
		#clk_period;
	end
	for (i = 0; i < 16; i++) begin
		b = BitWidth'(i);
		#clk_period;
	end
end

initial begin
	$monitor("cin = %b, a = %0d, b = %0d, y = %0d, cout = %b", cin, a, b, y, cout);
end

endmodule
