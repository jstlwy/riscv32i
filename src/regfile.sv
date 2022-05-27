module regfile #(
	parameter BitWidth = 64,
	parameter NumReg = 32,
	parameter NumReadPorts = 2
)(
	output wire [BitWidth-1:0] read_data [NumReadPorts-1:0],
	input wire [$clog2(NumReg)-1:0] read_src [NumReadPorts-1:0],
	input wire [BitWidth-1:0] write_data,
	input wire [$clog2(NumReg)-1:0] write_dest,
	input wire write_en,
	input wire rst
);

localparam RegSelWidth = $clog2(NumReg);

// Convert write address to one hot
wire [NumReg-1:0] write_dest_onehot;
decoder #(
		.InBitWidth(RegSelWidth)
	)
	write_dest_dcd (
		.out(write_dest_onehot),
		.in(write_dest)
	);

wire [BitWidth-1:0] xreg_out [NumReg-1:0];
wire [NumReg-1:1] xreg_en;

// RISC-V register x0 always outputs 0.
assign xreg_out[0] = BitWidth'(0);

genvar i, j;
generate
	// Instantiate registers x1 through xi
	for (i = 1; i < NumReg; i++) begin : create_reg
		assign xreg_en[i] = write_en & write_dest_onehot[i];
		for (j = 0; j < BitWidth; j++) begin : create_bits
			dff_rst dff_j (
				.q(xreg_out[i][j]),
				.d(write_data[j]),
				.clk(xreg_en[i]),
				.rst(rst)
			);
		end
	end
	
	// Instantiate muxes for read ports
	for (i = 0; i < NumReadPorts; i++) begin : create_read_muxes
		mux_assign #(
				.SelBitWidth(RegSelWidth),
				.DataBitWidth(BitWidth)
			)
			read_mux_i (
				.out(read_data[i]),
				.in(xreg_out),
				.sel(read_src[i])
			);
	end
endgenerate

endmodule
