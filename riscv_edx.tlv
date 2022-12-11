\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/warp-v_includes/1d1023ccf8e7b0a8cf8e8fc4f0a823ebb61008e3/risc-v_defs.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])

   //--------------------------------
   // CHAPTER 5 TEST PROGRAM
   m4_test_prog()
   //--------------------------------

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   
   $reset = *reset;
   
   //-----------------
   // PROGRAM COUNTER
   //-----------------
   $pc[31:0] = >>1$next_pc[31:0];
   $next_pc[31:0] =
     $reset ? 32'b0 :
     ($taken_br || $is_jal) ? $br_tgt_pc :
     $is_jalr ? $jalr_tgt_pc :
     $pc + 4;
   
   //--------------------
   // INSTRUCTION MEMORY
   //--------------------
   `READONLY_MEM($pc, $$instr[31:0]);
   
   //-------------
   // DECODE LOGIC
   //-------------
   // i: 11001, 0000x, 001x0
   $is_i_instr = $instr[6:2] ==  5'b11001 || ($instr[6:5] == 2'b00 && ($instr[4:2] ==? 3'b00x || $instr[4:2] ==? 3'b1x0));
   // r: 10100, 01011, 011x0
   $is_r_instr = $instr[6:2] ==  5'b10100 || ($instr[6:5] == 2'b01 && ($instr[4:2] ==  3'b011 || $instr[4:2] ==? 3'b1x0));
   $is_s_instr = $instr[6:2] ==? 5'b0100x;
   $is_b_instr = $instr[6:2] ==  5'b11000;
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   $is_j_instr = $instr[6:2] ==  5'b11011;
   
   $opcode[6:0] = $instr[6:0];
   
   // "d" for "destination"
   $rd_valid = !($is_s_instr || $is_b_instr);
   $rd[4:0] = $instr[11:7];
   
   $imm_valid = !$is_r_instr;
   $imm[31:0] = $is_i_instr ? {{21{$instr[31]}}, $instr[30:25], $instr[24:21], $instr[20]} :
                $is_s_instr ? {{21{$instr[31]}}, $instr[30:25], $instr[11:8], $instr[7]} :
                $is_b_instr ? {{20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0} :
                $is_u_instr ? {$instr[31], $instr[30:20], $instr[19:12], 12'b0} :
                $is_j_instr ? {{12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:25], $instr[24:21], 1'b0} :
                32'b0;
   
   // "s" for "source"
   $rs1_valid = !($is_u_instr || $is_j_instr);
   $rs1[4:0] = $instr[19:15];
   $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
   $rs2[4:0] = $instr[24:20];
   
   $funct7[6:0] = $instr[31:25];
   $funct3[2:0] = $instr[14:12];
   
   $dec_bits[10:0] = {$instr[30], $funct3, $opcode};
   $is_lui   = $opcode == 7'b0110111;
   $is_auipc = $opcode == 7'b0010111;
   $is_jal   = $opcode == 7'b1101111;
   $is_jalr  = $dec_bits ==? 11'bx_000_1100111;
   // Branching
   $is_beq  = $dec_bits ==? 11'bx_000_1100011;
   $is_bne  = $dec_bits ==? 11'bx_001_1100011;
   $is_blt  = $dec_bits ==? 11'bx_100_1100011;
   $is_bge  = $dec_bits ==? 11'bx_101_1100011;
   $is_bltu = $dec_bits ==? 11'bx_110_1100011;
   $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
   // Loading
   $is_load = $opcode == 7'b0000011;
   // Storing
   // Use $is_s_instr
   // Arithmetic and bitwise
   $is_addi  = $dec_bits ==? 11'bx_000_0010011;
   $is_slti  = $dec_bits ==? 11'bx_010_0010011;
   $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
   $is_xori  = $dec_bits ==? 11'bx_100_0010011;
   $is_ori   = $dec_bits ==? 11'bx_110_0010011;
   $is_andi  = $dec_bits ==? 11'bx_111_0010011;
   $is_slli  = $dec_bits ==? 11'b0_001_0010011;
   $is_srli  = $dec_bits ==  11'b0_101_0010011;
   $is_srai  = $dec_bits ==  11'b1_101_0010011;
   $is_add   = $dec_bits ==  11'b0_000_0110011;
   $is_sub   = $dec_bits ==  11'b1_000_0110011;
   $is_sll   = $dec_bits ==  11'b0_001_0110011;
   $is_slt   = $dec_bits ==  11'b0_010_0110011;
   $is_sltu  = $dec_bits ==  11'b0_011_0110011;
   $is_xor   = $dec_bits ==  11'b0_100_0110011;
   $is_srl   = $dec_bits ==  11'b0_101_0110011;
   $is_sra   = $dec_bits ==  11'b1_101_0110011;
   $is_or    = $dec_bits ==  11'b0_110_0110011;
   $is_and   = $dec_bits ==  11'b0_111_0110011;
   
   //---------------
   // REGISTER FILE
   //---------------
   /*
   Original variables:
   32,
   32,
   $reset,
   $wr_en,
   $wr_index[4:0],
   $wr_data[31:0],
   $rd1_en,
   $rd1_index[4:0],
   $rd1_data,
   $rd2_en,
   $rd2_index[4:0],
   $rd2_data
   */
   m4+rf(32, 32, $reset, $rd_valid, $rd, $alur_or_dmem, $rs1_valid, $rs1, $src1_value, $rs2_valid, $rs2, $src2_value)
   
   //------------
   // ALU
   //------------
   // SLTU and SLTIU (set if less than, unsigned) results
   $sltu_rslt[31:0]  = {31'b0, $src1_value < $src2_value};
   $sltiu_rslt[31:0] = {31'b0, $src1_value < $imm};
   // SLT and SLTI (set if less than, signed) results
   $slt_rslt[31:0]  = ($src1_value[31] == $src2_value[31]) ? $sltu_rslt  : {31'b0, $src1_value[31]};
   $slti_rslt[31:0] = ($src1_value[31] == $imm[31])        ? $sltiu_rslt : {31'b0, $src1_value[31]};
   
   // SRA and SRAI (shift right, arithmetic) results
   // Sign-extended src1
   $sext_src1[63:0] = {{32{$src1_value[31]}}, $src1_value};
   // 64-bit sign-extended results, to be truncated
   $sra_rslt[63:0]  = $sext_src1 >> $src2_value[4:0];
   $srai_rslt[63:0] = $sext_src1 >> $imm[4:0];
   
   $result[31:0] =
      $is_lui   ? {$imm[31:12], 12'b0} :
      $is_auipc ? $pc + $imm :
      $is_jal   ? $pc + 32'd4 :
      $is_jalr  ? $pc + 32'd4 :
      $is_addi  ? $src1_value + $imm :
      $is_slti  ? $slti_rslt :
      $is_sltiu ? $sltiu_rslt :
      $is_xori  ? $src1_value ^ $imm :
      $is_ori   ? $src1_value | $imm :
      $is_andi  ? $src1_value & $imm :
      $is_slli  ? $src1_value << $imm[5:0] :
      $is_srli  ? $src1_value >> $imm[5:0] :
      $is_srai  ? $srai_rslt[31:0] :
      $is_add   ? $src1_value + $src2_value :
      $is_sub   ? $src1_value - $src2_value :
      $is_sll   ? $src1_value << $src2_value[4:0] :
      $is_slt   ? $slt_rslt :
      $is_sltu  ? $sltu_rslt :
      $is_xor   ? $src1_value ^ $src2_value :
      $is_srl   ? $src1_value >> $src2_value[4:0] :
      $is_sra   ? $sra_rslt[31:0] :
      $is_or    ? $src1_value | $src2_value :
      $is_and   ? $src1_value & $src2_value :
      32'b0;
   
   //--------------
   // BRANCH LOGIC
   //--------------
   $taken_br =
      $is_beq  ? ($src1_value == $src2_value) :
      $is_bne  ? ($src1_value != $src2_value) :
      $is_blt  ? (($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
      $is_bge  ? (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
      $is_bltu ? ($src1_value < $src2_value) :
      $is_bgeu ? ($src1_value >= $src2_value) :
      1'b0;
   $br_tgt_pc[31:0] = $pc + $imm;
   $jalr_tgt_pc[31:0] = $src1_value + $imm;
   
   //-------------
   // DATA MEMORY
   //-------------
   /*
   Original variables:
   32
   32
   $reset
   $addr[4:0]
   $wr_en
   $wr_data[31:0]
   $rd_en
   $rd_data
   */
   m4+dmem(32, 32, $reset, $result[4:0], $is_s_instr, $src2_value, $is_load, $ld_data)
   $alur_or_dmem[31:0] = $is_load ? $ld_data : $result;
   
   `BOGUS_USE($rd $rd_valid $rs1 $rs1_valid $funct7 $imm_valid);
   
   // Assert these to end simulation (before Makerchip cycle limit).
   //*passed = 1'b0;
   m4+tb()
   *failed = *cyc_cnt > M4_MAX_CYC;
   
   m4+cpu_viz()
\SV
   endmodule