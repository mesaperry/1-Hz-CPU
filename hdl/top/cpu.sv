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
    ExecuteControl ec0();

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
    assign exe_redir = ((ec0.taken != exe_says_take) & ec0.is_br) | 
                       (ec0.is_jalr & !ec0.taken);
    logic [1:0] exe_btype;
    rv32i_word exe_pc;
    rv32i_word exe_target_pc;
    rv32i_word exe_redir_pc;
    assign exe_target_pc = alu_out;
    assign exe_redir_pc = exe_says_take | ec0.is_jalr ? exe_target_pc : exe_pc + 4;
    
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
        dc0.shadowed
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
            ec.uopcode <= uopc::add;
            ec.exu_type <= exut::alu;
            ec.rd <= '0;
            ec.rs1 <= '0;
            ec.rs2 <= '0;
            ec.imm_type <= immt::r;
            ec.taken <= '0;
            ec.shadowed <= '0;
        end
        else if (ready) begin
            ec.uopcode <= aluqdout.uopcode;
            ec.exu_type <= exut::alu;
            ec.rd <= '0;
            ec.rs1 <= '0;
            ec.rs2 <= '0;
            ec.imm_type <= immt::r;
            ec.taken <= '0;
            ec.shadowed <= '0;
        end
    end




    


    // exec





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
