import rv32i_types::*;

module one_hz_cpu (
    input clk,
    input rst,
    output  rv32i_word   pc,
    input   rv32i_word   instr,
    output  logic        imem_read,
    input   logic        imem_resp,
    output  rv32i_word   mem_address,
    output  rv32i_word   mem_rdata,
    input   rv32i_word   mem_wdata,
    output  logic        mem_read,
    output  logic        mem_write,
    output  logic [3:0]  mem_byte_enable,
    input   logic        mem_resp
);

    DecodeControl dc0();
    ExecuteControl rc0();
    ExecuteControl ec0();
    ExecuteControl wc0();

    // decode redirect
    logic dec_says_take;
    logic dec_confident;
    logic dec_redir;
    assign dec_redir = ((dc0.taken != dec_says_take) & dc0.bctrl.is_br & dec_confident) | 
                       (dc0.bctrl.is_jal & !dc0.taken);
    rv32i_word dec_pc;
    rv32i_word dec_target_pc;
    rv32i_word dec_redir_pc;
    assign dec_target_pc = dc0.bctrl.is_jal ? dc0.jtarget : dc0.btarget;
    assign dec_redir_pc = dec_says_take | dc0.bctrl.is_jal ? dec_target_pc : dec_pc + 4;


    // exe redirect
    logic exe_says_take;
    logic exe_redir;
    assign exe_redir = ((ec0.taken != exe_says_take) & ec0.ctrl.brfn[2:1] != 2'b11) | 
                       (ec0.ctrl.brfn == brfnt::jalr & !ec0.taken);
    logic [1:0] exe_btype;
    rv32i_word exe_pc;
    rv32i_word exe_target_pc;
    rv32i_word exe_redir_pc;
    assign exe_target_pc = alu_out;
    assign exe_redir_pc = exe_says_take ? exe_target_pc : exe_pc + 4;
    
    // fetch
    logic fetch_pc;
    assign pc = fetch_pc;
    rv32i_word npc;
    rv32i_word btb_target_pc;
    rv32i_word nextline_pc;
    logic btb_hit;

    assign nextline_pc = fetch_pc + 4;

    always_comb begin
        unique casez ({btb_hit, dec_redir, exe_redir})
            3'b??1  : npc = exe_target_pc;
            3'b?10  : npc = dec_redir_pc; 
            3'b100  : npc = btb_target_pc;
            default : npc = nextline_pc;
        endcase
    end

    // TODO: only load for jal, jalr, and confident br
    dummyBTB BTB (
        .clk,
        .rst,
        .new_PC(exe_redir ? exe_pc : dec_pc),
        .new_target(exe_redir ? exe_redir_pc : dec_redir_pc),
        // TODO: fix, definitely not right
        .new_btype(exe_redir ? exe_btype : {cw.bctrl.is_br, cw.bctrl.is_jal}),
        .load(exe_redir | dec_redir),

        .fetch_PC(fetch_pc),
        .target(btb_target_pc),
        .hit(btb_hit)
    );
    
    rg fetch_pc_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(npc),
        .dout(fetch_pc)
    );
    

    // fetch -> decode
    rg dec_pc_reg (
        .clk,
        .rst,
        .ld(1'b1),
        .din(fetch_pc),
        .dout(dec_pc)
    );
    assign dc0.under_shadow = 1'b0; // TODO: SFO
    assign dc0.instr = instr;


    // decode

    decode_unit dec0 (
        .dc(dc0)
    );

    branch_target_calc btc (
        .pc(dec_pc),
        .dc(dc0)
    );

    // 2 stage. starts in fetch. uses bram
    // result arrives in decode.
    dummyBHT (
        .clk,
        .rst,
        .pc(fetch_pc),
        .should_take(dec_says_take),
        .confidence(dec_confident)
    );

    // dispatch 
    // trying to shove in same cycle as decode
    logic aluqpush,  memqpush;
    logic aluqpop,   memqpop;
    logic aluqempty, memqempty;
    logic aluqfull,  memqfull;
    queue_item_t aluqdin,  memqdin;
    queue_item_t aluqdout, memqdout;

    queue_item_t dec_out;

    assign dec_out = '{
        dc0.ctrl.uopcode, 
        dc0.ctrl.exu_type, 
        dc0.ctrl.has_rd, 
        dc0.ctrl.has_rs1, 
        dc0.ctrl.has_rs2,
        dc0.ctrl.imm_type,
        dc0.packed_imm,
        dc0.taken,
        dc0.shadowed,
        dec_pc
    };

    assign aluqdin = dec_out;
    assign memqdin = dec_out;

    assign imem_read = !(aluqfull | memqfull);

    assign aluqpush = !aluqfull & dc0.ctrl.iq_type == iqt::alu;
    assign memqpush = !memqfull & dc0.ctrl.iq_type == iqt::mem;

    dummy_queue #(
        $bits(queue_item_t)
    )
    aluq (
        .clk,
        .rst,
        .push_front(aluqpush),
        .pop_back(aluqpop),
        .empty(aluqempty),
        .full(aluqfull),
        .din(aluqdin),
        .dout(aluqdout)
    );
    
    dummy_queue #(
        $bits(queue_item_t)
    )
    memq (
        .clk,
        .rst,
        .push_front(memqpush),
        .pop_back(memqpop),
        .empty(memqempty),
        .full(memqfull),
        .din(memqdin),
        .dout(memqdout)
    );

    // rrd
    
    always_comb begin
        if (aluqempty) begin
            rc0.uopcode <= uopc::add;
            rc0.exu_type <= exut::alu;
            rc0.rd <= '0;
            rc0.rs1 <= '0;
            rc0.rs2 <= '0;
            rc0.imm_type <= immt::r;
            rc0.packed_imm <= '0;
            rc0.taken <= '0;
            rc0.shadowed <= '0;
            rc0.pc <= '0;
        end
        else if (ready) begin
            rc0.uopcode <= aluqdout.uopcode;
            rc0.exu_type <= aluqdout.exu_type;
            rc0.rd <= aluqdout.rd;
            rc0.rs1 <= aluqdout.rs1;
            rc0.rs2 <= aluqdout.rs2;
            rc0.imm_type <= aluqdout.imm_type;
            rc0.packed_imm <= aluqdout.packed_imm;
            rc0.taken <= aluqdout.taken;
            rc0.shadowed <= aluqdout.shadowed;
            rc0.pc <= aluqdout.pc;
        end
    end

    exe_decode(.ec(rc0));
    alu_imm_dec imm_dec (
        .packed_imm(rc0.packed_imm),
        .imm_type(rc0.imm_type),
        .imm(rc0.imm)
    );

    
    rv32i_word reg_a, reg_b;

    regfile rf (
        .clk,
        .prefer_a(1'b1),
        .ld_a(wc0.has_rd),
        .ld_b(0),
        .dest_a(wc0.rd),
        .dest_b('0),
        .in_a(alu_out_wb),
        .in_b(0),
        .src_a(rc0.rs1),
        .src_b(rc0.rs2),
        .reg_a,
        .reg_b
    );

    rv32i_word reg_a_exe;
    rv32i_word reg_b_exe;

    // rrd -> exec
    always_ff @(posedge clk) begin
        ec0.uopcode <= rc0.uopcode;
        ec0.exu_type <= rc0.exu_type;
        ec0.has_rd <= rc0.has_rd;
        ec0.has_rs1 <= rc0.has_rs1;
        ec0.has_rs2 <= rc0.has_rs2;
        ec0.rd <= rc0.rd;
        ec0.rs1 <= rc0.rs1;
        ec0.rs2 <= rc0.rs2;
        ec0.taken <= rc0.taken;
        ec0.shadowed <= rc0.shadowed;
        ec0.pc <= rc0.pc;
        ec0.ctrl <= rc0.ctrl;
        ec0.imm <= rc0.imm;
        reg_a_exe <= reg_a;
        reg_b_exe <= reg_b;
    end

    // exec
    rv32i_word operand1;
    rv32i_word operand2;
    
    always_comb begin
        unique case (ec0.ctrl.opr1)
            opr1t::rs1  : operand1 = reg_a_exe;
            opr1t::pc   : operand1 = ec0.pc;
            opr1t::zero : operand1 = '0;
        endcase
    end

    always_comb begin
        unique case (ec0.ctrl.opr2)
            opr2t::rs2  : operand2 = reg_b_exe;
            opr2t::imm  : operand2 = ec0.imm;
        endcase
    end

    rv32i_word alu_out;

    //
    alu alu_inst (
        .fn(ec0.ctrl.alufn),
        .in1(operand1),
        .in2(operand2),
        .out(alu_out)
    );

    logic eq;
    logic lt;
    logic ltu;
    assign eq  = reg_a_exe == reg_b_exe;
    assign lt  = reg_a_exe <  reg_b_exe;
    assign ltu = $signed(reg_a_exe) <  $signed(reg_b_exe);

    always_comb begin
        unique case (ec0.ctrl.brfn)
            brfnt::beq  : exe_says_take = eq;
            brfnt::bne  : exe_says_take = !eq;
            brfnt::blt  : exe_says_take = lt;
            brfnt::bge  : exe_says_take = !lt;
            brfnt::bltu : exe_says_take = ltu;
            brfnt::bgeu : exe_says_take = !ltu;
            brfnt::jalr : exe_says_take = 1'b1;
            default     : exe_says_take = 1'bX;
        endcase
    end


    // exec -> wb
    rv32i_word alu_out_wb;
    always_ff @(posedge clk) begin
        alu_out_wb <= alu_out;
        wc0.has_rd <= ec0.has_rd;
        wc0.has_rs1 <= ec0.has_rs1;
        wc0.has_rs2 <= ec0.has_rs2;
        wc0.rd <= ec0.rd;
        wc0.rs1 <= ec0.rs1;
        wc0.rs2 <= ec0.rs2;
        wc0.shadowed <= ec0.shadowed;
    end

    // wb
    // TODO: set registers to unused
    

 







endmodule : one_hz_cpu

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
    output  logic            ready,
    input   logic [size-1:0] din,
    output  logic [size-1:0] dout
);
    
    assign ready = ~empty;
    always_ff @(posedge clk) begin
        if (rst | pop) begin
            empty <= 1'b1;
            full <= 1'b0;
        end
        else if (push) begin
            empty <= 1'b0;
            full <= 1'b1;
        end
    end

    rg #(
        size
    ) 
    q (
        .clk,
        .rst(rst | pop),
        .ld(push),
        .din,
        .dout
    );

endmodule : dummy_queue

module rg #(
    parameter size = 32
)
(
    input clk,
    input rst,
    input ld,
    input   logic [size-1:0] din,
    output  logic [size-1:0] dout
);

    always_ff @(posedge clk) begin
        if (rst) dout <= '0;
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
