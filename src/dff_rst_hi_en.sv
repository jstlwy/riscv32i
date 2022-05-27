module dff_rst_hi_en (
	output logic q,
	input logic d, 
	input logic clk,
	input logic rst,	// Asynchronous active low
	input logic en
);

always_ff @(posedge clk or negedge rst) begin
	if (!rst == 1'b1) begin
		q <= 1'b1;
	end
	else if (en == 1'b1) begin
		q <= d;
	end
	else begin
		q <= q;
	end
end

endmodule
