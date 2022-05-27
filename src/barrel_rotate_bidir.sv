module barrel_rotate_bidir #(
	parameter BitWidth
)(
	output logic [BitWidth-1:0] out,
	input logic [BitWidth-1:0] in,
	input logic [$clog2(BitWidth)-1:0] amount,
	input logic left1_right0
);

localparam AmtWidth = $clog2(BitWidth);

logic [BitWidth-1:0] stage [AmtWidth-2:0];
logic [AmtWidth-2:0] s;

always_comb begin
	// Rotate 2, 1, or 0 (depending on direction and amount)
	unique case ({amount[0], left1_right0})
		2'b00   : stage[0] = in;
		2'b01   : stage[0] = {in[1:0], in[BitWidth-1:2]};
		default : stage[0] = {in[0], in[BitWidth-1:1]};
	endcase
end

generate
	genvar i;
	// Rotate 2**i or 0
	for (i = 1; i < AmtWidth; i = i + 1) begin
		assign s[i-1] = amount[i] ^ left1_right0;
		if (i == AmtWidth-1) begin
			assign out = s[i-1] ? {stage[i-1][(2**i)-1:0], stage[i-1][BitWidth-1:(2**i)]} : stage[i-1];	
		end
		else begin
			assign stage[i] = s[i-1] ? {stage[i-1][(2**i)-1:0], stage[i-1][BitWidth-1:(2**i)]} : stage[i-1];
		end
	end
endgenerate

endmodule
