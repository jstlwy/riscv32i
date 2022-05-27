module dff_rst_en (
	output logic q,
	input logic d, 
	input logic clk,
	input logic rst,
	input logic en
);

always_ff @(posedge clk or negedge rst) begin
	if (!rst == 1'b1) begin
		q <= 1'b0;
	end
	else if (en == 1'b1) begin
		q <= d;
	end
end

endmodule