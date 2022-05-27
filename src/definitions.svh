// RISC-V Opcodes and Funct3 Codes

`ifndef DEFINITIONS
`define DEFINITIONS

package definitions;

localparam NOP				= 32'h0000_0013;

// ==============================
// OPCODES
// Actually 7 bits, but lowest
// 2 bits are high for all.
// ==============================

localparam OP_LOAD			= 5'b00000;
localparam OP_FENCE			= 5'b00011;
localparam OP_ARI_I			= 5'b00100;
localparam OP_AUIPC			= 5'b00101;
localparam OP_ARI_I_W		= 5'b00110;
localparam OP_STORE			= 5'b01000;
localparam OP_ARI_R			= 5'b01100;
localparam OP_LUI			= 5'b01101;
localparam OP_ARI_R_W		= 5'b01110;
localparam OP_BRANCH		= 5'b11000;
localparam OP_JALR			= 5'b11001;
localparam OP_JAL			= 5'b11011;
localparam OP_EXCEPT		= 5'b11100;


// ==============================
// FUNCT3 CODES
// ==============================

// Load
localparam F3_LB			= 3'b000;
localparam F3_LH			= 3'b001;
localparam F3_LW			= 3'b010;
localparam F3_LD			= 3'b011;
localparam F3_LBU			= 3'b100;
localparam F3_LHU			= 3'b101;
localparam F3_LWU			= 3'b110;

// Store
localparam F3_SB			= 3'b000;
localparam F3_SH			= 3'b001;
localparam F3_SW			= 3'b010;
localparam F3_SD			= 3'b011;

// Arithmetic R-type
localparam F3_ADD_SUB		= 3'b000; // add: funct7[5] = 0; sub: funct7[5] = 1
localparam F3_SLL			= 3'b001;
localparam F3_SLT			= 3'b010;
localparam F3_SLTU			= 3'b011;
localparam F3_XOR			= 3'b100;
localparam F3_SRL_SRA		= 3'b101;
localparam F3_OR			= 3'b110;
localparam F3_AND			= 3'b111;

// Arithmetic I-type
localparam F3_ADDIW			= 3'b000;
localparam F3_SLLIW			= 3'b001;
localparam F3_SLTI			= 3'b010;
localparam F3_SLTIU			= 3'b011;
localparam F3_XORI			= 3'b100;
localparam F3_SRLIW_SRAIW	= 3'b101; // srliw: funct7[5] = 0; sraiw: funct7[5] = 1
localparam F3_ORI			= 3'b110;
localparam F3_ANDI			= 3'b111;

// Branch
localparam F3_BEQ			= 3'b000;
localparam F3_BNE			= 3'b001;
localparam F3_BLT			= 3'b100;
localparam F3_BGE			= 3'b101;
localparam F3_BLTU			= 3'b110;
localparam F3_BGEU			= 3'b111;

endpackage
`endif //OPCODE
