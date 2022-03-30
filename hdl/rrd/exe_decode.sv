import rv32i_types::*;

module exe_decode (
    ExecuteControl ec
);

    always_comb begin
        unique case (ec.uopcode)
            uopc::lui    : ec.ctrl = '{alufnt::add,  opr1t::zero, opr2t::imm, brfnt::none};
            uopc::auipc  : ec.ctrl = '{alufnt::add,  opr1t::pc,   opr2t::imm, brfnt::none};

            uopc::jalr   : ec.ctrl = '{alufnt::add,  opr1t::rs1,  opr2t::imm, brfnt::jalr};

            uopc::beq    : ec.ctrl = '{alufnt::add,  opr1t::pc,   opr2t::imm, brfnt::beq };
            uopc::bne    : ec.ctrl = '{alufnt::add,  opr1t::pc,   opr2t::imm, brfnt::bne };
            uopc::blt    : ec.ctrl = '{alufnt::add,  opr1t::pc,   opr2t::imm, brfnt::blt };
            uopc::bge    : ec.ctrl = '{alufnt::add,  opr1t::pc,   opr2t::imm, brfnt::bge };
            uopc::bltu   : ec.ctrl = '{alufnt::add,  opr1t::pc,   opr2t::imm, brfnt::bltu};
            uopc::bgeu   : ec.ctrl = '{alufnt::add,  opr1t::pc,   opr2t::imm, brfnt::bgeu};

            uopc::addi   : ec.ctrl = '{alufnt::add,  opr1t::rs1,  opr2t::imm, brfnt::none};
            uopc::slti   : ec.ctrl = '{alufnt::slt,  opr1t::rs1,  opr2t::imm, brfnt::none};
            uopc::sltiu  : ec.ctrl = '{alufnt::sltu, opr1t::rs1,  opr2t::imm, brfnt::none};
            uopc::xori   : ec.ctrl = '{alufnt::xoro, opr1t::rs1,  opr2t::imm, brfnt::none};
            uopc::ori    : ec.ctrl = '{alufnt::oro,  opr1t::rs1,  opr2t::imm, brfnt::none};
            uopc::andi   : ec.ctrl = '{alufnt::ando, opr1t::rs1,  opr2t::imm, brfnt::none};
            uopc::slli   : ec.ctrl = '{alufnt::sl,   opr1t::rs1,  opr2t::imm, brfnt::none};
            uopc::srli   : ec.ctrl = '{alufnt::sr,   opr1t::rs1,  opr2t::imm, brfnt::none};
            uopc::srai   : ec.ctrl = '{alufnt::sra,  opr1t::rs1,  opr2t::imm, brfnt::none};

            uopc::add    : ec.ctrl = '{alufnt::add,  opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::sub    : ec.ctrl = '{alufnt::sub,  opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::sll    : ec.ctrl = '{alufnt::sl,   opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::slt    : ec.ctrl = '{alufnt::slt,  opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::sltu   : ec.ctrl = '{alufnt::sltu, opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::xoro   : ec.ctrl = '{alufnt::xoro, opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::srl    : ec.ctrl = '{alufnt::sr,   opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::sra    : ec.ctrl = '{alufnt::sra,  opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::oro    : ec.ctrl = '{alufnt::oro,  opr1t::rs1,   opr2t::rs2, brfnt::none};
            uopc::ando   : ec.ctrl = '{alufnt::ando, opr1t::rs1,   opr2t::rs2, brfnt::none};

            default      : ec.ctrl = '{alufnt::add,  opr1t::zero, opr2t::imm, brfnt::none};
        endcase
    end

    

endmodule : exe_decode

module alu_imm_dec (
    input   logic [19:0]       packed_imm,
    input   immt::imm_type_t   imm_type,
    output  rv32i_word         imm
);

    logic sign;
    assign sign = packed_imm[19];

    assign imm[31]    = sign;
    assign imm[30:20] = imm_type == immt::u ? packed_imm[18:8] : {11{sign}};
    assign imm[19:12] = imm_type == immt::u || imm_type == immt::j ? packed_imm[7:0] : {8{sign}};
    assign imm[11]    = imm_type == immt::u
                      ? '0
                      : imm_type == immt::j || imm_type == immt::b 
                        ? packed_imm[8] 
                        : sign;
    assign imm[10:5]  = imm_type == immt::u ? '0 : packed_imm[18:13];
    assign imm[4:1]   = imm_type == immt::u ? '0 : packed_imm[12:9];
    assign imm[0]     = imm_type == immt::i ? packed_imm[8] : 1'b0;

endmodule : alu_imm_dec
