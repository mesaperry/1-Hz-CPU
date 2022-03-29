import rv32i_types::*;

module top (
    input   clk,
    input   rv32i_word instr,
    input   rv32i_word pc,
    input   logic under_shadow,

    output  uopc::micro_opcode_t uopcode,
    output  iqt::queue_type_t iq_type,
    output  exut::exe_unit_type_t exu_type,
    output  logic has_rd,
    output  logic has_rs1,
    output  logic has_rs2,
    output  immt::imm_type_t imm_type,
    output  logic is_br,
    output  logic is_jal,
    output  logic is_jalr,
    output  logic shadowed,

    output  logic [19:0] packed_imm
);


    CTRLWord cw();
    always_ff @(posedge clk)
    begin
        cw.instr <= instr;
        cw.pc <= pc;
        cw.under_shadow <= under_shadow;
    end
    assign uopcode = cw.ctrl.uopcode;
    assign iq_type = cw.ctrliq_type;
    assign exu_type = cw.ctrl.exu_type;
    assign has_rd = cw.ctrl.has_rd;
    assign has_rs1 = cw.ctrl.has_rs1;
    assign has_rs2 = cw.ctrl.has_rs2;
    assign imm_type = cw.ctrl.imm_type;
    assign is_br = cw.bctrl.is_br;
    assign is_jal = cw.bctrl.is_jal;
    assign is_jalr = cw.bctrl.is_jalr;
    assign shadowed = cw.shadowed;
    assign packed_imm = cw.packed_imm;

    decode_unit dec_inst (.*);

endmodule : top
