module dff_rst (
	output logic q,  
	input logic d, 
	input logic clk,
	input logic rst
);

always_ff @(posedge clk) begin
	if (!rst == 1'b1) begin
		q <= 1'b0;
	end
	else begin
		q <= d;
	end
end

endmodule