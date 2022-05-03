//`include "../../hvl/tb_itf.sv"
import rv32i_types::*;
import ctrl_sigs::*;


module one_hz_cpu (
    input clk,
    input rst,
    output  rv32i_word   pc,
    input   rv32i_word   inst_rdata,
    output  logic        inst_read,
    input   logic        inst_resp,
    output  rv32i_word   data_address,
    input   rv32i_word   data_rdata,
    output  rv32i_word   data_wdata,
    output  logic        data_read,
    output  logic        data_write,
    output  logic [3:0]  data_mbe,
    input   logic        data_resp
);

    
    localparam start_addr = 32'h00000060;
    localparam nop_inst = 32'h00000013;

    //------------//
    //--- decl ---//
    //------------//

    //-- fetch0 --//
    rv32i_word pc_f0;
    logic [9:0] bh_f0;
    logic hold_redir;
    rv32i_word hold_target;
    logic [9:0] hold_bh_snap;


    //-- fetch1 --//
    rv32i_word pc_f1;
    logic [9:0] bh_f1;

    logic taken_f1;

    logic [1:0] bht_resp_f1;
    btb_resp_t btb_resp_f1;
    rv32i_word nxl_target; // (next line or pc+4)
    rv32i_word btb_target;
    rv32i_word ras_target; // technically available in f0

    rv32i_word instr_f1;
    logic instr_valid_f1;
    logic is_br_f1;


    //-- decode --//
    rv32i_word pc_dc;
    logic [1:0] bht_resp_dc;
    logic [9:0] bh_dc;

    logic taken_dc;

    rv32i_word instr_dc;
    logic instr_valid_dc;

    logic dec_redir;
    rv32i_word dec_target;

    queue_item_t ctrl_sigs_dc;

    DecodeControl dc0();


    //-- rrd/issue --//
    rv32i_word pc_is;
    logic [1:0] bht_resp_is;
    logic [9:0] bh_is;

    queue_item_t ctrl_sigs_is;

    alufnt::alu_func_t alufn_is;

    mem_ctrl_sigs_t lsu_ctrl_is;

    brfnt::br_func_t brfn_is;


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

    logic mem_stall;
    rv32i_word lsu_res_ex;
    
    // bru
    rv32i_word pc_br;
    logic [1:0] bru_bht_resp_ex;
    logic bru_has_rd_ex;
    logic [4:0] bru_rd_ex;
    brfnt::br_func_t brfn_ex;
    rv32i_word bru_cmp1_ex;
    rv32i_word bru_cmp2_ex;
    rv32i_word bru_base_ex;
    rv32i_word bru_ofst_ex;
    rv32i_word bru_add1_ex;
    logic bru_taken_ex;
    logic [9:0] bru_bh_ex;

    logic bru_redir;
    logic bru_is_br;
    logic [1:0] bru_bht_update;
    rv32i_word bru_res_ex;
    rv32i_word bru_target;
    logic [9:0] bru_bh_snap;


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
    logic mispred;
    assign mispred = bru_redir;

    //-- fetch0 --//
    assign inst_read = ~stall;
    assign pc = pc_f0;

    logic bht_says_take_f1;
    assign bht_says_take_f1 = bht_resp_f1[1];

    always_comb begin
        unique casez ({
            inst_resp,
            hold_redir,
            bru_redir, 
            dec_redir, 
            btb_resp_f1.valid, 
            btb_resp_f1.is_ret, 
            btb_resp_f1.is_jmp, 
            bht_says_take_f1
        })
            // FIXME: currently, the cache is sensitive to changing
            // addresses, so we prioritize stalling to wait for 
            // the fetch over changing pc to respond to a prediction
            8'b0??????? : {pc_f0, taken_f1} = {pc_f1,      1'b0};
            8'b11?????? : {pc_f0, taken_f1} = {hold_target,1'b0};
            8'b101????? : {pc_f0, taken_f1} = {bru_target, 1'b0};
            8'b1001???? : {pc_f0, taken_f1} = {dec_target, 1'b0};
            8'b100011?? : {pc_f0, taken_f1} = {ras_target, 1'b1};
            8'b1000101? : {pc_f0, taken_f1} = {btb_target, 1'b1};
            8'b10001001 : {pc_f0, taken_f1} = {btb_target, 1'b1};
            default     : {pc_f0, taken_f1} = {nxl_target, 1'b0};
        endcase
    end


    always_ff @(posedge clk) begin
        if (rst) begin
            hold_redir <= 1'b0;
            hold_target <= start_addr;
            hold_bh_snap <= 10'b0;
        end
        else if (mispred & ~inst_resp) begin
            hold_redir <= 1'b1;
            hold_target <= bru_target;
            hold_bh_snap <= bru_bh_snap;
        end
        else if (hold_redir & inst_resp) begin
            hold_redir <= 1'b0;
            hold_target <= bru_target;
            hold_bh_snap <= bru_bh_snap;
        end
    end



    always_comb begin
        unique casez ({
            inst_resp,
            hold_redir,
            bru_redir,
            dec_redir & dc0.bctrl.is_br,
            is_br_f1
        })
            // FIXME: currently, the cache is sensitive to changing
            // addresses, so we prioritize stalling to wait for 
            // the fetch over changing pc to respond to a prediction
            5'b11??? : bh_f0 = hold_bh_snap;
            5'b101?? : bh_f0 = bru_bh_snap;
            5'b1001? : bh_f0 = {bh_f1, 1'b1};
            5'b10001 : bh_f0 = {bh_f1[8:0], bht_says_take_f1};
            default  : bh_f0 = bh_f1;
        endcase
    end

    dummyBTB btb (
        .clk,
        .rst,
        .new_pc(),
        .new_target(),
        .new_type(),
        .load(1'b0),
        .pc(pc_f0),
        .target(btb_target),
        .resp(btb_resp_f1)
    );

    BHT bht (
        .clk,
        .rst,
        .read_pc(pc_f0),
        .read_bh(bh_f0),
        .pred(bht_resp_f1),
        .write(bru_is_br),
        .write_pc(pc_br),
        .write_bh(bru_bh_ex),
        .update(bru_bht_update)
    );
    //assign bht_resp_f1 = 2'b01;
    

    //-- fetch0 -> fetch1 --//

    rg #(
        .rst_val(start_addr)
    )
    fetch1_pc_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(pc_f0),
        .dout(pc_f1)
    );
    rg #(
        .size(10)
    )
    fetch1_bh_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(bh_f0),
        .dout(bh_f1)
    );

    assign nxl_target = pc_f1 + 4;

    //-- fetch1 --//

    always_ff @(posedge clk) begin
        ras_target <= '0; // TODO: output from RAS
    end

    // we need this to update branch history.
    // we don't have to read from instr_f1, because if there's a dec_redir,
    // that already takes priority when assigning bh_f0
    assign is_br_f1 = inst_resp ? inst_rdata[6:2] == 5'b11000 : 1'b0;

    // fetch1 instruction becomes a nop if there was a decode redirect
    assign instr_f1 = inst_rdata;

    assign instr_valid_f1 = ~(dec_redir | ~inst_resp | hold_redir);


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
        .size(10)
    )
    decode_bh_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(bh_f1),
        .dout(bh_dc)
    );
    rg #(
        .size(1)
    )
    decode_taken_reg (
        .clk,
        .rst,
        .ld(~stall),
        .din(taken_f1),
        .dout(taken_dc)
    );
    rg #(
        .size(2)
    )
    decode_bht_resp_reg (
        .clk,
        .rst(rst | mispred),
        .ld(~stall),
        .din(bht_resp_f1),
        .dout(bht_resp_dc)
    );
    rg #(
        .rst_val(nop_inst)
    )
    decode_instr_reg (
        .clk,
        .rst(rst | mispred),
        .ld(~stall),
        .din(instr_f1),
        .dout(instr_dc)
    );
    rg #(
        .size(1)
    )
    decode_instr_valid_reg (
        .clk,
        .rst(rst | mispred),
        .ld(~stall),
        .din(instr_valid_f1),
        .dout(instr_valid_dc)
    );
    rg #(
        .size(1)
    )
    decode_is_br_reg (
        .clk,
        .rst(rst | mispred),
        .ld(~stall),
        .din(is_br_f1),
        .dout(dc0.bctrl.is_br)
    );

    //-- decode --//

    // TODO: detect ret and call

    assign dc0.instr = instr_dc;
    // TODO: implement SFO
    assign dc0.under_shadow = 1'b0;

    decode_unit dec0 (
        .dc(dc0)
    );

    branch_target_calc btc0 (
        .pc(pc_dc),
        .dc(dc0)
    );

    assign dc0.bctrl.is_jal = dc0.opcode[6:2] == 5'b11011;

    assign dec_target = dc0.bctrl.is_jal ? dc0.jtarget : dc0.btarget;
    logic dec_says_take;
    // decode says take if:
    // instruction is a jal
    // the bht says strongly taken
    // instruction is a branch, the bht doesn't say strongly not taken,
    // and the immediate sign is negative (loops)
    // that loop check isn't amazing for fmax
    // assuming bht will never say strongly taken for a non jmp instruction
    assign dec_says_take = ((dc0.bctrl.is_jal)
                         | (dc0.bctrl.is_br & bht_resp_dc[1])
                         | (dc0.bctrl.is_br & |bht_resp_dc & instr_dc[31]))
                         & instr_valid_dc;
    assign dec_redir = dec_says_take & ~taken_dc;
    // anded with inst_resp, because if we are committed to 
    // waiting for a resp, then we can't do a dec_redir
    assign dc0.taken = (dec_says_take & inst_resp) | taken_dc;

    // do sfo if we're only skipping one instruction
    logic is_sf;
    assign is_sf = ({dc0.instr[31], dc0.instr[7], dc0.instr[30:25], dc0.instr[11:8]} == 12'h004) & instr_valid_dc;
    logic is_sf_br;
    assign is_sf_br = dc0.bctrl.is_br & |bht_resp_dc & is_sf;


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

    logic needs_pc_dc;
    assign needs_pc_dc = dc0.ctrl.exu_type == exut::jmp;

    //-- decode --(queue)-> rrd/issue --//

    logic push_iq0, pop_iq0, empty_iq0, full_iq0;
    logic push_pq0, pop_pq0, empty_pq0, full_pq0;

    assign stall = full_iq0 | full_pq0;

    assign push_iq0 = ~stall & instr_valid_dc;
    assign push_pq0 = push_iq0 & needs_pc_dc;
    
    queue_item_t ctrl_sigs_iq;

    instr_queue iq0 (
        .clk,
        .rst(rst | mispred),
        .push(push_iq0),
        .pop(pop_iq0),
        .empty(empty_iq0),
        .full(full_iq0),
        .din(ctrl_sigs_dc),
        .dout(ctrl_sigs_iq)
    );

    pc_queue pq0 (
        .clk,
        .rst(rst | mispred),
        .push(push_pq0),
        .pop(pop_pq0),
        .empty(empty_pq0),
        .full(full_pq0),
        .pc_in(pc_dc),
        .bh_in(bh_dc),
        .pred_in(bht_resp_dc),
        .pc_out(pc_is),
        .bh_out(bh_is),
        .pred_out(bht_resp_is)
    );

    // synthesis translate_off
    logic [79:0] debug_sigs_dc;
    logic [79:0] debug_sigs_is;
    assign debug_sigs_dc = {
        dc0.instr,
        ~dc0.ctrl.legal,
        dc0.rs1,
        dc0.rs2,
        dc0.ctrl.has_rd ? dc0.rd : 5'b0,
        pc_dc
    };
    logic [7:0] level;
    rvfi_dc_is rq0 (
        .clk,
        .rst(rst | mispred),
        .push(push_iq0),
        .pop(pop_iq0),
        .level,
        .rvfi_dc(debug_sigs_dc),
        .rvfi_is(debug_sigs_is)
    );
    // synthesis translate_on

    //-- rrd/issue --//
    queue_item_t nop_sigs;
    assign nop_sigs = '{
        uopc::addi, 
        exut::alu, 
        1'b0, 1'b0, 1'b0, 
        5'b0, 5'b0, 5'b0, 
        immt::i, 
        20'b0, 
        1'b0, 
        1'b0
    };


    // PERF: do as much as possible to use ctrl_sigs_iq instead of
    // ctrl_sigs_rd and especially ctrl_sigs_is
    // WARNING: queue output (ctrl_sigs_iq, can be don't cares if empty)
    queue_item_t ctrl_sigs_rd;
    assign ctrl_sigs_rd = empty_iq0 ? nop_sigs : ctrl_sigs_iq;
    fwdsel::fwd_sel_t rs1_sel_is, rs2_sel_is;
    logic [4:0] lsu_rd_fwd, bru_rd_fwd, mul_rd_fwd, alu_rd_fwd;
    assign lsu_rd_fwd = 5'b0;
    assign mul_rd_fwd = 5'b0;

    logic can_issue;

    scoreboard sb0 (
        .clk,
        .rst,
        .mispred,
        .exu_type('{ctrl_sigs_rd.exu_type}),
        .has_rd(ctrl_sigs_rd.has_rd),
        .has_rs1(ctrl_sigs_rd.has_rs1),
        .has_rs2(ctrl_sigs_rd.has_rs2),
        .rd('{ctrl_sigs_iq.rd}),
        .rs1('{ctrl_sigs_iq.rs1}),
        .rs2('{ctrl_sigs_iq.rs2}),
        .ready('{can_issue}),
        .rs1_sel('{rs1_sel_is}),
        .rs2_sel('{rs2_sel_is}),
        .has_rd_wb({alu_has_rd_wb, lsu_has_rd_wb, bru_has_rd_wb}),
        .rd_wb('{alu_rd_wb, lsu_rd_wb, bru_rd_wb}),
        .exu_fwd('{lsu_rd_fwd, bru_rd_fwd, mul_rd_fwd, alu_rd_fwd}),
        .exu_status({mem_stall, 1'b0, 1'b1, 1'b0}) // TODO: fix when implementing mul
    );

    assign ctrl_sigs_is = can_issue ? ctrl_sigs_rd : nop_sigs;

    logic needs_pc_is;
    assign needs_pc_is = ctrl_sigs_iq.exu_type == exut::jmp;

    assign pop_iq0 = ~empty_iq0 & can_issue;
    // assuming will not be empty if needs pc
    assign pop_pq0 = ~empty_pq0 & can_issue & needs_pc_is;


    rv32i_word rgf_rs1_is, rgf_rs2_is;
    regfile rf (
        .clk,
        .rst,
        .ld({alu_has_rd_wb, lsu_has_rd_wb, bru_has_rd_wb}),
        .dest('{alu_rd_wb, lsu_rd_wb, bru_rd_wb}),
        .in('{alu_res_wb, lsu_res_wb, bru_res_wb}),
        .src('{ctrl_sigs_iq.rs1, ctrl_sigs_iq.rs2}),
        .out('{rgf_rs1_is, rgf_rs2_is})
    );

    rv32i_word imm_out_is;

    imm_dec imm_dec0 (
        .packed_imm(ctrl_sigs_iq.packed_imm),
        .imm_type(ctrl_sigs_iq.imm_type),
        .imm(imm_out_is)
    );

    // TODO: transfer reg outs and fwd_sels to exe, 
    // and do the operand selection logic in exe
    
    // alu setup
    logic is_lui_is;
    assign is_lui_is = ctrl_sigs_iq.uopcode == uopc::lui;

    alu_ctrl_sigs_t alu_ctrl;
    alu_decode alu_dec0 (
        .uopcode(ctrl_sigs_iq.uopcode),
        .ctrl(alu_ctrl)
    );

    assign alufn_is = alu_ctrl.alufn;

    logic alu_has_rd_is;
    assign alu_has_rd_is = ctrl_sigs_is.exu_type == exut::alu && ctrl_sigs_is.has_rd;

    opr2t::operand2_t alu_opr2_sel_is;
    assign alu_opr2_sel_is = alu_ctrl.opr2;

    // mem setup
    mem_decode mem_dec0 (
        .uopcode(ctrl_sigs_is.uopcode),
        .ctrl(lsu_ctrl_is)
    );

    logic lsu_has_rd_is;
    assign lsu_has_rd_is = ctrl_sigs_is.exu_type == exut::mem && ctrl_sigs_is.has_rd;

    // bru setup
    logic is_jalr_is;
    assign is_jalr_is = ctrl_sigs_iq.uopcode == uopc::jalr;

    logic is_auipc_is;
    assign is_auipc_is = ctrl_sigs_iq.uopcode == uopc::auipc;

    bru_decode bru_dec0 (
        .uopcode(ctrl_sigs_is.uopcode),
        .brfn(brfn_is)
    );

    logic bru_has_rd_is;
    assign bru_has_rd_is = ctrl_sigs_is.exu_type == exut::jmp && ctrl_sigs_is.has_rd;

    //-- rrd/issue -> execute (shared) --//
    rv32i_word rgf_rs1_ex, rgf_rs2_ex;
    rv32i_word imm_out_ex;
    fwdsel::fwd_sel_t rs1_sel_ex, rs2_sel_ex;

    rg exec_rs1_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(rgf_rs1_is),
        .dout(rgf_rs1_ex)
    );
    rg exec_rs2_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(rgf_rs2_is),
        .dout(rgf_rs2_ex)
    );
    rg exec_imm_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(imm_out_is),
        .dout(imm_out_ex)
    );
    logic [$bits(fwdsel::fwd_sel_t)-1:0] rs1_sel_bits_ex;
    rg #(
        .size($bits(fwdsel::fwd_sel_t))
    )
    exec_rs1_sel_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(rs1_sel_is),
        .dout(rs1_sel_bits_ex)
    );
    assign rs1_sel_ex = fwdsel::fwd_sel_t'(rs1_sel_bits_ex);
    logic [$bits(fwdsel::fwd_sel_t)-1:0] rs2_sel_bits_ex;
    rg #(
        .size($bits(fwdsel::fwd_sel_t))
    )
    exec_rs2_sel_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(rs2_sel_is),
        .dout(rs2_sel_bits_ex)
    );
    assign rs2_sel_ex = fwdsel::fwd_sel_t'(rs2_sel_bits_ex);


    //-- execute (shared) --//
    rv32i_word rs1_out, rs2_out;

    always_comb begin
        unique case (rs1_sel_ex)
            fwdsel::alu : rs1_out = alu_res_wb;
            fwdsel::mul : rs1_out = 'X;
            fwdsel::bru : rs1_out = bru_res_wb;
            fwdsel::lsu : rs1_out = 'X;
            default     : rs1_out = rgf_rs1_ex;
        endcase
    end
    always_comb begin
        unique case (rs2_sel_ex)
            fwdsel::alu : rs2_out = alu_res_wb;
            fwdsel::mul : rs2_out = 'X;
            fwdsel::bru : rs2_out = bru_res_wb;
            fwdsel::lsu : rs2_out = 'X;
            default     : rs2_out = rgf_rs2_ex;
        endcase
    end

    //-- rrd/issue -> alu --//

    rg #(
        .size(1)
    )
    exec_alu_has_rd_reg (
        .clk,
        .rst(rst | mispred),
        .ld(1'b1),
        .din(alu_has_rd_is),
        .dout(alu_has_rd_ex)
    );
    rg #(
        .size(5)
    )
    exec_alu_rd_reg (
        .clk,
        .rst(rst | mispred),
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
        .rst(rst | mispred),
        .ld(1'b1),
        .din(alufn_is),
        .dout(alufn_bits_ex)
    );
    assign alufn_ex = alufnt::alu_func_t'(alufn_bits_ex);
    logic is_lui_ex;
    rg #(
        .size(1)
    )
    alu_is_lui_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(is_lui_is),
        .dout(is_lui_ex)
    );
    opr2t::operand2_t alu_opr2_sel_ex;
    logic [$bits(opr2t::operand2_t)-1:0] alu_opr2_sel_bits_ex;
    rg #(
        .size($bits(opr2t::operand2_t))
    )
    alu_opr2_sel_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(alu_opr2_sel_is),
        .dout(alu_opr2_sel_bits_ex)
    );
    assign alu_opr2_sel_ex = opr2t::operand2_t'(alu_opr2_sel_bits_ex);

    //-- alu --//
    assign alu_opr1_ex = is_lui_ex ? '0 : rs1_out;
    always_comb begin
        unique case (alu_opr2_sel_ex)
            opr2t::rs2  : alu_opr2_ex = rs2_out;
            opr2t::imm  : alu_opr2_ex = imm_out_ex;
            default     : alu_opr2_ex = imm_out_ex;
        endcase
    end

    alu alu0 (
        .fn(alufn_ex),
        .in1(alu_opr1_ex),
        .in2(alu_opr2_ex),
        .out(alu_res_ex)
    );

    assign alu_rd_fwd = alu_rd_ex;

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




    //-- rrd/issue -> lsu --//

    rg #(
        .size(1)
    )
    agu_has_rd_reg (
        .clk,
        .rst(rst | (mispred & ~mem_stall)),
        .ld(~mem_stall),
        .din(lsu_has_rd_is),
        .dout(lsu_has_rd_ex)
    );
    rg #(
        .size(5)
    )
    agu_rd_reg (
        .clk,
        .rst(rst | (mispred & ~mem_stall)),
        .ld(~mem_stall),
        .din(ctrl_sigs_is.rd),
        .dout(lsu_rd_ex)
    );
    logic [$bits(mem_ctrl_sigs_t)-1:0] lsu_ctrl_bits_ex;
    rg #(
        .size($bits(mem_ctrl_sigs_t))
        // assuming reset value is zero, which causes "nm" mem op
    )
    agu_mem_ctrl_reg (
        .clk,
        .rst(rst | (mispred & ~mem_stall)),
        .ld(~mem_stall),
        .din(lsu_ctrl_is),
        .dout(lsu_ctrl_bits_ex)
    );
    assign lsu_ctrl_ex = mem_ctrl_sigs_t'(lsu_ctrl_bits_ex);

    //-- lsu --//

    // agu

    rv32i_word lsu_valu_hold;
    rv32i_word lsu_base_hold;
    rv32i_word lsu_ofst_hold;

    logic rmem_stall;
    always_ff @(posedge clk) begin
        rmem_stall <= mem_stall;
    end

    rg agu_mem_valu_hold_reg (
        .clk,
        .rst(1'b0),
        .ld(~rmem_stall),
        .din(rs2_out),
        .dout(lsu_valu_hold)
    );
    rg agu_mem_base_hold_reg (
        .clk,
        .rst(1'b0),
        .ld(~rmem_stall),
        .din(rs1_out),
        .dout(lsu_base_hold)
    );
    rg agu_mem_ofst_hold_reg (
        .clk,
        .rst(1'b0),
        .ld(~rmem_stall),
        .din(imm_out_ex),
        .dout(lsu_ofst_hold)
    );

    // TODO: probably need to hold on 
    assign lsu_valu_ex = rmem_stall ? lsu_valu_hold : rs2_out;
    assign lsu_base_ex = rmem_stall ? lsu_base_hold : rs1_out;
    assign lsu_ofst_ex = rmem_stall ? lsu_ofst_hold : imm_out_ex;


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
    assign agu_base_ex = lsu_base_ex;
    assign agu_ofst_ex = lsu_ofst_ex;

    assign agu_addr_ex = agu_base_ex + agu_ofst_ex;

    mbe_gen mbe_gen0 (
        .ctrl(agu_ctrl_ex),
        .addr(agu_addr_ex),
        .mbe(agu_mbe_ex)
    );

    mem_wdata_align mem_wdata_align0 (
        .addr(agu_addr_ex),
        .data_ualgn(lsu_valu_ex),
        .data_algn(agu_valu_ex)
    );

    // agu -> mem
    logic mem_has_rd_ex;
    logic [4:0] mem_rd_ex;
    mem_ctrl_sigs_t mem_ctrl_ex;
    rv32i_word mem_valu_ex;
    rv32i_word mem_addr_ex;
    logic [3:0] mem_mbe_ex;

    logic mem_busy;
    assign mem_busy = |mem_ctrl_ex.memfn;
    assign mem_stall = mem_busy & ~data_resp;

    assign data_mbe = mem_stall ? mem_mbe_ex : agu_mbe_ex;
    assign data_address = {mem_stall ? mem_addr_ex[31:2] : agu_addr_ex[31:2], 2'b0};
    assign data_wdata = mem_stall ? mem_valu_ex : agu_valu_ex;
    assign data_read = mem_stall ? mem_ctrl_ex.memfn[1] : agu_ctrl_ex.memfn[1];
    assign data_write = mem_stall ? mem_ctrl_ex.memfn[0] : agu_ctrl_ex.memfn[0];

    rg #(
        .size(1)
    )
    mem_has_rd_reg (
        .clk,
        .rst,
        .ld(~mem_stall),
        .din(agu_has_rd_ex),
        .dout(mem_has_rd_ex)
    );
    rg #(
        .size(5)
    )
    mem_rd_reg (
        .clk,
        .rst,
        .ld(~mem_stall),
        .din(agu_rd_ex),
        .dout(mem_rd_ex)
    );
    rg #(
        .size($bits(mem_ctrl_sigs_t))
        // assuming reset value is zero, which causes "nm" mem op
    )
    mem_mem_ctrl_reg (
        .clk,
        .rst,
        .ld(~mem_stall),
        .din(agu_ctrl_ex),
        .dout(mem_ctrl_ex)
    );
    rg mem_mem_val_reg (
        .clk,
        .rst,
        .ld(~mem_stall),
        .din(agu_valu_ex),
        .dout(mem_valu_ex)
    );
    rg mem_mem_addr_reg (
        .clk,
        .rst,
        .ld(~mem_stall),
        .din(agu_addr_ex),
        .dout(mem_addr_ex)
    );
    rg #(
        .size(4)
    ) 
    mem_mbe_reg (
        .clk,
        .rst,
        .ld(~mem_stall),
        .din(agu_mbe_ex),
        .dout(mem_mbe_ex)
    );

    // mem access

    rv32i_word mem_res_ex;


    // TODO: modulize
    /*
    always_comb begin
        unique casez ({mem_ctrl_ex.memsz, mem_ctrl_ex.ldext, mem_addr_ex[1:0]})
            {memszt::b, ldextt::s, 2'b00} : mem_res_ex = {{24{data_rdata[07]}}, data_rdata[07:0]};
            {memszt::b, ldextt::s, 2'b01} : mem_res_ex = {{24{data_rdata[15]}}, data_rdata[15:8]};
            {memszt::b, ldextt::s, 2'b10} : mem_res_ex = {{24{data_rdata[23]}}, data_rdata[23:16]};
            {memszt::b, ldextt::s, 2'b11} : mem_res_ex = {{24{data_rdata[31]}}, data_rdata[31:24]};
            {memszt::b, ldextt::z, 2'b00} : mem_res_ex = { 24'b0,               data_rdata[07:0]};
            {memszt::b, ldextt::z, 2'b01} : mem_res_ex = { 24'b0,               data_rdata[15:8]};
            {memszt::b, ldextt::z, 2'b10} : mem_res_ex = { 24'b0,               data_rdata[23:16]};
            {memszt::b, ldextt::z, 2'b11} : mem_res_ex = { 24'b0,               data_rdata[31:24]};
            {memszt::h, ldextt::s, 2'b0?} : mem_res_ex = {{16{data_rdata[15]}}, data_rdata[15:0]};
            {memszt::h, ldextt::s, 2'b1?} : mem_res_ex = {{16{data_rdata[31]}}, data_rdata[31:16]};
            {memszt::h, ldextt::z, 2'b0?} : mem_res_ex = { 16'b0,               data_rdata[15:0]};
            {memszt::h, ldextt::z, 2'b1?} : mem_res_ex = { 16'b0,               data_rdata[31:16]};
            default                       : mem_res_ex =                        data_rdata;
        endcase
    end
    */

    always_comb begin
        unique casez ({mem_ctrl_ex.memsz, mem_ctrl_ex.ldext})
            {memszt::b, ldextt::s} : mem_res_ex = 32'(signed'(data_rdata[mem_addr_ex[1:0]*8 +: 8]));
            {memszt::b, ldextt::z} : mem_res_ex = 32'(data_rdata[mem_addr_ex[1:0]*8 +: 8]);
            {memszt::h, ldextt::s} : mem_res_ex = 32'(signed'(data_rdata[mem_addr_ex[1:0]*16 +: 16]));
            {memszt::h, ldextt::z} : mem_res_ex = 32'(data_rdata[mem_addr_ex[1:0]*16 +: 16]);
            default                : mem_res_ex =                        data_rdata;
        endcase
    end


    assign lsu_res_ex = mem_res_ex;
    

    //-- lsu -> writeback --//

    rg #(
        .size(1)
    )
    wb_lsu_has_rd_reg (
        .clk,
        .rst(rst | ~data_resp),
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
        .ld(~mem_stall),
        .din(mem_rd_ex),
        .dout(lsu_rd_wb)
    );
    rg wb_lsu_res_reg (
        .clk,
        .rst,
        .ld(~mem_stall),
        .din(lsu_res_ex),
        .dout(lsu_res_wb)
    );

    //-- writeback (lsu) --//


    



    //-- rrd/issue -> bru --//

    rg bru_pc_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1), // bru is pipelined so never busy
        .din(pc_is),
        .dout(pc_br)
    );
    rg #(
        .size(10)
    )
    bru_bh_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1), // bru is pipelined so never busy
        .din(bh_is),
        .dout(bru_bh_ex)
    );
    rg #(
        .size(1)
    )
    exec_bru_has_rd_reg (
        .clk,
        .rst(rst | mispred),
        .ld(1'b1),
        .din(bru_has_rd_is),
        .dout(bru_has_rd_ex)
    );
    rg #(
        .size(5)
    )
    exec_bru_rd_reg (
        .clk,
        .rst(rst | mispred),
        .ld(1'b1),
        .din(ctrl_sigs_is.rd),
        .dout(bru_rd_ex)
    );
    logic [$bits(brfnt::br_func_t)-1:0] brfn_bits_ex;
    rg #(
        .size($bits(brfnt::br_func_t)),
        // should correspond to "none" brfn
        .rst_val(3'b111)
    )
    bru_fn_reg (
        .clk,
        .rst(rst | mispred),
        .ld(1'b1),
        .din(brfn_is),
        .dout(brfn_bits_ex)
    );
    assign brfn_ex = brfnt::br_func_t'(brfn_bits_ex);
    rg #(
        .size(1)
    )
    bru_taken_reg (
        .clk,
        .rst(rst | mispred),
        .ld(1'b1),
        .din(ctrl_sigs_is.taken),
        .dout(bru_taken_ex)
    );
    rg #(
        .size(2)
    )
    bru_bht_resp_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(bht_resp_is),
        .dout(bru_bht_resp_ex)
    );
    logic is_jalr_ex;
    rg #(
        .size(1)
    )
    bru_is_jalr_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(is_jalr_is),
        .dout(is_jalr_ex)
    );
    logic is_auipc_ex;
    rg #(
        .size(1)
    )
    bru_is_auipc_reg (
        .clk,
        .rst(1'b0),
        .ld(1'b1),
        .din(is_auipc_is),
        .dout(is_auipc_ex)
    );

    //-- bru --//
    assign bru_cmp1_ex = rs1_out;
    assign bru_cmp2_ex = rs2_out;
    assign bru_base_ex = is_jalr_ex ? rs1_out : pc_br;
    assign bru_ofst_ex = imm_out_ex;
    assign bru_add1_ex = is_auipc_ex ? imm_out_ex : 4;

    // TODO: modulize
    logic eq;
    logic lt;
    logic ltu;
    assign eq  = bru_cmp1_ex == bru_cmp2_ex;
    assign lt  = $signed(bru_cmp1_ex) <  $signed(bru_cmp2_ex);
    assign ltu = bru_cmp1_ex <  bru_cmp2_ex;

    assign bru_res_ex = pc_br + bru_add1_ex;

    rv32i_word bru_jmp_target;
    rv32i_word bru_no_jmp_target;
    assign bru_jmp_target = bru_base_ex + bru_ofst_ex;
    assign bru_no_jmp_target = pc_br + 4;

    logic bru_says_take;

    always_comb begin
        unique case (brfn_ex)
            brfnt::beq  : {bru_says_take, bru_is_br} = {eq,   1'b1};
            brfnt::bne  : {bru_says_take, bru_is_br} = {!eq,  1'b1};
            brfnt::blt  : {bru_says_take, bru_is_br} = {lt,   1'b1};
            brfnt::bge  : {bru_says_take, bru_is_br} = {!lt,  1'b1};
            brfnt::bltu : {bru_says_take, bru_is_br} = {ltu,  1'b1};
            brfnt::bgeu : {bru_says_take, bru_is_br} = {!ltu, 1'b1};
            brfnt::jal  : {bru_says_take, bru_is_br} = {1'b1, 1'b0};
            default     : {bru_says_take, bru_is_br} = {1'b0, 1'b0};
        endcase
    end

    assign bru_redir = bru_says_take ^ bru_taken_ex;
    assign bru_target = bru_says_take 
                      ? bru_jmp_target 
                      : bru_no_jmp_target;
    assign bru_bh_snap = bru_is_br 
                       ? {bru_bh_ex[8:0], bru_says_take}
                       : bru_bh_ex;

    always_comb begin
        unique case ({bru_bht_resp_ex, bru_says_take})
            3'b000 : bru_bht_update = 2'b00;
            3'b001 : bru_bht_update = 2'b01;
            3'b010 : bru_bht_update = 2'b00;
            3'b011 : bru_bht_update = 2'b10;
            3'b100 : bru_bht_update = 2'b01;
            3'b101 : bru_bht_update = 2'b11;
            3'b110 : bru_bht_update = 2'b10;
            3'b111 : bru_bht_update = 2'b11;
            default : bru_bht_update = 2'b01;
        endcase
    end

    assign bru_rd_fwd = bru_rd_ex;


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




endmodule : one_hz_cpu

module pc_queue (
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    output logic empty,
    output logic full,
    input rv32i_word pc_in,
    input logic [9:0] bh_in,
    input logic [1:0] pred_in,
    output rv32i_word pc_out,
    output logic [9:0] bh_out,
    output logic [1:0] pred_out
);

    fifo42x4 fifo (
        .clock(clk),
        .data({pc_in[31:02], bh_in, pred_in}),
        .rdreq(pop),
        .sclr(rst),
        .wrreq(push),
        .empty(empty),
        .full(full),
        .q({pc_out[31:02], bh_out, pred_out})
    );

    assign pc_out[1:0] = 2'b00;

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

module rvfi_dc_is (
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    output logic [7:0] level,
    input logic [79:0] rvfi_dc,
    output logic [79:0] rvfi_is
);

    logic [19:0] unused;

    fifo100x8_n fifo (
        .clock(clk),
        .data({20'b0, rvfi_dc}),
        .rdreq(pop),
        .sclr(rst),
        .wrreq(push),
        .q({unused, rvfi_is}),
        .usedw(level[2:0])
    );
    assign level[7:3] = '0;

endmodule : rvfi_dc_is

module scoreboard #(
    parameter s_index = 5,
    parameter num_read_ports = 1,
    parameter num_write_ports = 3,
    parameter num_execution_units = 4,
    parameter nrp = num_read_ports,
    parameter nwp = num_write_ports,
    parameter neu = num_execution_units,
    parameter eu_idx_sz = $clog2(neu)
)
(
    input   logic                  clk,
    input   logic                  rst,
    input   logic                  mispred,
    input   logic [eu_idx_sz-1:0]  exu_type [nrp-1:0],
    input   logic [nrp-1:0]        has_rd,
    input   logic [nrp-1:0]        has_rs1,
    input   logic [nrp-1:0]        has_rs2,
    input   logic [s_index-1:0]    rd  [nrp-1:0],
    input   logic [s_index-1:0]    rs1 [nrp-1:0],
    input   logic [s_index-1:0]    rs2 [nrp-1:0],
    output  logic                  ready [nrp-1:0],
    output  fwdsel::fwd_sel_t      rs1_sel [nrp-1:0],                
    output  fwdsel::fwd_sel_t      rs2_sel [nrp-1:0],                

    input   logic [nwp-1:0]        has_rd_wb,
    input   logic [s_index-1:0]    rd_wb [nwp-1:0],
    input   logic [s_index-1:0]    exu_fwd [neu-1:0],
    input   logic [neu-1:0]        exu_status

);

    localparam num_regs = 2**s_index;
    localparam s_write_sel = $clog2(nwp);
    localparam swl = s_write_sel;

    logic reg_states [num_regs];
    logic [eu_idx_sz-1:0] reg_locs [num_regs];

    genvar rp;
    generate
        for (rp = 0; rp < nrp; rp++) begin : reads
            assign ready[rp] = ~(
                // guess it doesn't hurt to "forward" rd?
                ((reg_states[rd[rp]]) & has_rd)   |
                ((reg_states[rs1[rp]] & ~(exu_fwd[reg_locs[rs1[rp]]] == rs1[rp])) & has_rs1) | 
                ((reg_states[rs2[rp]] & ~(exu_fwd[reg_locs[rs2[rp]]] == rs2[rp])) & has_rs2) | 
                (exu_status[exu_type[rp]])      
            );
        end
        for (rp = 0; rp < nrp; rp++) begin : sel_gen
            assign rs1_sel[rp] = reg_states[rs1[rp]] ? fwdsel::fwd_sel_t'({1'b0, reg_locs[rs1[rp]]}) : fwdsel::rgf;
            assign rs2_sel[rp] = reg_states[rs2[rp]] ? fwdsel::fwd_sel_t'({1'b0, reg_locs[rs2[rp]]}) : fwdsel::rgf;
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < num_regs; i++) begin
                reg_states[i] <= 1'b0;
            end
        end else begin
            for (int i = 0; i < nrp; i++) begin
                if (ready[i] & ~mispred & rd[i] != '0) begin
                    reg_states[rd[i]] <= has_rd[i];
                    reg_locs[rd[i]] <= exu_type[i];
                end
            end
            for (int i = 0; i < nwp; i++) begin
                if (has_rd_wb[i]) begin
                    reg_states[rd_wb[i]] <= 1'b0;
                end
            end
        end
    end

endmodule : scoreboard


module dummyBTB (
    input clk,
    input rst,

    input   logic [31:0]   new_pc,
    input   logic [31:0]   new_target,
    input   btb_resp_t     new_type,
    input   logic          load,

    input   logic [31:0]   pc,

    output  logic [31:0]   target,
    output  btb_resp_t     resp
);

    logic [31:0] pc_out;
    rg pc_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(pc),
        .dout(pc_out)
    );
    always_comb begin
        if (pc_out == 32'h140) begin
            resp = '{1'b0, 1'b0, 1'b0, 1'b0};
            target = 32'h218;
        end
        else begin
            resp = '{1'b0, 1'b0, 1'b0, 1'b0};
            target = 32'hX;
        end
    end


endmodule : dummyBTB


module BHT (
    input clk,
    input rst,

    input   logic [31:0]   read_pc,
    input   logic [9:0]    read_bh,
    output  logic [1:0]    pred,

    input   logic          write,
    input   logic [31:0]   write_pc,
    input   logic [9:0]    write_bh,
    input   logic [1:0]    update
);

    bram2x1024_2p bht_store (
        .clock     (clk),
        .data      (update),
        .rdaddress (read_pc[11:2] ^ read_bh),
        .wraddress (write_pc[11:2] ^ write_bh),
        .wren      (write),
        .q         (pred)
    );

endmodule : BHT


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

