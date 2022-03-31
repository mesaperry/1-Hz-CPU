//`include "../ctrl_word.sv"
//`include "../../hvl/tb_itf.sv"
import rv32i_types::*;
typedef struct packed {
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
    rv32i_word pc;
} queue_item_t;

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

    DecodeControl dc0();
    ExecuteControl arc0();
    ExecuteControl aec0();
    ExecuteControl awc0();
    MemoryControl mrc0();
    MemoryControl mmc0();
    MemoryControl mwc0();

    regfile rf (
        .clk,
        .ld({awc0.has_rd, mwc0.has_rd}),
        .dest('{awc0.rd, mwc0.rd}),
        .in('{awc0.alu_out, mwc0.mem_out}),
        .src('{arc0.rs1, arc0.rs2, mrc0.rs1, mrc0.rs2}),
        .out('{arc0.reg_a, arc0.reg_b, mrc0.reg_a, mrc0.reg_b})
    );

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
    assign exe_redir = ((aec0.taken != exe_says_take) & aec0.ctrl.brfn[2:1] != 2'b11) | 
                       (aec0.ctrl.brfn == brfnt::jalr & !aec0.taken);
    logic [1:0] exe_btype;
    rv32i_word exe_pc;
    assign exe_pc = aec0.pc;
    rv32i_word exe_target_pc;
    rv32i_word exe_redir_pc;
    assign exe_target_pc = aec0.alu_out;
    assign exe_redir_pc = exe_says_take ? exe_target_pc : exe_pc + 4;
    
    // fetch
    rv32i_word fetch_pc;
    assign pc = fetch_pc;
    rv32i_word npc;
    rv32i_word btb_target_pc;
    rv32i_word nextline_pc;
    logic btb_hit;

    assign nextline_pc = imem_read ? fetch_pc + 4 : fetch_pc;

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
        .new_btype(exe_redir ? exe_btype : {dc0.bctrl.is_br, dc0.bctrl.is_jal}),
        .load(exe_redir | dec_redir),

        .fetch_PC(fetch_pc),
        .target(btb_target_pc),
        .btype(),
        .hit(btb_hit)
    );
    
    rg #(
        .rst_val(32'h00000060)
    )
    fetch_pc_reg (
        .clk,
        .rst,
        .ld(1'b1), // TODO: maybe should be imem_resp
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
    rg dec_instr_reg0 (
        .clk,
        .rst,
        .ld(1'b1),
        .din(instr),
        .dout(dc0.instr)
    );
    rg dec_taken_reg0 (
        .clk,
        .rst,
        .ld(1'b1),
        .din(btb_hit),
        .dout(dc0.taken)
    );
    assign dc0.under_shadow = 1'b0; // TODO: SFO
    


    // decode

    decode_unit dec0 (
        .dc(dc0)
    );

    branch_target_calc btc0 (
        .pc(dec_pc),
        .dc(dc0)
    );

    // 2 stage. starts in fetch. uses bram
    // result arrives in decode.
    dummyBHT bht0 (
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
        dc0.rd,
        dc0.rs1,
        dc0.rs2,
        dc0.ctrl.imm_type,
        dc0.packed_imm,
        dc0.taken,
        dc0.shadowed,
        dec_pc
    };

    assign aluqdin = dec_out;
    assign memqdin = dec_out;

    assign imem_read = 1'b1;//!(aluqfull | memqfull);
    // not checking if full, since it we need more slots so it doesn't stall
    assign aluqpush = /*!aluqfull & */dc0.ctrl.iq_type == iqt::alu;
    assign memqpush = /*!memqfull & */dc0.ctrl.iq_type == iqt::mem;

    dummy_queue #(
        $bits(queue_item_t)
    )
    aluq0 (
        .clk,
        .rst,
        .push_front(aluqpush),
        .pop_back(aluqpop),
        .empty(aluqempty),
        .full(aluqfull),
        .din(aluqdin),
        .dout(aluqdout)
    );

    logic aluqready;

    dummy_issue_check aluq_issue_check0 (
        .exu_type(aluqdout.exu_type),
        .has_rd(aluqdout.has_rd),
        .has_rs1(aluqdout.has_rs1),
        .has_rs2(aluqdout.has_rs2),
        .rd(aluqdout.rd),
        .rs1(aluqdout.rs1),
        .rs2(aluqdout.rs2),
        .ready(aluqready)
    );
    
    dummy_queue #(
        $bits(queue_item_t)
    )
    memq0 (
        .clk,
        .rst,
        .push_front(memqpush),
        .pop_back(memqpop),
        .empty(memqempty),
        .full(memqfull),
        .din(memqdin),
        .dout(memqdout)
    );

    logic memqready;

    dummy_issue_check memq_issue_check0 (
        .exu_type(memqdout.exu_type),
        .has_rd(memqdout.has_rd),
        .has_rs1(memqdout.has_rs1),
        .has_rs2(memqdout.has_rs2),
        .rd(memqdout.rd),
        .rs1(memqdout.rs1),
        .rs2(memqdout.rs2),
        .ready(memqready)
    );

    // rrd
	 
    assign aluqpop = !aluqempty & aluqready;
    
    always_comb begin
        if (aluqempty || !aluqready) begin
            arc0.uopcode <= uopc::add;
            arc0.exu_type <= exut::alu;
            arc0.has_rd <= '0;
            arc0.has_rs1 <= '0;
            arc0.has_rs2 <= '0;
            arc0.rd <= '0;
            arc0.rs1 <= '0;
            arc0.rs2 <= '0;
            arc0.imm_type <= immt::r;
            arc0.packed_imm <= '0;
            arc0.taken <= '0;
            arc0.shadowed <= '0;
            arc0.pc <= '0;
        end
        else begin
            arc0.uopcode <= aluqdout.uopcode;
            arc0.exu_type <= aluqdout.exu_type;
            arc0.has_rd <= aluqdout.has_rd;
            arc0.has_rs1 <= aluqdout.has_rs1;
            arc0.has_rs2 <= aluqdout.has_rs2;
            arc0.rd <= aluqdout.rd;
            arc0.rs1 <= aluqdout.rs1;
            arc0.rs2 <= aluqdout.rs2;
            arc0.imm_type <= aluqdout.imm_type;
            arc0.packed_imm <= aluqdout.packed_imm;
            arc0.taken <= aluqdout.taken;
            arc0.shadowed <= aluqdout.shadowed;
            arc0.pc <= aluqdout.pc;
        end
    end

    exe_decode exe_dec0 (.ec(arc0));

    alu_imm_dec alu_imm_dec0 (
        .packed_imm(arc0.packed_imm),
        .imm_type(arc0.imm_type),
        .imm(arc0.imm)
    );

    

    // rrd -> exec
    always_ff @(posedge clk) begin
        aec0.uopcode <= arc0.uopcode;
        aec0.exu_type <= arc0.exu_type;
        aec0.has_rd <= arc0.has_rd;
        aec0.has_rs1 <= arc0.has_rs1;
        aec0.has_rs2 <= arc0.has_rs2;
        aec0.rd <= arc0.rd;
        aec0.rs1 <= arc0.rs1;
        aec0.rs2 <= arc0.rs2;
        aec0.taken <= arc0.taken;
        aec0.shadowed <= arc0.shadowed;
        aec0.pc <= arc0.pc;
        aec0.ctrl <= arc0.ctrl;
        aec0.imm <= arc0.imm;
        aec0.reg_a <= arc0.reg_a;
        aec0.reg_b <= arc0.reg_b;
    end

    // exec
    rv32i_word operand1;
    rv32i_word operand2;
    
    always_comb begin
        unique case (aec0.ctrl.opr1)
            opr1t::rs1  : operand1 = aec0.reg_a;
            opr1t::pc   : operand1 = aec0.pc;
            opr1t::zero : operand1 = '0;
        endcase
    end

    always_comb begin
        unique case (aec0.ctrl.opr2)
            opr2t::rs2  : operand2 = aec0.reg_b;
            opr2t::imm  : operand2 = aec0.imm;
        endcase
    end


    //
    alu alu0 (
        .fn(aec0.ctrl.alufn),
        .in1(operand1),
        .in2(operand2),
        .out(aec0.alu_out)
    );

    logic eq;
    logic lt;
    logic ltu;
    assign eq  = aec0.reg_a == aec0.reg_b;
    assign lt  = $signed(aec0.reg_a) <  $signed(aec0.reg_b);
    assign ltu = aec0.reg_a <  aec0.reg_b;

    always_comb begin
        unique case (aec0.ctrl.brfn)
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
    always_ff @(posedge clk) begin
        awc0.alu_out <= aec0.alu_out;
        awc0.has_rd <= aec0.has_rd;
        awc0.has_rs1 <= aec0.has_rs1;
        awc0.has_rs2 <= aec0.has_rs2;
        awc0.rd <= aec0.rd;
        awc0.rs1 <= aec0.rs1;
        awc0.rs2 <= aec0.rs2;
        awc0.shadowed <= aec0.shadowed;
    end

    // wb
    // TODO: set registers to unused
    




    // -- mem stuff oh god why -- //


    // rrd
	 
	 assign memqpop = !memqempty & memqready;
    
    always_comb begin
        if (memqempty || !memqready) begin
            mrc0.uopcode <= uopc::add;
            mrc0.exu_type <= exut::mem;
            mrc0.has_rd <= '0;
            mrc0.has_rs1 <= '0;
            mrc0.has_rs2 <= '0;
            mrc0.rd <= '0;
            mrc0.rs1 <= '0;
            mrc0.rs2 <= '0;
            mrc0.packed_imm <= '0;
        end
        else begin
            mrc0.uopcode <= memqdout.uopcode;
            mrc0.exu_type <= memqdout.exu_type;
            mrc0.has_rd <= memqdout.has_rd;
            mrc0.has_rs1 <= memqdout.has_rs1;
            mrc0.has_rs2 <= memqdout.has_rs2;
            mrc0.rd <= memqdout.rd;
            mrc0.rs1 <= memqdout.rs1;
            mrc0.rs2 <= memqdout.rs2;
            mrc0.packed_imm <= memqdout.packed_imm;
        end
    end

    mem_decode mem_dec (.mc(mrc0));

    mem_imm_dec mem_imm_dec0 (
        .packed_imm(mrc0.packed_imm),
        .imm(mrc0.imm)
    );



    // rrd -> agu
    always_ff @(posedge clk) begin
        mmc0.uopcode  <= mrc0.uopcode;
        mmc0.exu_type <= mrc0.exu_type;
        mmc0.has_rd   <= mrc0.has_rd;
        mmc0.has_rs1  <= mrc0.has_rs1;
        mmc0.has_rs2  <= mrc0.has_rs2;
        mmc0.rd       <= mrc0.rd;
        mmc0.rs1      <= mrc0.rs1;
        mmc0.rs2      <= mrc0.rs2;
        mmc0.ctrl     <= mrc0.ctrl;
        mmc0.imm      <= mrc0.imm;
        mmc0.reg_a    <= mrc0.reg_a;
        mmc0.reg_b    <= mrc0.reg_b;
    end

    // agu + mem
    // TODO: timing: agu and mem should be split into 2 stages

    assign mmc0.addr = mmc0.reg_a + mmc0.imm;

    mbe_gen mbe_gen0 ( .mc(mmc0) );

    assign mem_byte_enable = mmc0.mbe;
    assign mem_address = mmc0.addr;
    assign mem_wdata = mmc0.reg_b;

    logic sign_byte;
    logic zero_byte;
    always_comb begin
        unique case ({mmc0.ctrl.memsz, mmc0.ctrl.ldext})
            {memszt::b, ldextt::s} : mmc0.mem_out = {{24{mem_rdata[07]}}, mem_rdata[07:0]};
            {memszt::b, ldextt::z} : mmc0.mem_out = { 24'b0,              mem_rdata[07:0]};
            {memszt::h, ldextt::s} : mmc0.mem_out = {{16{mem_rdata[15]}}, mem_rdata[15:0]};
            {memszt::h, ldextt::z} : mmc0.mem_out = { 16'b0,              mem_rdata[15:0]};
            default                : mmc0.mem_out =                       mem_rdata;
        endcase
    end

    assign mem_read  = mmc0.ctrl.memfn[1];
    assign mem_write = mmc0.ctrl.memfn[0];

    // TODO: if no resp, unit busy


    //


    // mem -> wb
    always_ff @(posedge clk) begin
        mwc0.mem_out <= mmc0.mem_out;
        mwc0.has_rd <= mmc0.has_rd;
        mwc0.has_rs1 <= mmc0.has_rs1;
        mwc0.has_rs2 <= mmc0.has_rs2;
        mwc0.rd <= mmc0.rd;
        mwc0.rs1 <= mmc0.rs1;
        mwc0.rs2 <= mmc0.rs2;
    end

    // wb
    // TODO: set registers to unused





endmodule : one_hz_cpu



module dummy_issue_check (
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

endmodule : dummy_issue_check


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
