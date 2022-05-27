// RISC-V Opcodes and Funct3 Codes

`ifndef DEFINITIONS
`define DEFINITIONS

`define NOP            32'h0000_0013

// ==============================
// OPCODES
// Actually 7 bits, but lowest
// 2 bits are high for all.
// ==============================

`define OP_LOAD        5'b00000
`define OP_FENCE       5'b00011
`define OP_ARI_I		5'b00100
`define OP_AUIPC       5'b00101
`define OP_ARI_I_W     5'b00110
`define OP_STORE       5'b01000
`define OP_ARI_R       5'b01100
`define OP_LUI         5'b01101
`define OP_ARI_R_W     5'b01110
`define OP_BRANCH      5'b11000
`define OP_JALR        5'b11001
`define OP_JAL         5'b11011
`define OP_EXCEPT      5'b11100


// ==============================
// FUNCT3 CODES
// ==============================

// Load
`define F3_LB          3'b000
`define F3_LH          3'b001
`define F3_LW          3'b010
`define F3_LD          3'b011
`define F3_LBU         3'b100
`define F3_LHU         3'b101
`define F3_LWU         3'b110

// Store
`define F3_SB          3'b000
`define F3_SH          3'b001
`define F3_SW          3'b010
`define F3_SD          3'b011

// Arithmetic R-type
`define F3_ADD_SUB     3'b000 // add: funct7[5] = 0; sub: funct7[5] = 1
`define F3_SLL         3'b001
`define F3_SLT         3'b010
`define F3_SLTU        3'b011
`define F3_XOR         3'b100
`define F3_SRL_SRA	   3'b101
`define F3_OR          3'b110
`define F3_AND         3'b111

// Arithmetic I-type
`define F3_ADDIW       3'b000
`define F3_SLLIW       3'b001
`define F3_SRLIW_SRAIW 3'b101 // srliw: funct7[5] = 0; sraiw: funct7[5] = 1

// Branch
`define F3_BEQ         3'b000
`define F3_BNE         3'b001
`define F3_BLT         3'b100
`define F3_BGE         3'b101
`define F3_BLTU        3'b110
`define F3_BGEU        3'b111

`endif //OPCODE
