`timescale 1ns/1ps
module regfile_tb ();
integer clk_period = 100;
integer clk_half_period = clk_period / 2;
integer i, j;

localparam BitWidth = 64;
localparam NumReg = 32;
localparam RegSelWidth = $clog2(NumReg);
localparam NumReadPorts = 2;

// Output
logic [BitWidth-1:0] read_data [NumReadPorts-1:0];
// Input
logic [RegSelWidth-1:0] read_src [1:0];
logic [RegSelWidth-1:0] write_dest;
logic [BitWidth-1:0] write_data;
logic write_en;
logic rst;

regfile #(
		.BitWidth(BitWidth),
		.NumReg(NumReg),
		.NumReadPorts(NumReadPorts)
	)
	rf (
		.read_data(read_data),
		.read_src(read_src),
		.write_data(write_data),
		.write_dest(write_dest),
		.write_en(write_en),
		.rst(rst)
	);

bit [BitWidth-1:0] random_data;

initial begin
	rst = 1'b0;
	repeat (5) #clk_period;
	rst = 1'b1;
	$write("All registers have been reset.\n");
	write_en = 1'b1;
	for (i = 1; i < NumReg; i++) begin
		write_dest = RegSelWidth'(i);
		void'(std::randomize(random_data));
		write_data = random_data;
		repeat (5) #clk_period;
		$write("Register x%0d = %h\n", write_dest, write_data);
	end
	write_en = 1'b0;
	$write("\n");
	for (i = 0; i < NumReg; i++) begin
		for (j = 0; j < NumReadPorts; j++) begin
			read_src[j] = RegSelWidth'(i);
			repeat (5) #clk_period;
			$write("Read Port %0d: source = x%0d, data = %h\n", j, read_src[j], read_data[j]);
		end
	end
end

endmodule
