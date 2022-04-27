import rv32i_types::*;
import ctrl_sigs::*;

module mem_decode (
    input uopc::micro_opcode_t uopcode,
    output mem_ctrl_sigs_t ctrl
);

    always_comb begin
        unique case (uopcode)
            uopc::lb  : ctrl = '{memfnt::ld, memszt::b, ldextt::s};
            uopc::lh  : ctrl = '{memfnt::ld, memszt::h, ldextt::s};
            uopc::lw  : ctrl = '{memfnt::ld, memszt::w, ldextt::s};
            uopc::lbu : ctrl = '{memfnt::ld, memszt::b, ldextt::z};
            uopc::lhu : ctrl = '{memfnt::ld, memszt::h, ldextt::z};

            uopc::sb  : ctrl = '{memfnt::st, memszt::b, ldextt::load_ext_t'('X)};
            uopc::sh  : ctrl = '{memfnt::st, memszt::h, ldextt::load_ext_t'('X)};
            uopc::sw  : ctrl = '{memfnt::st, memszt::w, ldextt::load_ext_t'('X)};

            default   : ctrl = '{memfnt::nm, memszt::mem_size_t'('X), ldextt::load_ext_t'('X)};
        endcase
    end

endmodule : mem_decode


module mbe_gen (
    input mem_ctrl_sigs_t ctrl,
    input rv32i_word addr,
    output logic [3:0] mbe
);
    
    always_comb begin
        unique casez ({ctrl.memsz, addr[1:0]})
            {memszt::b, 2'b00} : mbe = 4'b0001;
            {memszt::b, 2'b01} : mbe = 4'b0010;
            {memszt::b, 2'b10} : mbe = 4'b0100;
            {memszt::b, 2'b11} : mbe = 4'b1000;

            {memszt::h, 2'b0?} : mbe = 4'b0011;
            {memszt::h, 2'b1?} : mbe = 4'b1100;

            {memszt::w, 2'b??} : mbe = 4'b1111;
            default            : mbe = 4'b0000;
        endcase
    end

endmodule : mbe_gen

module mem_wdata_align (
    input rv32i_word addr,
    input rv32i_word data_ualgn,
    output rv32i_word data_algn
);

    always_comb begin
        unique case (addr[1:0])
            2'b01   : data_algn = {data_ualgn[23:0], 8'b0};
            2'b10   : data_algn = {data_ualgn[15:0], 16'b0};
            2'b11   : data_algn = {data_ualgn[7:0], 24'b0};
            default : data_algn = data_ualgn;
        endcase
    end

endmodule : mem_wdata_align


module mem_imm_dec (
    input   logic [19:0]       packed_imm,
    output  rv32i_word         imm
);

    logic sign;
    assign sign = packed_imm[19];

    assign imm[31:11] = {21{sign}};
    assign imm[10:0]  = packed_imm[18:8];

endmodule : mem_imm_dec
