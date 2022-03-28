import rv32i_types::*;

module decode_unit (
    CTRLWord cw
);

    rv32i_word instr;
    assign instr = cw.instr;

    logic [6:0] opcode;  
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [6:0] imm3125;
    logic [4:0] imm2420;
    logic [4:0] imm1107;
    logic [7:0] imm1912;

    instr_parts instr_parts_inst (.*);

    ctrl_sigs_t ctrl;

    decode_mux dec_mux_inst (.*);

    //if (!ctrl.legal) // do something

    assign cw.uopcode = ctrl.uopcode;
    assign cw.iq_type = ctrl.iq_type;
    assign cw.exu_type = ctrl.exu_type;
    assign cw.has_rd = ctrl.has_rd;
    assign cw.has_rs1 = ctrl.has_rs1;
    assign cw.has_rs2 = ctrl.has_rs2;
    assign cw.rd = rd;
    assign cw.rs1 = rs1;
    assign cw.rs2 = rs2;
    assign cw.imm_type = ctrl.imm_type;
    assign cw.is_br = ctrl.is_br;
    // critical path #2
    assign cw.is_jal = ctrl.uopcode == uopc::jal;
    assign cw.is_jalr = ctrl.uopcode == uopc::jalr;
    // TODO: if under shadow and come across non shadowable instruction, cancel SFO
    assign cw.shadowed = ctrl.shadowable & cw.under_shadow;

    logic [4:0] packed_imm_mid;
    // critical path #1
    assign packed_imm_mid = ctrl.imm_type == immt::b || ctrl.imm_type == immt::s ? imm1107 : imm2420;

    assign cw.packed_imm = {imm3125, packed_imm_mid, imm1912};

endmodule : decode_unit

module instr_parts (
    input   rv32i_word     instr,
    output  logic [6:0]    opcode,
    output  logic [2:0]    funct3,
    output  logic [6:0]    funct7,
    output  logic [6:0]    imm3125,
    output  logic [4:0]    imm2420,
    output  logic [4:0]    imm1107,
    output  logic [7:0]    imm1912,
    output  logic [4:0]    rs1,
    output  logic [4:0]    rs2,
    output  logic [4:0]    rd
);

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    assign imm3125 = instr[31:25];
    assign imm2420 = instr[24:20];
    assign imm1107 = instr[11:07];
    assign imm1912 = instr[19:12];
    assign rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];

endmodule : instr_parts

module decode_mux (
    input   logic [6:0]   opcode,  
    input   logic [2:0]   funct3,
    input   logic [6:0]   funct7,
    output  ctrl_sigs_t   ctrl
);

    always_comb begin
        unique casez ({funct7, funct3, opcode})
            dec_op::LUI    : ctrl = '{1'b1, uopc::lui,    iqt::alu, exut::alu, 1'b1, 1'b0, 1'b0, immt::u, 1'b0, 1'b1};
            dec_op::AUIPC  : ctrl = '{1'b1, uopc::auipc,  iqt::alu, exut::alu, 1'b1, 1'b0, 1'b0, immt::u, 1'b0, 1'b0};
            // TODO: make sure AUIPC should use alu (maybe jump unit or smth?)

            dec_op::JAL    : ctrl = '{1'b1, uopc::jal,    iqt::alu, exut::alu, 1'b1, 1'b0, 1'b0, immt::j, 1'b0, 1'b0};
            dec_op::JALR   : ctrl = '{1'b1, uopc::jalr,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b0};

            dec_op::BEQ    : ctrl = '{1'b1, uopc::beq,    iqt::alu, exut::alu, 1'b0, 1'b1, 1'b1, immt::b, 1'b1, 1'b0};
            dec_op::BNE    : ctrl = '{1'b1, uopc::bne,    iqt::alu, exut::alu, 1'b0, 1'b1, 1'b1, immt::b, 1'b1, 1'b0}; 
            dec_op::BLT    : ctrl = '{1'b1, uopc::blt,    iqt::alu, exut::alu, 1'b0, 1'b1, 1'b1, immt::b, 1'b1, 1'b0};
            dec_op::BGE    : ctrl = '{1'b1, uopc::bge,    iqt::alu, exut::alu, 1'b0, 1'b1, 1'b1, immt::b, 1'b1, 1'b0};
            dec_op::BLTU   : ctrl = '{1'b1, uopc::bltu,   iqt::alu, exut::alu, 1'b0, 1'b1, 1'b1, immt::b, 1'b1, 1'b0};
            dec_op::BGEU   : ctrl = '{1'b1, uopc::bgeu,   iqt::alu, exut::alu, 1'b0, 1'b1, 1'b1, immt::b, 1'b1, 1'b0};

            dec_op::LB     : ctrl = '{1'b1, uopc::lb,     iqt::mem, exut::mem, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b0};
            dec_op::LH     : ctrl = '{1'b1, uopc::lh,     iqt::mem, exut::mem, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b0};
            dec_op::LW     : ctrl = '{1'b1, uopc::lw,     iqt::mem, exut::mem, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b0};
            dec_op::LBU    : ctrl = '{1'b1, uopc::lbu,    iqt::mem, exut::mem, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b0};
            dec_op::LHU    : ctrl = '{1'b1, uopc::lhu,    iqt::mem, exut::mem, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b0};

            dec_op::SB     : ctrl = '{1'b1, uopc::sb,     iqt::mem, exut::mem, 1'b0, 1'b1, 1'b1, immt::s, 1'b0, 1'b0};
            dec_op::SH     : ctrl = '{1'b1, uopc::sh,     iqt::mem, exut::mem, 1'b0, 1'b1, 1'b1, immt::s, 1'b0, 1'b0};
            dec_op::SW     : ctrl = '{1'b1, uopc::sw,     iqt::mem, exut::mem, 1'b0, 1'b1, 1'b1, immt::s, 1'b0, 1'b0};

            dec_op::ADDI   : ctrl = '{1'b1, uopc::addi,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::SLTI   : ctrl = '{1'b1, uopc::slti,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::SLTIU  : ctrl = '{1'b1, uopc::sltiu,  iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::XORI   : ctrl = '{1'b1, uopc::xori,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::ORI    : ctrl = '{1'b1, uopc::ori,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::ANDI   : ctrl = '{1'b1, uopc::andi,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::SLLI   : ctrl = '{1'b1, uopc::slli,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::SRLI   : ctrl = '{1'b1, uopc::srli,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::SRAI   : ctrl = '{1'b1, uopc::srai,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};

            dec_op::ADD    : ctrl = '{1'b1, uopc::add,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::SUB    : ctrl = '{1'b1, uopc::sub,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::SLL    : ctrl = '{1'b1, uopc::sll,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::SLT    : ctrl = '{1'b1, uopc::slt,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::SLTU   : ctrl = '{1'b1, uopc::sltu,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::XOR    : ctrl = '{1'b1, uopc::xoro,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::SRL    : ctrl = '{1'b1, uopc::srl,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1}; 
            dec_op::SRA    : ctrl = '{1'b1, uopc::sra,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1}; 
            dec_op::OR     : ctrl = '{1'b1, uopc::oro,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1}; 
            dec_op::AND    : ctrl = '{1'b1, uopc::ando,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1}; 

            // all following instructions currently marked illegal
            // FIXME: implement and mark legal
            dec_op::MUL    : ctrl = '{1'b0, uopc::mul,    iqt::alu, exut::mul, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b0};
            dec_op::MULH   : ctrl = '{1'b0, uopc::mulh,   iqt::alu, exut::mul, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b0};
            dec_op::MULHSU : ctrl = '{1'b0, uopc::mulhsu, iqt::alu, exut::mul, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b0};
            dec_op::MULHU  : ctrl = '{1'b0, uopc::mulhu,  iqt::alu, exut::mul, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b0};
            dec_op::DIV    : ctrl = '{1'b0, uopc::div,    iqt::alu, exut::div, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b0};
            dec_op::DIVU   : ctrl = '{1'b0, uopc::divu,   iqt::alu, exut::div, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b0};
            dec_op::REM    : ctrl = '{1'b0, uopc::rem,    iqt::alu, exut::div, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b0};
            dec_op::REMU   : ctrl = '{1'b0, uopc::remu,   iqt::alu, exut::div, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b0};

            dec_op::ANDN   : ctrl = '{1'b0, uopc::andn,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::ORN    : ctrl = '{1'b0, uopc::orn,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::XNOR   : ctrl = '{1'b0, uopc::xnoro,  iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};

            dec_op::ROL    : ctrl = '{1'b0, uopc::rol,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::ROR    : ctrl = '{1'b0, uopc::ror,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::RORI   : ctrl = '{1'b0, uopc::rori,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};

            dec_op::MIN    : ctrl = '{1'b0, uopc::min,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::MINU   : ctrl = '{1'b0, uopc::minu,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::MAX    : ctrl = '{1'b0, uopc::max,    iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};
            dec_op::MAXU   : ctrl = '{1'b0, uopc::maxu,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};

            dec_op::GREVI  : ctrl = '{1'b0, uopc::grevi,  iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            dec_op::GORCI  : ctrl = '{1'b0, uopc::gorci,  iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};

            // TODO: this may need to be broken into sub instructions in
            // decode by using shamt
            dec_op::CBSEXT : ctrl = '{1'b0, uopc::cbsext, iqt::alu, exut::alu, 1'b1, 1'b1, 1'b0, immt::i, 1'b0, 1'b1};
            // we will only implement Zbb so PACK is only used for zext.h and rs2 can only take zero.
            dec_op::PACK   : ctrl = '{1'b0, uopc::pack,   iqt::alu, exut::alu, 1'b1, 1'b1, 1'b1, immt::r, 1'b0, 1'b1};

            default : ctrl = '{1'b0, uopc::micro_opcode_t'('X), iqt::queue_type_t'('X), exut::exe_unit_type_t'('X), 1'bX, 1'bX, 1'bX, immt::imm_type_t'('X), 1'bX, 1'bX};
        endcase
    end
        

endmodule : decode_mux

module alu_imm_dec (
    input   logic [19:0]       imm_packed,
    input   immt::imm_type_t   imm_sel,
    output  rv32i_word         imm
);

    logic sign;
    assign sign = imm_packed[19];

    assign imm[31]    = sign;
    assign imm[30:20] = imm_sel == immt::u ? imm_packed[18:8] : {11{sign}};
    assign imm[19:12] = imm_sel == immt::u || imm_sel == immt::j ? imm_packed[7:0] : {8{sign}};
    assign imm[11]    = imm_sel == immt::u
                      ? '0
                      : imm_sel == immt::j || imm_sel == immt::b 
                        ? imm_packed[8] 
                        : sign;
    assign imm[10:5]  = imm_sel == immt::u ? '0 : imm_packed[18:13];
    assign imm[4:1]   = imm_sel == immt::u ? '0 : imm_packed[12:9];
    assign imm[0]     = imm_sel == immt::i ? imm_packed[8] : 1'b0;

endmodule : alu_imm_dec
