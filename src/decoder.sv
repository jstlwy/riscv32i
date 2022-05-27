module decoder #(	
	parameter InBitWidth
)(	
	output logic [(2**InBitWidth)-1:0] out,
	input logic [InBitWidth-1:0] in
);

localparam OutBitWidth = 2**InBitWidth;

always_comb begin
	out = OutBitWidth'(0);
	out[in] = 1'b1;
end

endmodule