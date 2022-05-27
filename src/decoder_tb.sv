`timescale 1ns/1ps
module decoder_tb ();
integer clk_period = 100;
integer i;

parameter InBitWidth = 5;
parameter OutBitWidth = 2**InBitWidth;

logic [OutBitWidth-1:0] out;
logic [InBitWidth-1:0] in;
decoder #(
		.InBitWidth(InBitWidth)
	)
	proto_dcdr (
		.out(out),
		.in(in)
	);

initial begin
	for(i = 0; i < OutBitWidth; i = i + 1) begin
		in = InBitWidth'(i);
		#clk_period;
	end
end

initial begin
	$monitor("in: %b, out: %b", in, out);
end

endmodule