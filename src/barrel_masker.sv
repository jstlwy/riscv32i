module barrel_masker #(
	parameter BitWidth
)(
	output logic [BitWidth-1:0] out,
	input logic [BitWidth-1:0] in,
	input logic [$clog2(BitWidth)-1:0] amount,
	input logic sign,
	input logic arith1_logic0,
	input logic left1_right0,
	input logic shift1_rotate0
);

localparam AmtWidth = $clog2(BitWidth);
logic [BitWidth-1:0] right_mask;
thermometer_decoder #(
		.InBitWidth(AmtWidth)
	)
	td (
		.out(right_mask),
		.in(amount)
	);

logic is_right_shift, is_left_shift, sign_ext;
assign is_right_shift = (~left1_right0) & shift1_rotate0;
assign is_left_shift = left1_right0 & shift1_rotate0;
assign sign_ext = sign & arith1_logic0;

logic [BitWidth-1:0] rs_rm;
logic [BitWidth-1:0] ls_rmr;
logic [BitWidth-1:0] kill_x;
logic [BitWidth-1:0] sa_rm;

generate
	genvar i;
	for (i = 0; i < BitWidth; i = i + 1) begin : define_output
		assign rs_rm[i] = ~(is_right_shift & right_mask[i]);
		assign ls_rmr[i] = ~(is_left_shift & right_mask[BitWidth-1-i]);
		assign kill_x[i] = (~rs_rm[i]) | (~ls_rmr[i]);
		assign sa_rm[i] = ~(sign_ext & right_mask[i]);
		assign out[i] = ((~kill_x[i]) & in[i]) | (~sa_rm[i]);
	end
endgenerate

endmodule
