`include "definitions.svh"
import definitions::*;

// USING "PREDICT NOT TAKEN" LOGIC
module rv32i #(
	parameter IMemCacheLen = 8192,
	parameter DMemCacheLen = 8192
)(
	input wire clk,
	input wire rst
);

genvar i;

localparam DataWidth = 32;
localparam NumReg = 32;
localparam InstrWidth = 32;
localparam MemEntryWidth = 8;
localparam IMemAddrWidth = $clog2(IMemCacheLen);
localparam RemPCWidth = DataWidth - 12;
localparam DMemAddrWidth = $clog2(DMemCacheLen);


// ==================================================
// REGISTER INPUTS AND OUTPUTS
// PC
wire [DataWidth-1:0] branch_offset;
wire [DataWidth-1:0] pc_inc_in, pc_inc_out, branch_adder_out;
wire [DataWidth-1:0] pc_in, pc_out;
// IF/ID
wire [InstrWidth-1:0] ifid_in, ifid_out;
// ID/EX
wire [InstrWidth-1:0] idex_out;
wire [DataWidth-1:0] idex_a_out, idex_b_out;
// EX/MEM
wire [InstrWidth-1:0] exmem_out;
wire [DataWidth-1:0] exmem_b_out, exmem_alu_out;
// MEM/WB
wire [InstrWidth-1:0] memwb_out;
reg [DataWidth-1:0] MEMWBValue;


// ==================================================
// STAGE WIRING
// IF
wire [InstrWidth-1:0] imem_out;
// ID
wire [6:0] ifid_op;
wire [4:0] rf_src [1:0];
wire [DataWidth-1:0] rf_out [1:0];
wire write_reg_en;
// EX
wire [6:0] idex_op;
wire [2:0] idex_funct3;
wire [6:0] idex_funct7;
wire [4:0] idex_rs1, idex_rs2;
reg [DataWidth-1:0] alu_a, alu_b_ari, ex_out;
wire [DataWidth-1:0] alu_b_imm, alu_b, alu_out;
// MEM
wire [6:0] exmem_op;
wire [4:0] exmem_rd;
wire [2:0] exmem_funct3;
wire [InstrWidth-1:0] dmem_out;
// WB
wire [6:0] memwb_op;
wire [4:0] memwb_rd;
wire write_data_en;


// ==================================================
// CONTROL SIGNALS
// 
wire exmem_op_is_ari_r, memwb_op_is_ari_r, memwb_op_is_load;
assign exmem_op_is_ari_r = (exmem_op[6:2] == OP_ARI_R) || (exmem_op[6:2] == OP_ARI_R_W);
assign memwb_op_is_ari_r = (memwb_op[6:2] == OP_ARI_R) || (memwb_op[6:2] == OP_ARI_R_W);
assign memwb_op_is_load = (memwb_op[6:2] == OP_LOAD);
// ALU bypass logic
wire take_a_from_mem, take_a_from_wb;
wire take_b_from_mem, take_b_from_wb;
// Stalling
wire stall;
// Branching: if opcode is BRANCH and rs1 == rs2
wire take_branch;
assign take_branch = (ifid_op[6:2] == OP_BRANCH) && (rf_out[0] == rf_out[1]);




// PC REGISTER
// a taken branch is in ID; instruction in IF is wrong; insert a NOP and reset the PC
assign pc_inc_in = DataWidth'(4);
assign branch_offset = {{RemPCWidth{ifid_out[31]}}, ifid_out[7], ifid_out[30:25], ifid_out[11:8], 2'b0};
assign pc_in = take_branch ? branch_adder_out : pc_inc_out;

add #(
		.BitWidth(DataWidth)
	)
	pc_incrementer (
		.y(pc_inc_out),
		.cout(),
		.a(pc_out),
		.b(pc_inc_in),
		.cin(1'b0)
	);

add #(
		.BitWidth(DataWidth)
	)
	branch_adder (
		.y(branch_adder_out),
		.cout(),
		.a(pc_out),
		.b(branch_offset),
		.cin(1'b0)
	);

general_reg_rst_en #(
		.BitWidth(DataWidth)
	)
	pc (
		.out(pc_out),
		.in(pc_in),
		.clk(clk),
		.rst(rst),
		.en(~stall)
	);



// IF STAGE
instr_mem #(
		.InstrWidth(InstrWidth),
		.EntryWidth(MemEntryWidth),
		.AddrWidth(IMemAddrWidth)
	)
	imem (
		.instr(imem_out),
		.addr(pc_out[IMemAddrWidth-1:0])
	);



// IF/ID PIPELINE REGISTER
// a taken branch is in ID; instruction in IF is wrong; insert a NOP and reset the PC
assign ifid_in = take_branch ? NOP : imem_out;
pipe_reg_rst_nop_en #(
		.BitWidth(InstrWidth)
	)
	ifid (
		.out(ifid_out),
		.in(ifid_in),
		.clk(clk),
		.rst(rst),
		.en(~stall)
	);



// ID STAGE
assign ifid_op = ifid_out[6:0];
assign rf_src[0] = ifid_out[19:15]; // rs1
assign rf_src[1] = ifid_out[24:20]; // rs2
regfile #(
		.BitWidth(DataWidth),
		.NumReg(NumReg),
		.NumReadPorts(2)
	)
	rf (
		.read_data(rf_out),
		.read_src(rf_src),
		.write_data(MEMWBValue),
		.write_dest(memwb_rd),
		.write_en(write_reg_en),
		.rst(rst)
	);



// ID/EX PIPELINE REGISTER
pipe_reg_rst_nop_en #(
		.BitWidth(InstrWidth)
	)
	idex (
		.out(idex_out),
		.in(ifid_out),
		.clk(clk),
		.rst(rst),
		.en(~stall)
	);

general_reg_en #(
		.BitWidth(DataWidth)
	)
	idex_a (
		.out(idex_a_out),
		.in(rf_out[0]),
		.clk(clk),
		.en(~stall)
	);

general_reg_en #(
		.BitWidth(DataWidth)
	)
	idex_b (
		.out(idex_b_out),
		.in(rf_out[1]),
		.clk(clk),
		.en(~stall)
	);



// EX STAGE
assign idex_op = idex_out[6:0];
assign idex_funct3 = idex_out[14:12];
assign idex_funct7 = idex_out[31:25];
assign idex_rs1 = idex_out[19:15];
assign idex_rs2 = idex_out[24:20];
assign alu_b_imm = {{(DataWidth-12){idex_out[31]}}, idex_out[31:20]};

// ALU A input
assign take_a_from_mem = (idex_rs1 == exmem_rd) && (idex_rs1 != 5'd0) && exmem_op_is_ari_r;
assign take_a_from_wb = (idex_rs1 == memwb_rd) && (idex_rs1 != 5'd0) && (memwb_op_is_ari_r || memwb_op_is_load);
always_comb begin
	priority case (1'b1)
		take_a_from_mem : alu_a = exmem_alu_out;
		take_a_from_wb	: alu_a = MEMWBValue;
		default 		: alu_a = idex_a_out;
	endcase
end

// ALU B INPUT
assign take_b_from_mem = (exmem_rd == idex_rs2) && (idex_rs2 != 5'd0) && exmem_op_is_ari_r;
assign take_b_from_wb = (memwb_rd == idex_rs2) && (idex_rs2 != 5'd0) && (memwb_op_is_ari_r || memwb_op_is_load);
always_comb begin
	priority case (1'b1)
		take_b_from_mem : alu_b_ari = exmem_alu_out;
		take_b_from_wb	: alu_b_ari = MEMWBValue;
		default			: alu_b_ari = idex_b_out;
	endcase
end

assign alu_b = (idex_op[5] == 1'b1) ? alu_b_ari : alu_b_imm;

alu #(
		.BitWidth(DataWidth)
	)
	alu0 (
		.y(alu_out),
		.a(alu_a),
		.b(alu_b),
		.funct3(idex_funct3),
		.funct7_b5(idex_funct7[5])
	);



// EX/MEM PIPELINE REGISTER
pipe_reg_rst_nop_en #(
		.BitWidth(InstrWidth)
	)
	exmem (
		.out(exmem_out),
		.in(idex_out),
		.clk(clk),
		.rst(rst),
		.en(~stall)
	);

general_reg_en #(
		.BitWidth(DataWidth)
	)
	exmem_b (
		.out(exmem_b_out),
		.in(idex_b_out),
		.clk(clk),
		.en(~stall)
	);
	
general_reg_en #(
		.BitWidth(DataWidth)
	)
	exmem_alu (
		.out(exmem_alu_out),
		.in(alu_out),
		.clk(clk),
		.en(~stall)
	);



// MEM STAGE
assign exmem_op = exmem_out[6:0];
assign exmem_rd = exmem_out[11:7];
assign exmem_funct3 = exmem_out[14:12];
assign write_data_en = (exmem_op[6:2] == OP_STORE);
data_mem_rv32 #(
		.AddrWidth(DMemAddrWidth)
	)
	dmem (
		.read_data(dmem_out),
		.addr(exmem_alu_out),
		.write_data(exmem_b_out),
		.write_en(write_data_en),
		.funct3(exmem_funct3)
	);



// MEM/WB PIPELINE REGISTER
pipe_reg_rst_nop #(
		.BitWidth(InstrWidth)
	)
	memwb (
		.out(memwb_out),
		.in(exmem_out),
		.clk(clk),
		.rst(rst)
	);

always @(posedge clk) begin
	if (exmem_op[6:2] == OP_ARI_I) begin
		MEMWBValue <= exmem_alu_out; // pass along ALU result
	end
	else if (exmem_op[6:2] == OP_LOAD) begin
		MEMWBValue <= dmem_out;
	end
end



// WB STAGE
assign memwb_op = memwb_out[6:0];
assign memwb_rd = memwb_out[11:7];
//assign write_reg_en = (memwb_op_is_load || memwb_op_is_ari_r) && (memwb_rd != 5'd0);
// Don't need to check if rd is x0 because x0 can't be written in this implementation
assign write_reg_en = (memwb_op_is_load || memwb_op_is_ari_r);



// ==============================
// STALL DETECTION LOGIC
// ==============================

// The signal for detecting a stall based on the use of a result from LW
assign stall = memwb_op_is_load && // source instruction is a load
		((((idex_op[6:2] == OP_LOAD) || (idex_op[6:2] == OP_STORE)) && (idex_rs1 == memwb_rd)) || // stall for address calc
		((idex_op[6:2] == OP_ARI_I) && ((idex_rs1 == memwb_rd) || (idex_rs2 == memwb_rd)))); // ALU use

endmodule
