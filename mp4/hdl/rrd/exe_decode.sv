import rv32i_types::*;
import ctrl_sigs::*;

module alu_decode (
    input uopc::micro_opcode_t uopcode,
    output alu_ctrl_sigs_t ctrl
);

    always_comb begin
        unique case (uopcode)
            uopc::lui    : ctrl = '{alufnt::add,  opr2t::imm};

            uopc::addi   : ctrl = '{alufnt::add,  opr2t::imm};
            uopc::slti   : ctrl = '{alufnt::slt,  opr2t::imm};
            uopc::sltiu  : ctrl = '{alufnt::sltu, opr2t::imm};
            uopc::xori   : ctrl = '{alufnt::xoro, opr2t::imm};
            uopc::ori    : ctrl = '{alufnt::oro,  opr2t::imm};
            uopc::andi   : ctrl = '{alufnt::ando, opr2t::imm};
            uopc::slli   : ctrl = '{alufnt::sl,   opr2t::imm};
            uopc::srli   : ctrl = '{alufnt::sr,   opr2t::imm};
            uopc::srai   : ctrl = '{alufnt::sra,  opr2t::imm};

            uopc::add    : ctrl = '{alufnt::add,  opr2t::rs2};
            uopc::sub    : ctrl = '{alufnt::sub,  opr2t::rs2};
            uopc::sll    : ctrl = '{alufnt::sl,   opr2t::rs2};
            uopc::slt    : ctrl = '{alufnt::slt,  opr2t::rs2};
            uopc::sltu   : ctrl = '{alufnt::sltu, opr2t::rs2};
            uopc::xoro   : ctrl = '{alufnt::xoro, opr2t::rs2};
            uopc::srl    : ctrl = '{alufnt::sr,   opr2t::rs2};
            uopc::sra    : ctrl = '{alufnt::sra,  opr2t::rs2};
            uopc::oro    : ctrl = '{alufnt::oro,  opr2t::rs2};
            uopc::ando   : ctrl = '{alufnt::ando, opr2t::rs2};

            default      : ctrl = '{alufnt::add,  opr2t::imm};
        endcase
    end

endmodule : alu_decode

module bru_decode (
    input uopc::micro_opcode_t uopcode,
    output brfnt::br_func_t brfn
);

    always_comb begin
        unique case (uopcode)
            uopc::auipc  : brfn = brfnt::none;

            // should be taken care of in decode
            uopc::jal    : brfn = brfnt::none;
            uopc::jalr   : brfn = brfnt::jalr;

            uopc::beq    : brfn = brfnt::beq;
            uopc::bne    : brfn = brfnt::bne;
            uopc::blt    : brfn = brfnt::blt;
            uopc::bge    : brfn = brfnt::bge;
            uopc::bltu   : brfn = brfnt::bltu;
            uopc::bgeu   : brfn = brfnt::bgeu;

            default      : brfn = brfnt::none;
        endcase
    end


endmodule : bru_decode

module alu_imm_dec (
    input   logic [19:0]       packed_imm,
    input   immt::imm_type_t   imm_type,
    output  rv32i_word         imm
);

    logic sign;
    assign sign = packed_imm[19];

    assign imm[31]    = sign;
    assign imm[30:12] = imm_type == immt::u ? packed_imm[18:0] : {19{sign}};
    assign imm[11]    = imm_type == immt::u ? '0 : sign;
    assign imm[10:0]  = imm_type == immt::u ? '0 : packed_imm[18:8];

endmodule : alu_imm_dec

module jmp_imm_dec (
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
    assign imm[0]     = 1'b0;

endmodule : jmp_imm_dec

module imm_dec (
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

endmodule : imm_dec
