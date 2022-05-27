`timescale 1ns/1ps
module thermometer_decoder_tb ();
integer clk_period = 100;
integer i;

localparam InBitWidth = 5;
localparam OutBitWidth = 2**InBitWidth;

logic [OutBitWidth-1:0] out;
logic [InBitWidth-1:0] in;
thermometer_decoder #(
		.InBitWidth(InBitWidth)
	)
	td (
		.out(out),
		.in(in)
	);

initial begin
	for (i = 0; i < OutBitWidth; i = i + 1) begin
		in = InBitWidth'(i);
		#clk_period;
	end
end

initial begin
	$monitor("in = %d, out = %b", in, out);
end

endmodule
