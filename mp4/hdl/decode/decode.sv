import rv32i_types::*;

module decode_unit (
    DecodeControl dc
);

    instr_parts instr_parts_inst (.*);

    decode_mux dec_mux_inst (.*);

    branch_decode_mux bdec_mux_inst (.*);

    //if (!ctrl.legal) // do something

    // TODO: if under shadow and come across non shadowable instruction, cancel SFO
    assign dc.shadowed = dc.bctrl.shadowable & dc.under_shadow;

    logic [4:0] packed_imm_mid;
    // critical path #1
    assign packed_imm_mid = dc.ctrl.imm_type == immt::b || dc.ctrl.is_simm ? dc.imm1107 : dc.imm2420;

    assign dc.packed_imm = {dc.imm3125, packed_imm_mid, dc.imm1912};

endmodule : decode_unit

module instr_parts (
    DecodeControl dc
);

    assign dc.opcode = dc.instr[6:0];
    assign dc.funct3 = dc.instr[14:12];
    assign dc.funct7 = dc.instr[31:25];
    assign dc.imm3125 = dc.instr[31:25];
    assign dc.imm2420 = dc.instr[24:20];
    assign dc.imm1107 = dc.instr[11:07];
    assign dc.imm1912 = dc.instr[19:12];
    assign dc.rd = dc.instr[11:7];
    assign dc.rs1 = dc.instr[19:15];
    assign dc.rs2 = dc.instr[24:20];

endmodule : instr_parts

module decode_mux (
    DecodeControl dc
);

    always_comb begin
        unique casez ({dc.funct7, dc.funct3, dc.opcode})
            dec_op::LUI    : dc.ctrl = '{1'b1, uopc::lui,    exut::alu, 1'b1, 1'b0, 1'b0, 1'b0, immt::u};
            dec_op::AUIPC  : dc.ctrl = '{1'b1, uopc::auipc,  exut::jmp, 1'b1, 1'b0, 1'b0, 1'b0, immt::u};

            dec_op::JAL    : dc.ctrl = '{1'b1, uopc::jal,    exut::jmp, 1'b1, 1'b0, 1'b0, 1'b0, immt::j};
            dec_op::JALR   : dc.ctrl = '{1'b1, uopc::jalr,   exut::jmp, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};

            dec_op::BEQ    : dc.ctrl = '{1'b1, uopc::beq,    exut::jmp, 1'b0, 1'b1, 1'b1, 1'b0, immt::b};
            dec_op::BNE    : dc.ctrl = '{1'b1, uopc::bne,    exut::jmp, 1'b0, 1'b1, 1'b1, 1'b0, immt::b}; 
            dec_op::BLT    : dc.ctrl = '{1'b1, uopc::blt,    exut::jmp, 1'b0, 1'b1, 1'b1, 1'b0, immt::b};
            dec_op::BGE    : dc.ctrl = '{1'b1, uopc::bge,    exut::jmp, 1'b0, 1'b1, 1'b1, 1'b0, immt::b};
            dec_op::BLTU   : dc.ctrl = '{1'b1, uopc::bltu,   exut::jmp, 1'b0, 1'b1, 1'b1, 1'b0, immt::b};
            dec_op::BGEU   : dc.ctrl = '{1'b1, uopc::bgeu,   exut::jmp, 1'b0, 1'b1, 1'b1, 1'b0, immt::b};

            dec_op::LB     : dc.ctrl = '{1'b1, uopc::lb,     exut::mem, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::LH     : dc.ctrl = '{1'b1, uopc::lh,     exut::mem, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::LW     : dc.ctrl = '{1'b1, uopc::lw,     exut::mem, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::LBU    : dc.ctrl = '{1'b1, uopc::lbu,    exut::mem, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::LHU    : dc.ctrl = '{1'b1, uopc::lhu,    exut::mem, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};

            dec_op::SB     : dc.ctrl = '{1'b1, uopc::sb,     exut::mem, 1'b0, 1'b1, 1'b1, 1'b1, immt::i};
            dec_op::SH     : dc.ctrl = '{1'b1, uopc::sh,     exut::mem, 1'b0, 1'b1, 1'b1, 1'b1, immt::i};
            dec_op::SW     : dc.ctrl = '{1'b1, uopc::sw,     exut::mem, 1'b0, 1'b1, 1'b1, 1'b1, immt::i};

            dec_op::ADDI   : dc.ctrl = '{1'b1, uopc::addi,   exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::SLTI   : dc.ctrl = '{1'b1, uopc::slti,   exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::SLTIU  : dc.ctrl = '{1'b1, uopc::sltiu,  exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::XORI   : dc.ctrl = '{1'b1, uopc::xori,   exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::ORI    : dc.ctrl = '{1'b1, uopc::ori,    exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::ANDI   : dc.ctrl = '{1'b1, uopc::andi,   exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::SLLI   : dc.ctrl = '{1'b1, uopc::slli,   exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::SRLI   : dc.ctrl = '{1'b1, uopc::srli,   exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::SRAI   : dc.ctrl = '{1'b1, uopc::srai,   exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};

            dec_op::ADD    : dc.ctrl = '{1'b1, uopc::add,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::SUB    : dc.ctrl = '{1'b1, uopc::sub,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::SLL    : dc.ctrl = '{1'b1, uopc::sll,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::SLT    : dc.ctrl = '{1'b1, uopc::slt,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::SLTU   : dc.ctrl = '{1'b1, uopc::sltu,   exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::XOR    : dc.ctrl = '{1'b1, uopc::xoro,   exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::SRL    : dc.ctrl = '{1'b1, uopc::srl,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)}; 
            dec_op::SRA    : dc.ctrl = '{1'b1, uopc::sra,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)}; 
            dec_op::OR     : dc.ctrl = '{1'b1, uopc::oro,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)}; 
            dec_op::AND    : dc.ctrl = '{1'b1, uopc::ando,   exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)}; 

            // all following instructions currently marked illegal
            // FIXME: implement and mark legal
            dec_op::MUL    : dc.ctrl = '{1'b0, uopc::mul,    exut::mul, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::MULH   : dc.ctrl = '{1'b0, uopc::mulh,   exut::mul, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::MULHSU : dc.ctrl = '{1'b0, uopc::mulhsu, exut::mul, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::MULHU  : dc.ctrl = '{1'b0, uopc::mulhu,  exut::mul, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::DIV    : dc.ctrl = '{1'b0, uopc::div,    exut::mul, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::DIVU   : dc.ctrl = '{1'b0, uopc::divu,   exut::mul, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::REM    : dc.ctrl = '{1'b0, uopc::rem,    exut::mul, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::REMU   : dc.ctrl = '{1'b0, uopc::remu,   exut::mul, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};

            dec_op::ANDN   : dc.ctrl = '{1'b0, uopc::andn,   exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::ORN    : dc.ctrl = '{1'b0, uopc::orn,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::XNOR   : dc.ctrl = '{1'b0, uopc::xnoro,  exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};

            dec_op::ROL    : dc.ctrl = '{1'b0, uopc::rol,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::ROR    : dc.ctrl = '{1'b0, uopc::ror,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::RORI   : dc.ctrl = '{1'b0, uopc::rori,   exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};

            dec_op::MIN    : dc.ctrl = '{1'b0, uopc::min,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::MINU   : dc.ctrl = '{1'b0, uopc::minu,   exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::MAX    : dc.ctrl = '{1'b0, uopc::max,    exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};
            dec_op::MAXU   : dc.ctrl = '{1'b0, uopc::maxu,   exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};

            dec_op::GREVI  : dc.ctrl = '{1'b0, uopc::grevi,  exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            dec_op::GORCI  : dc.ctrl = '{1'b0, uopc::gorci,  exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};

            // TODO: this may need to be broken into sub instructions in
            // decode by using shamt
            dec_op::CBSEXT : dc.ctrl = '{1'b0, uopc::cbsext, exut::alu, 1'b1, 1'b1, 1'b0, 1'b0, immt::i};
            // we will only implement Zbb so PACK is only used for zext.h and rs2 can only take zero.
            dec_op::PACK   : dc.ctrl = '{1'b0, uopc::pack,   exut::alu, 1'b1, 1'b1, 1'b1, 1'b0, immt::imm_type_t'('X)};

            default        : dc.ctrl = '{1'b0, uopc::add,    exut::alu, 1'b0, 1'b0, 1'b0, 1'b0, immt::imm_type_t'('X)};
        endcase
    end

endmodule : decode_mux

module branch_decode_mux (
    DecodeControl dc
);
    // TODO: detect returns and calls
    always_comb begin
        unique casez ({dc.funct7, dc.funct3, dc.opcode})
            dec_op::LUI    : dc.bctrl = '{1'b0, 1'b0, 1'b1};

            dec_op::JAL    : dc.bctrl = '{1'b0, 1'b1, 1'b0};
            dec_op::JALR   : dc.bctrl = '{1'b0, 1'b0, 1'b0};

            dec_op::BEQ    : dc.bctrl = '{1'b1, 1'b0, 1'b0};
            dec_op::BNE    : dc.bctrl = '{1'b1, 1'b0, 1'b0}; 
            dec_op::BLT    : dc.bctrl = '{1'b1, 1'b0, 1'b0};
            dec_op::BGE    : dc.bctrl = '{1'b1, 1'b0, 1'b0};
            dec_op::BLTU   : dc.bctrl = '{1'b1, 1'b0, 1'b0};
            dec_op::BGEU   : dc.bctrl = '{1'b1, 1'b0, 1'b0};

            dec_op::ADDI   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SLTI   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SLTIU  : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::XORI   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::ORI    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::ANDI   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SLLI   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SRLI   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SRAI   : dc.bctrl = '{1'b0, 1'b0, 1'b1};

            dec_op::ADD    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SUB    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SLL    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SLT    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SLTU   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::XOR    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::SRL    : dc.bctrl = '{1'b0, 1'b0, 1'b1}; 
            dec_op::SRA    : dc.bctrl = '{1'b0, 1'b0, 1'b1}; 
            dec_op::OR     : dc.bctrl = '{1'b0, 1'b0, 1'b1}; 
            dec_op::AND    : dc.bctrl = '{1'b0, 1'b0, 1'b1}; 

            dec_op::ANDN   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::ORN    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::XNOR   : dc.bctrl = '{1'b0, 1'b0, 1'b1};

            dec_op::MIN    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::MINU   : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::MAX    : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::MAXU   : dc.bctrl = '{1'b0, 1'b0, 1'b1};

            dec_op::GREVI  : dc.bctrl = '{1'b0, 1'b0, 1'b1};
            dec_op::GORCI  : dc.bctrl = '{1'b0, 1'b0, 1'b1};

            default        : dc.bctrl = '{1'b0, 1'b0, 1'b0};
        endcase
    end

endmodule : branch_decode_mux

module branch_target_calc (
    input rv32i_word pc,
    DecodeControl dc
);
    rv32i_word b_imm;
    rv32i_word j_imm;

    assign b_imm = {{20{dc.instr[31]}}, dc.instr[7], dc.instr[30:25], dc.instr[11:8], 1'b0};
    assign j_imm = {{12{dc.instr[31]}}, dc.instr[19:12], dc.instr[20], dc.instr[30:21], 1'b0};

    assign dc.btarget = pc + b_imm;
    assign dc.jtarget = pc + j_imm;

endmodule : branch_target_calc

