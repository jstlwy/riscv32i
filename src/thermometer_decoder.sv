module thermometer_decoder #(
	parameter InBitWidth
)(
	output logic [(2**InBitWidth)-1:0] out,
	input logic [InBitWidth-1:0] in
);

localparam OutBitWidth = 2**InBitWidth;
logic [OutBitWidth-1:0] dcd_out;

decoder #(
		.InBitWidth(InBitWidth)
	)
	dcd (
		.out(dcd_out),
		.in(in)
	);

assign out[0] = 1'b0;
assign out[1] = dcd_out[OutBitWidth-1];

generate
	genvar i;
	for (i = 2; i < OutBitWidth; i = i + 1) begin
		assign out[i] = |dcd_out[OutBitWidth-1:OutBitWidth-i];
	end
endgenerate

endmodule
