import rv32i_types::*;

module mem_decode (
    MemoryControl mc
);

    always_comb begin
        unique case (mc.uopcode)
            uopc::lb  : mc.ctrl = '{memfnt::ld, memszt::b, ldextt::s};
            uopc::lh  : mc.ctrl = '{memfnt::ld, memszt::h, ldextt::s};
            uopc::lw  : mc.ctrl = '{memfnt::ld, memszt::w, ldextt::s};
            uopc::lbu : mc.ctrl = '{memfnt::ld, memszt::b, ldextt::z};
            uopc::lhu : mc.ctrl = '{memfnt::ld, memszt::h, ldextt::z};

            uopc::sb  : mc.ctrl = '{memfnt::st, memszt::b, ldextt::load_ext_t'('X)};
            uopc::sh  : mc.ctrl = '{memfnt::st, memszt::h, ldextt::load_ext_t'('X)};
            uopc::sw  : mc.ctrl = '{memfnt::st, memszt::w, ldextt::load_ext_t'('X)};

            default   : mc.ctrl = '{memfnt::nm, memszt::mem_size_t'('X), ldextt::load_ext_t'('X)};
        endcase
    end

endmodule : mem_decode


module mbe_gen (
    MemoryControl mc
);
    
    always_comb begin
        unique casez ({mc.ctrl.memsz, mc.addr[1:0]})
            {memszt::b, 2'b00} : mc.mbe = 4'b0001;
            {memszt::b, 2'b01} : mc.mbe = 4'b0010;
            {memszt::b, 2'b10} : mc.mbe = 4'b0100;
            {memszt::b, 2'b11} : mc.mbe = 4'b1000;

            {memszt::h, 2'b0?} : mc.mbe = 4'b0011;
            {memszt::h, 2'b1?} : mc.mbe = 4'b1100;

            {memszt::w, 2'b??} : mc.mbe = 4'b1111;
            default            : mc.mbe = 4'b0000;
        endcase
    end

endmodule : mbe_gen


module mem_imm_dec (
    input   logic [19:0]       packed_imm,
    output  rv32i_word         imm
);

    logic sign;
    assign sign = packed_imm[19];

    assign imm[31:11] = {21{sign}};
    assign imm[10:0]  = packed_imm[18:8];

endmodule : mem_imm_dec
