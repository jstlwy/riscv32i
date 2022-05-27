module instr_mem #(
	parameter InstrWidth = 32,
	parameter EntryWidth = 8,
	parameter AddrWidth = 14
)(
	output wire [InstrWidth-1:0] instr,
	input wire [AddrWidth-1:0] addr
);

integer i;

reg [EntryWidth-1:0] mem [(2**AddrWidth)-1:0];

always_comb begin
	// Clear all memory (temp solution)
	for (i = 0; i < 2**AddrWidth; i++) begin
		mem[i] = EntryWidth'(0);
	end
end

assign instr = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};

endmodule
