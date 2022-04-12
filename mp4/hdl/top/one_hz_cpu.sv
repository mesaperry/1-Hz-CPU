//`include "../../hvl/tb_itf.sv"
import rv32i_types::*;
import ctrl_sigs::*;
/*
typedef struct packed {//50
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
typedef struct packed {
    memfnt::mem_func_t memfn;
    memszt::mem_size_t memsz;
    ldextt::load_ext_t ldext;
} mem_ctrl_sigs_t;
typedef struct {
    alufnt::alu_func_t alufn;
    opr2t::operand2_t opr2;
} alu_ctrl_sigs_t;
*/

// TODO: actually important! jal and jalr
// need to store pc+4. jalr implementation may work
// already, but not tested. would prefer to fix it
// so it doesn't need another adder
// TODO: detect ret and call

module one_hz_cpu (
    input clk,
    input rst,
    output  rv32i_word   pc,
    input   rv32i_word   instr,
    output  logic        imem_read,
    input   logic        imem_resp,
    output  rv32i_word   mem_address,
    input   rv32i_word   mem_rdata,
    output  rv32i_word   mem_wdata,
    output  logic        mem_read,
    output  logic        mem_write,
    output  logic [3:0]  mem_byte_enable,
    input   logic        mem_resp
);

    //------------//
    //--- decl ---//
    //------------//

    //-- fetch0 --//
    rv32i_word pc_f0;

    logic taken_f0;


    //-- fetch1 --//
    rv32i_word pc_f1;

    logic taken_f1;

    logic [1:0] bht_resp_f1;
    btb_resp_t btb_resp_f1;
    rv32i_word nxl_target; // (next line or pc+4)
    rv32i_word btb_target;
    rv32i_word ras_target; // technically available in f0

    rv32i_word instr_f1;


    //-- decode --//
    rv32i_word pc_dc;

    logic taken_dc;

    logic [1:0] bht_resp_dc;

    rv32i_word instr_dc;

    logic dec_redir;
    rv32i_word dec_target;

    queue_item_t ctrl_sigs_dc;


    //-- rrd/issue --//
    rv32i_word pc_is;

    queue_item_t ctrl_sigs_is;

    alufnt::alu_func_t alufn_is;
    rv32i_word alu_opr1_is;
    rv32i_word alu_opr2_is;

    mem_ctrl_sigs_t lsu_ctrl_is;
    rv32i_word lsu_valu_is;
    rv32i_word lsu_base_is;
    rv32i_word lsu_ofst_is;

    brfnt::br_func_t brfn_is;
    rv32i_word bru_cmp1_is;
    rv32i_word bru_cmp2_is;
    rv32i_word bru_ofst_is;
    rv32i_word bru_add1_is;
    rv32i_word bru_add2_is;


    //-- execute --//

    // alu
    logic alu_has_rd_ex;
    logic [4:0] alu_rd_ex;
    alufnt::alu_func_t alufn_ex;
    rv32i_word alu_opr1_ex;
    rv32i_word alu_opr2_ex;

    rv32i_word alu_res_ex;

    // lsu
    logic lsu_has_rd_ex;
    logic [4:0] lsu_rd_ex;
    mem_ctrl_sigs_t lsu_ctrl_ex;
    rv32i_word lsu_valu_ex;
    rv32i_word lsu_base_ex;
    rv32i_word lsu_ofst_ex;

    rv32i_word lsu_res_ex;
    
    // bru
    rv32i_word pc_br;
    logic bru_has_rd_ex;
    logic [4:0] bru_rd_ex;
    brfnt::br_func_t brfn_ex;
    rv32i_word bru_cmp1_ex;
    rv32i_word bru_cmp2_ex;
    rv32i_word bru_ofst_ex;
    rv32i_word bru_add1_ex;
    rv32i_word bru_add2_ex;
    logic bru_taken_ex;

    logic bru_redir;
    rv32i_word bru_res_ex;
    rv32i_word bru_target;


    //-- writeback --//
    logic alu_has_rd_wb;
    logic [4:0] alu_rd_wb;
    rv32i_word alu_res_wb;
    
    logic lsu_has_rd_wb;
    logic [4:0] lsu_rd_wb;
    rv32i_word lsu_res_wb;
    
    logic bru_has_rd_wb;
    logic [4:0] bru_rd_wb;
    rv32i_word bru_res_wb;




    //------------//
    //--- impl ---//
    //------------//

    logic stall;

    //-- fetch0 --//
    assign imem_read = 1'b1;//~stall;

    // TODO: decide based on:
    // BHT entry (4 state)
    // BTB valid? ret? jmp?
    // decoded jal
    // branch unit resolution
    always_comb begin
        unique casez ({bru_redir, dec_redir, &bht_resp_dc, btb_resp_f1.valid, btb_resp_f1.is_ret, btb_resp_f1.is_jmp, &bht_resp_f1})
            // TODO: for branch resolution redirect, 
            // kill everything not in a functional unit
            7'b1?????? : {pc_f0, taken_f0} = {bru_target, 1'b0};
            // TODO: for decode redirect 
            // need to kill anything in fetch1
            // need to put taken tag in correct uopc
            7'b01????? : {pc_f0, taken_f0} = {dec_target, 1'b1};
            7'b001???? : {pc_f0, taken_f0} = {dec_target, 1'b1};
            7'b00011?? : {pc_f0, taken_f0} = {ras_target, 1'b1};
            7'b000101? : {pc_f0, taken_f0} = {btb_target, 1'b1};
            7'b0001001 : {pc_f0, taken_f0} = {btb_target, 1'b1};
            default    : {pc_f0, taken_f0} = {nxl_target, 1'b0};
        endcase
    end

    

    //-- fetch0 -> fetch1 --//

    rg #(
        .rst_val('X)
    )
    fetch1_pc_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(pc_f0),
        .dout(pc_f1)
    );

    // think taken_f0 should go directly to decode
    /*
    rg #(
        .size(1)
    )
    fetch1_taken_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(taken_f0),
        .dout(taken_f1)
    );
    */

    //-- fetch1 --//

    rg #(
        .rst_val(32'h00000060)
    )
    next_line_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(pc_f0 + 4),
        .dout(nxl_target)
    );

    always_ff @(posedge clk) begin
        bht_resp_f1 <= 2'b01;
        btb_resp_f1 <= '{1'b0, 1'b0, 1'b0, 1'b0};
        btb_target <= '0; // TODO: output from BTB
        ras_target <= '0; // TODO: output from RAS
    end

    // dummy 2 cycle pipelined icache
    assign pc = pc_f1;
    assign instr_f1 = instr;


    //-- fetch1 -> decode --//

    rg #(
        .rst_val('X)
    )
    decode_pc_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(pc_f1),
        .dout(pc_dc)
    );

    rg #(
        .size(1)
    )
    decode_taken_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(taken_f0),
        .dout(taken_dc)
    );

    rg #(
        .size(2)
    )
    decode_bht_resp_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(bht_resp_f1),
        .dout(bht_resp_dc)
    );

    rg #(
        .rst_val('X) // TODO: make a nop
    )
    decode_instr_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(instr_f1),
        .dout(instr_dc)
    );

    //-- decode --//

    DecodeControl dc0();

    assign dc0.instr = instr_dc;
    assign dc0.taken = taken_dc;
    // TODO: implement SFO
    assign dc0.under_shadow = 1'b0;

    decode_unit dec0 (
        .dc(dc0)
    );

    branch_target_calc btc0 (
        .pc(pc_dc),
        .dc(dc0)
    );

    assign dec_target = dc0.bctrl.is_jal ? dc0.jtarget : dc0.btarget;
    logic dec_says_take;
    assign dec_says_take = dc0.bctrl.is_jal;
    assign dec_redir = dec_says_take & ~taken_dc;


    assign ctrl_sigs_dc = '{
        dc0.ctrl.uopcode, 
        dc0.ctrl.exu_type,
        dc0.ctrl.has_rd, 
        dc0.ctrl.has_rs1, 
        dc0.ctrl.has_rs2,
        dc0.rd,
        dc0.rs1,
        dc0.rs2,
        dc0.ctrl.imm_type,
        dc0.packed_imm,
        dc0.taken,
        dc0.shadowed
    };

    logic is_nop_dc;
    assign is_nop_dc = dc0.ctrl.exu_type == exut::alu && dc0.rd == 5'b0;

    logic needs_pc_dc;
    assign needs_pc_dc = dc0.ctrl.exu_type == exut::jmp;

    //-- decode --(queue)-> rrd/issue --//

    logic push_iq0, pop_iq0, empty_iq0, full_iq0;
    logic push_pq0, pop_pq0, empty_pq0, full_pq0;

    assign stall = full_iq0 | full_pq0;

    assign push_iq0 = ~stall & ~is_nop_dc;
    assign push_pq0 = push_iq0 & needs_pc_dc;
    
    queue_item_t ctrl_sigs_iq;
    rv32i_word   pc_pq;

    instr_queue iq0 (
        .clk,
        .rst,
        .push(push_iq0),
        .pop(pop_iq0),
        .empty(empty_iq0),
        .full(full_iq0),
        .din(ctrl_sigs_dc),
        .dout(ctrl_sigs_iq)
    );

    pc_queue pc0 (
        .clk,
        .rst,
        .push(push_pq0),
        .pop(pop_pq0),
        .empty(empty_pq0),
        .full(full_pq0),
        .din(pc_dc),
        .dout(pc_is)
    );


    //-- rrd/issue --//
    queue_item_t nop_sigs;
    assign nop_sigs = '{uopc::addi, exut::alu, 1'b0, 1'b0, 1'b0, 5'b0, 5'b0, 5'b0, immt::i, 20'b0, 1'b0, 1'b0};
    assign ctrl_sigs_is = empty_iq0 ? nop_sigs : ctrl_sigs_iq;

    logic can_issue;

    scoreboard sb0 (
        .exu_type(ctrl_sigs_is.exu_type),
        .has_rd(ctrl_sigs_is.has_rd),
        .has_rs1(ctrl_sigs_is.has_rs1),
        .has_rs2(ctrl_sigs_is.has_rs2),
        .rd(ctrl_sigs_is.rd),
        .rs1(ctrl_sigs_is.rs1),
        .rs2(ctrl_sigs_is.rs2),
        .ready(can_issue)
    );

    logic needs_pc_is;
    assign needs_pc_is = ctrl_sigs_is.exu_type == exut::jmp;

    assign pop_iq0 = ~empty_iq0 & can_issue;
    // assuming will not be empty if needs pc
    assign pop_pq0 = pop_iq0 & needs_pc_is;

    rv32i_word rs1_out, rs2_out;

    regfile rf (
        .clk,
        .ld({alu_has_rd_wb, lsu_has_rd_wb, bru_has_rd_wb}),
        .dest('{alu_rd_wb, lsu_rd_wb, bru_rd_wb}),
        .in('{alu_res_wb, lsu_res_wb, bru_res_wb}),
        .src('{ctrl_sigs_is.rs1, ctrl_sigs_is.rs2}),
        .out('{rs1_out, rs2_out})
    );

    rv32i_word imm_out;

    imm_dec imm_dec0 (
        .packed_imm(ctrl_sigs_is.packed_imm),
        .imm_type(ctrl_sigs_is.imm_type),
        .imm(imm_out)
    );

    
    // alu setup
    logic is_lui;
    assign is_lui = ctrl_sigs_is.uopcode == uopc::lui;

    alu_ctrl_sigs_t alu_ctrl;
    alu_decode alu_dec0 (
        .uopcode(ctrl_sigs_is.uopcode),
        .ctrl(alu_ctrl)
    );

    assign alufn_is = alu_ctrl.alufn;
    assign alu_opr1_is = is_lui ? '0 : rs1_out;
    always_comb begin
        unique case (alu_ctrl.opr2)
            opr2t::rs2  : alu_opr2_is = rs2_out;
            opr2t::imm  : alu_opr2_is = imm_out;
        endcase
    end

    logic alu_has_rd_is;
    assign alu_has_rd_is = ctrl_sigs_is.exu_type == exut::alu && ctrl_sigs_is.has_rd;

    // mem setup
    mem_decode mem_dec0 (
        .uopcode(ctrl_sigs_is.uopcode),
        .ctrl(lsu_ctrl_is)
    );
    assign lsu_valu_is = rs2_out;
    assign lsu_base_is = rs1_out;
    assign lsu_ofst_is = imm_out;

    logic lsu_has_rd_is;
    assign lsu_has_rd_is = ctrl_sigs_is.exu_type == exut::mem && ctrl_sigs_is.has_rd;

    // bru setup
    logic is_auipc;
    assign is_auipc = ctrl_sigs_is.uopcode == uopc::auipc;
    logic is_br;
    // Assuming only branches will have b type imm
    assign is_br = ctrl_sigs_is.imm_type == immt::b;

    bru_decode bru_dec0 (
        .uopcode(ctrl_sigs_is.uopcode),
        .brfn(brfn_is)
    );
    assign bru_cmp1_is = rs1_out;
    assign bru_cmp2_is = rs2_out;
    assign bru_ofst_is = is_auipc | is_br ? imm_out : 4;
    assign bru_add1_is = rs1_out;
    assign bru_add2_is = imm_out;

    logic bru_has_rd_is;
    assign bru_has_rd_is = ctrl_sigs_is.exu_type == exut::jmp && ctrl_sigs_is.has_rd;


    //-- rrd/issue -> alu --//

    rg #(
        .size(1)
    )
    exec_alu_has_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(alu_has_rd_is),
        .dout(alu_has_rd_ex)
    );
    rg #(
        .size(5)
    )
    exec_alu_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(ctrl_sigs_is.rd),
        .dout(alu_rd_ex)
    );
    logic [$bits(alufnt::alu_func_t)-1:0] alufn_bits_ex;
    rg #(
        .size($bits(alufnt::alu_func_t))
    )
    alu_fn_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(alufn_is),
        .dout(alufn_bits_ex)
    );
    assign alufn_ex = alufnt::alu_func_t'(alufn_bits_ex);
    rg alu_opr1_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(alu_opr1_is),
        .dout(alu_opr1_ex)
    );
    rg alu_opr2_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(alu_opr2_is),
        .dout(alu_opr2_ex)
    );

    //-- alu --//

    alu alu0 (
        .fn(alufn_ex),
        .in1(alu_opr1_ex),
        .in2(alu_opr2_ex),
        .out(alu_res_ex)
    );

    //-- alu -> writeback --//

    rg #(
        .size(1)
    )
    wb_alu_has_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(alu_has_rd_ex),
        .dout(alu_has_rd_wb)
    );
    rg #(
        .size(5)
    )
    wb_alu_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(alu_rd_ex),
        .dout(alu_rd_wb)
    );
    rg wb_alu_res_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(alu_res_ex),
        .dout(alu_res_wb)
    );

    //-- writeback (alu) --//

    // TODO: updata scoreboard



    //-- rrd/issue -> lsu --//

    rg #(
        .size(1)
    )
    agu_has_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(lsu_has_rd_is),
        .dout(lsu_has_rd_ex)
    );
    rg #(
        .size(5)
    )
    agu_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(ctrl_sigs_is.rd),
        .dout(lsu_rd_ex)
    );
    logic [$bits(mem_ctrl_sigs_t)-1:0] lsu_ctrl_bits_ex;
    rg #(
        .size($bits(mem_ctrl_sigs_t))
    )
    agu_mem_ctrl_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(lsu_ctrl_is),
        .dout(lsu_ctrl_bits_ex)
    );
    assign lsu_ctrl_ex = mem_ctrl_sigs_t'(lsu_ctrl_bits_ex);
    rg agu_mem_val_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(lsu_valu_is),
        .dout(lsu_valu_ex)
    );
    rg agu_mem_base_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(lsu_base_is),
        .dout(lsu_base_ex)
    );
    rg agu_mem_ofst_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(lsu_ofst_is),
        .dout(lsu_ofst_ex)
    );

    //-- lsu --//

    // agu
    logic agu_has_rd_ex;
    logic [4:0] agu_rd_ex;
    mem_ctrl_sigs_t agu_ctrl_ex;
    rv32i_word agu_valu_ex;
    rv32i_word agu_base_ex;
    rv32i_word agu_ofst_ex;

    rv32i_word agu_addr_ex;
    logic [3:0] agu_mbe_ex;

    assign agu_has_rd_ex = lsu_has_rd_ex;
    assign agu_rd_ex = lsu_rd_ex;
    assign agu_ctrl_ex = lsu_ctrl_ex;
    assign agu_valu_ex = lsu_valu_ex;
    assign agu_base_ex = lsu_base_ex;
    assign agu_ofst_ex = lsu_ofst_ex;

    assign agu_addr_ex = agu_base_ex + agu_ofst_ex;

    mbe_gen mbe_gen0 (
        .ctrl(agu_ctrl_ex),
        .addr(agu_addr_ex),
        .mbe(agu_mbe_ex)
    );

    // agu -> mem
    logic mem_has_rd_ex;
    logic [4:0] mem_rd_ex;
    mem_ctrl_sigs_t mem_ctrl_ex;
    rv32i_word mem_valu_ex;
    rv32i_word mem_addr_ex;
    logic [3:0] mem_mbe_ex;

    rg #(
        .size(1)
    )
    mem_has_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(agu_has_rd_ex),
        .dout(mem_has_rd_ex)
    );
    rg #(
        .size(5)
    )
    mem_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(agu_rd_ex),
        .dout(mem_rd_ex)
    );
    rg #(
        .size($bits(mem_ctrl_sigs_t))
    )
    mem_mem_ctrl_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(agu_ctrl_ex),
        .dout(mem_ctrl_ex)
    );
    rg mem_mem_val_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(agu_valu_ex),
        .dout(mem_valu_ex)
    );
    rg mem_mem_addr_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(agu_addr_ex),
        .dout(mem_addr_ex)
    );
    rg #(
        .size(4)
    ) 
    mem_mbe_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(agu_mbe_ex),
        .dout(mem_mbe_ex)
    );

    // mem access

    rv32i_word mem_res_ex;
    assign mem_byte_enable = mem_mbe_ex;
    assign mem_address = mem_addr_ex;
    assign mem_wdata = mem_valu_ex;
    assign mem_read = mem_ctrl_ex.memfn[1];
    assign mem_write = mem_ctrl_ex.memfn[0];

    // TODO: modulize
    always_comb begin
        unique case ({mem_ctrl_ex.memsz, mem_ctrl_ex.ldext})
            {memszt::b, ldextt::s} : mem_res_ex = {{24{mem_rdata[07]}}, mem_rdata[07:0]};
            {memszt::b, ldextt::z} : mem_res_ex = { 24'b0,              mem_rdata[07:0]};
            {memszt::h, ldextt::s} : mem_res_ex = {{16{mem_rdata[15]}}, mem_rdata[15:0]};
            {memszt::h, ldextt::z} : mem_res_ex = { 16'b0,              mem_rdata[15:0]};
            default                : mem_res_ex =                       mem_rdata;
        endcase
    end


    // TODO: if no resp, unit busy

    assign lsu_res_ex = mem_res_ex;
    

    //-- lsu -> writeback --//

    rg #(
        .size(1)
    )
    wb_lsu_has_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(mem_has_rd_ex),
        .dout(lsu_has_rd_wb)
    );
    rg #(
        .size(5)
    )
    wb_lsu_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(mem_rd_ex),
        .dout(lsu_rd_wb)
    );
    rg wb_lsu_res_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(lsu_res_ex),
        .dout(lsu_res_wb)
    );

    //-- writeback (lsu) --//

    // TODO: updata scoreboard


    



    //-- rrd/issue -> bru --//

    rg bru_pc_reg (
        .clk,
        .rst,
        .ld(1'b1), // bru is pipelined so never busy
        .din(pc_is),
        .dout(pc_br)
    );
    rg #(
        .size(1)
    )
    exec_bru_has_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_has_rd_is),
        .dout(bru_has_rd_ex)
    );
    rg #(
        .size(5)
    )
    exec_bru_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(ctrl_sigs_is.rd),
        .dout(bru_rd_ex)
    );
    logic [$bits(brfnt::br_func_t)-1:0] brfn_bits_ex;
    rg #(
        .size($bits(brfnt::br_func_t))
    )
    bru_fn_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(brfn_is),
        .dout(brfn_bits_ex)
    );
    assign brfn_ex = brfnt::br_func_t'(brfn_bits_ex);
    rg bru_cmp1_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_cmp1_is),
        .dout(bru_cmp1_ex)
    );
    rg bru_cmp2_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_cmp2_is),
        .dout(bru_cmp2_ex)
    );
    rg bru_ofst_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_ofst_is),
        .dout(bru_ofst_ex)
    );
    rg bru_add1_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_add1_is),
        .dout(bru_add1_ex)
    );
    rg bru_add2_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_add2_is),
        .dout(bru_add2_ex)
    );
    rg #(
        .size(1)
    )
    bru_taken_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(ctrl_sigs_is.taken),
        .dout(bru_taken_ex)
    );

    //-- bru --//

    // TODO: modulize
    logic eq;
    logic lt;
    logic ltu;
    assign eq  = bru_cmp1_ex == bru_cmp2_ex;
    assign lt  = $signed(bru_cmp1_ex) <  $signed(bru_cmp2_ex);
    assign ltu = bru_cmp1_ex <  bru_cmp2_ex;

    assign bru_res_ex = pc_br + bru_ofst_ex;
    rv32i_word jalr_target;
    assign jalr_target = bru_add1_ex + bru_add2_ex;

    logic is_jalr;
    assign is_jalr = brfn_ex == brfnt::jalr;

    assign bru_target = is_jalr ? jalr_target : bru_res_ex;

    logic bru_says_take;

    always_comb begin
        unique case (brfn_ex)
            brfnt::beq  : bru_says_take = eq;
            brfnt::bne  : bru_says_take = !eq;
            brfnt::blt  : bru_says_take = lt;
            brfnt::bge  : bru_says_take = !lt;
            brfnt::bltu : bru_says_take = ltu;
            brfnt::bgeu : bru_says_take = !ltu;
            brfnt::jalr : bru_says_take = 1'b1;
            default     : bru_says_take = 1'b0;
        endcase
    end

    assign bru_redir = bru_says_take & ~bru_taken_ex;



    //-- bru -> writeback --//

    rg #(
        .size(1)
    )
    wb_bru_has_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_has_rd_ex),
        .dout(bru_has_rd_wb)
    );
    rg #(
        .size(5)
    )
    wb_bru_rd_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_rd_ex),
        .dout(bru_rd_wb)
    );
    rg wb_bru_res_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(bru_res_ex),
        .dout(bru_res_wb)
    );

    //-- writeback (alu) --//

    // TODO: updata scoreboard







endmodule : one_hz_cpu

module pc_queue (
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    output logic empty,
    output logic full,
    input rv32i_word din,
    output rv32i_word dout
);

    logic [31:02] pc3102;
    fifo30x4 fifo (
        .clock(clk),
        .data(din[31:02]),
        .rdreq(pop),
        .sclr(rst),
        .wrreq(push),
        .empty(empty),
        .full(full),
        .q(pc3102)
    );

    assign dout = {pc3102, 2'b00};

endmodule : pc_queue

module instr_queue (
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    output logic empty,
    output logic full,
    input queue_item_t din,
    output queue_item_t dout
);

    fifo50x8 fifo (
        .clock(clk),
        .data(din),
        .rdreq(pop),
        .sclr(rst),
        .wrreq(push),
        .empty(empty),
        .full(full),
        .q(dout)
    );

endmodule : instr_queue




module scoreboard (
    input exut::exe_unit_type_t exu_type,
    input logic has_rd,
    input logic has_rs1,
    input logic has_rs2,
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    output logic ready
);

    assign ready = 1'b1;

endmodule : scoreboard


module dummy_queue #(
    parameter size = 32
)
(
    input clk,
    input rst,
    input   logic            push_front,
    input   logic            pop_back,
    output  logic            empty,
    output  logic            full,
    input   logic [size-1:0] din,
    output  logic [size-1:0] dout
);
    
    always_ff @(posedge clk) begin
        if (rst) begin
            empty <= 1'b1;
            full <= 1'b0;
        end
        else if (push_front) begin
            empty <= 1'b0;
            full <= 1'b1;
        end
        else if (pop_back) begin // and not push_front
            empty <= 1'b1;
            full <= 1'b0;
        end
    end

    rg #(
        size
    ) 
    q (
        .clk,
        .rst(rst | (pop_back & ~push_front)),
        .ld(push_front),
        .din,
        .dout
    );

endmodule : dummy_queue

module rg #(
    parameter size = 32,
    parameter rst_val = '0
)
(
    input clk,
    input rst,
    input ld,
    input   logic [size-1:0] din,
    output  logic [size-1:0] dout
);

    always_ff @(posedge clk) begin
        if (rst) dout <= rst_val;
        else if (ld) dout <= din;
    end

endmodule : rg


module dummyBTB (
    input clk,
    input rst,

    input   logic [28:0]   new_PC,
    input   logic [29:0]   new_target,
    input   logic [1:0]    new_btype,
    input   logic          load,

    input   logic [28:0]   fetch_PC,

    output  logic [29:0]   target,
    output  logic [1:0]    btype, // TODO: make enum
    output  logic          hit
);

    assign hit = 1'b0;


endmodule : dummyBTB

module dummyBHT (
    input clk,
    input rst,

    input   logic [31:0]   pc,
    output  logic should_take,
    output  logic confidence
);

    assign should_take = 1'b0;
    assign confidence = 1'b0;


endmodule : dummyBHT
