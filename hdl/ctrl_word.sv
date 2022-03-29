import rv32i_types::*;

package alufnt;
typedef enum logic [3:0] {
    add  = 4'b0000,
    sl   = 4'b0001,
    seq  = 4'b0010,
    sne  = 4'b0011,
    xoro = 4'b0100,
    sr   = 4'b0101,
    oro  = 4'b0110,
    ando = 4'b0111,
    sub  = 4'b1010,
    sra  = 4'b1011,
    slt  = 4'b1100,
    sge  = 4'b1101,
    sltu = 4'b1110,
    sgeu = 4'b1111
} alu_func_t;
endpackage

package opr1t;
typedef enum logic {
    rs1,
    pc,
    zero
} operand1_t;
endpackage

package opr2t;
typedef enum logic {
    rs2,
    imm
} operand2_t;
endpackage

package cmpfnt;
typedef enum logic [2:0] {
    beq,
    bne,
    blt,
    bge,
    bltu,
    bgeu,
    jalr,
    none
} cmp_func_t;
endpackage

package exut;
typedef enum logic [1:0] {
    alu,
    mul,
    div,
    mem
} exe_unit_type_t;
endpackage

package iqt;
typedef enum logic {
    alu,
    mem
} queue_type_t;
endpackage

package immt;
typedef enum logic [2:0] {
    i,
    b,
    u,
    j,
    s,
    r
} imm_type_t;
endpackage

package uopc;
typedef enum logic [5:0] {
    lui,
    auipc,

    jal,
    jalr,

    beq,
    bne,
    blt,
    bge,
    bltu,
    bgeu,

    lb,
    lh,
    lw,
    lbu,
    lhu,

    sb,
    sh,
    sw,

    addi,
    slti,
    sltiu,
    xori,
    ori,
    andi,
    slli,
    srli,
    srai,

    add,
    sub,
    sll,
    slt,
    sltu,
    xoro,
    srl,
    sra,
    oro,
    ando,

    mul,
    mulh,
    mulhsu,
    mulhu,
    div,
    divu,
    rem,
    remu,

    andn,
    orn,
    xnoro,
          
    rol,
    ror,
    rori,

    min,
    minu,
    max,
    maxu,

    grevi, // rev8
    gorci, // orc.b

    cbsext,
    pack  // zext.h
} micro_opcode_t;
endpackage

// frontend
// TODO: rename to indicate only for frontend
interface DecodeControl;
    // -- input -- //
    rv32i_word instr;
    // on the taken branch
    logic taken;
    // under branch shadow (SFO)
    logic under_shadow;

    //intermediate
    logic [6:0] opcode;  
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [6:0] imm3125;
    logic [4:0] imm2420;
    logic [4:0] imm1107;
    logic [7:0] imm1912;

    // decode output
    ctrl_sigs_t ctrl;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [19:0] packed_imm;

    // branch decode output
    branch_ctrl_sigs_t bctrl;
    // for short forward branch optimization
    // (if we implement it)
    logic shadowed;
    rv32i_word btarget;
    rv32i_word jtarget;
    // TODO: maybe define some modports so everything's not inout
endinterface

typedef struct {
    logic legal;
    // for further decoding in rrd
    uopc::micro_opcode_t uopcode;
    // for pushing to appropriate queue
    iqt::queue_type_t iq_type;
    // for checking if we can issue (scoreboard)
    // and for rrd
    exut::exe_unit_type_t exu_type;
    logic has_rd;
    logic has_rs1;
    logic has_rs2;
    // for decoding imm in parallel with rrd
    immt::imm_type_t imm_type;
} ctrl_sigs_t;

typedef struct {
    // for seeing if we should use 
    // bht prediction
    // (if we implement one)
    // would add mux to end of DEC
    // TODO: make enum maybe
    logic is_br;
    logic is_jal;
    logic shadowable;
} branch_ctrl_sigs_t;

// backend
interface ExecuteControl;
    logic under_shadow;

    // for further decoding in rrd
    uopc::micro_opcode_t uopcode;
    // for checking if we can issue (scoreboard)
    // and for rrd
    exut::exe_unit_type_t exu_type;
    logic has_rd;
    logic has_rs1;
    logic has_rs2;
    // for rrd
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;

    // for decoding imm in parallel with rrd
    immt::imm_type_t imm_type;
    logic [19:0] packed_imm;
    logic taken;
    // for short forward branch optimization
    // (if we implement it)
    logic shadowed;
    backend_ctrl_sigs_t ctrl;
    // somewhat compressed imm
    // decompressed imm
    rv32i_word imm;
    
    // TODO: maybe define some modports so everything's not inout
endinterface

typedef struct {
    alufnt::alu_func_t alufn;
    opr1t::operand1_t opr1;
    opr2t::operand2_t opr2;
    cmpfnt::cmp_func_t cmpfn;
} backend_ctrl_sigs_t;

typedef struct {
    uopc::micro_opcode_t uopcode;
    exut::exe_unit_type_t exu_type;
    logic has_rd;
    logic has_rs1;
    logic has_rs2;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    immt::imm_type_t imm_type;
    logic [19:0] packed_imm;
    logic taken;
    logic shadowed;
} queue_item_t;
    


// first 2 bits of opcode are don't cares
// because we don't support compressed
package dec_op;
typedef enum logic [16:0] {
    LUI    = 17'b???????_???_01101??,
    AUIPC  = 17'b???????_???_00101??,

    JAL    = 17'b???????_???_11011??,
    JALR   = 17'b???????_000_11001??,

    BEQ    = 17'b???????_000_11000??,
    BNE    = 17'b???????_001_11000??,
    BLT    = 17'b???????_100_11000??,
    BGE    = 17'b???????_101_11000??,
    BLTU   = 17'b???????_110_11000??,
    BGEU   = 17'b???????_111_11000??,

    LB     = 17'b???????_000_00000??,
    LH     = 17'b???????_001_00000??,
    LW     = 17'b???????_010_00000??,
    LBU    = 17'b???????_100_00000??,
    LHU    = 17'b???????_101_00000??,

    SB     = 17'b???????_000_01000??,
    SH     = 17'b???????_001_01000??,
    SW     = 17'b???????_010_01000??,

    ADDI   = 17'b???????_000_00100??,
    SLTI   = 17'b???????_010_00100??,
    SLTIU  = 17'b???????_011_00100??,
    XORI   = 17'b???????_100_00100??,
    ORI    = 17'b???????_110_00100??,
    ANDI   = 17'b???????_111_00100??,
    SLLI   = 17'b?00????_001_00100??,
    SRLI   = 17'b?00?0??_101_00100??,
    SRAI   = 17'b?10?0??_101_00100??,

    ADD    = 17'b?0????0_000_01100??,
    SUB    = 17'b?1????0_000_01100??,
    SLL    = 17'b?00???0_001_01100??,
    SLT    = 17'b??????0_010_01100??,
    SLTU   = 17'b??????0_011_01100??,
    XOR    = 17'b?0??0?0_100_01100??,
    SRL    = 17'b?00?0?0_101_01100??,
    SRA    = 17'b?10?0?0_101_01100??,
    OR     = 17'b?0??0?0_110_01100??,
    AND    = 17'b?0??0?0_111_01100??,

    // M extension
    MUL    = 17'b?0????1_000_01100??,
    MULH   = 17'b?00???1_001_01100??,
    MULHSU = 17'b??????1_010_01100??,
    MULHU  = 17'b??????1_011_01100??,
    DIV    = 17'b?0??0?1_100_01100??,
    DIVU   = 17'b?00?0?1_101_01100??,
    REM    = 17'b?0??0?1_110_01100??,
    REMU   = 17'b?0??0?1_111_01100??,

    // Zbb extension
    // https://github.com/riscv/riscv-bitmanip/blob/main/bitmanip/zbb.adoc
    ANDN   = 17'b?1??0?0_111_01100??,
    ORN    = 17'b?1??0?0_110_01100??,
    XNOR   = 17'b?1??0?0_100_01100??,

    ROL    = 17'b?11????_001_01100??,
    ROR    = 17'b?11?0?0_101_01100??,
    RORI   = 17'b?11?0??_101_00100??,

    MIN    = 17'b?0??1?1_100_01100??,
    MINU   = 17'b?00?1?1_101_01100??,
    MAX    = 17'b?0??1?1_110_01100??,
    MAXU   = 17'b?0??1?1_111_01100??,

    // Zbb only supports rev8 and orc.b
    // shamt = 11000
    GREVI  = 17'b?11?1??_101_00100??,
    // https://github.com/riscv/riscv-bitmanip/blob/main/bitmanip/_or_combine.adoc
    GORCI  = 17'b?01?1??_101_00100??,

    // CLZ, CTZ, CPOP, SEXT distinguished by shamt
    // CLZ    : 00000
    // CTZ    : 00001
    // CPOP   : 00010
    // SEXT.B : 00100
    // SEXT.H : 00101
    CBSEXT = 17'b?11????_001_00100??,
    // used only for zext.h in Zbb (rs2 == zero)
    PACK   = 17'b?0??1?0_100_01100??
} dec_op_t;
endpackage

