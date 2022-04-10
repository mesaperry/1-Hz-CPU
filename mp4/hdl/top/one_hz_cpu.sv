//`include "../ctrl_word.sv"
//`include "../../hvl/tb_itf.sv"
import rv32i_types::*;
typedef struct packed {//51
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
    rv32i_word nxl_target; // (next line or pc+4)
    rv32i_word btb_target
    rv32i_word ras_target; // technically available in f0

    rv32i_word instr_f1;


    //-- decode --//
    rv32i_word pc_dc;

    logic taken_dc;

    logic [1:0] bht_resp_dc;

    rv32i_word instr_dc;

    rv32i_word dec_target;

    queue_item_t ctrl_sigs_dc;


    //-- rrd/issue --//
    rv32i_word pc_is;

    queue_item_t ctrl_sigs_is;

    alufnt::alu_func_t alufn_is;
    rv32i_word alu_opr1_is;
    rv32i_word alu_opr2_is;

    memfnt::mem_func_t memfn_is;
    rv32i_word lsu_opr1_is;
    rv32i_word lsu_opr2_is;

    brfnt::br_func_t brfn_is;
    rv32i_word jmp_opr1_is;
    rv32i_word jmp_opr2_is;
    rv32i_word jmp_pc_ofst_is;


    //-- execute --//
    rv32i_word pc_ex;

    logic alu_has_rd_ex;
    logic [4:0] alu_rd_ex;
    
    logic mem_has_rd_ex;
    logic [4:0] mem_rd_ex;
    
    logic jmp_has_rd_ex;
    logic [4:0] jmp_rd_ex;
    
    alufnt::alu_func_t alufn_ex;
    rv32i_word alu_opr1_ex;
    rv32i_word alu_opr2_ex;

    memfnt::mem_func_t memfn_ex;
    rv32i_word lsu_opr1_ex;
    rv32i_word lsu_opr2_ex;

    brfnt::br_func_t brfn_ex;
    rv32i_word jmp_opr1_ex;
    rv32i_word jmp_opr2_ex;
    rv32i_word jmp_pc_ofst_ex;

    rv32i_word alu_res_ex;

    rv32i_word mem_res_ex;

    rv32i_word jmp_res_ex;


    //-- writeback --//
    logic alu_has_rd_wb;
    logic [4:0] alu_rd_wb;
    
    logic mem_has_rd_wb;
    logic [4:0] mem_rd_wb;
    
    logic jmp_has_rd_wb;
    logic [4:0] jmp_rd_wb;
    
    rv32i_word alu_res_wb;

    rv32i_word mem_res_wb;

    rv32i_word jmp_res_wb;




    //------------//
    //--- impl ---//
    //------------//

    logic stall;

    //-- fetch0 --//
    assign imem_read = ~stall;

    // TODO: decide based on:
    // BHT entry (4 state)
    // BTB valid? ret? jmp?
    // decoded jal
    // branch unit resolution
    always_comb begin
        unique case (0)
            1       : {pc_f0, taken_f0} = {btb_target, 1'b1};
            2       : {pc_f0, taken_f0} = {ras_target, 1'b1};
            // TODO: for decode redirect 
            // need to kill anything in fetch1
            3       : {pc_f0, taken_f0} = {dec_target, 1'b1};
            // TODO: for branch resolution redirect, 
            // kill everything not in a functional unit
            4       : {pc_f0, taken_f0} = {bru_target, 1'b1};
            default : {pc_f0, taken_f0} = {nxl_target, 1'b0};
        endcase
    end

    

    //-- fetch0 -> fetch1 --//

    rg #(
        .rst_val('X)
    )
    fetch1_pc_reg (
        .clk,
        .rst,
        .ld(~stall), // TODO: maybe should be imem_resp
        .din(pc_f0),
        .dout(pc_f1)
    );

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

    //-- fetch1 --//

    rg #(
        .rst_val(32'h00000060)
    )
    next_line_reg (
        .clk,
        .rst,
        .ld(~stall), // TODO: maybe should be imem_resp or stall
        .din(pc_f0 + 4),
        .dout(nxl_target)
    );

    always_ff @(posedge clk) begin
        bht_resp_f1 <= 2'b01;
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
        .din(taken_f1),
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
    decode_pc_reg (
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
    assign is_nop_dc = dc0.ctrl.exu_type == exut::alu && dc0.rd = 5'b0;

    logic needs_pc_dc;
    assign needs_pc_dc = dc0.ctrl.exu_type == exut::jmp;

    //-- decode --(queue)-> rrd/issue --//

    logic push_iq0, pop_iq0, empty_iq0, full_iq0;
    logic push_pq0, pop_pq0, empty_pq0, full_pq0;

    assign stall = full_iq0 | full_pq0;

    assign push_iq0 = ~stall & ~is_nop_dc;
    assign push_pq0 = ~stall & needs_pc_dc;

    instr_queue iq0 (
        .clk,
        .rst,
        .push(push_iq0),
        .pop(pop_iq0),
        .empty(empty_iq0),
        .full(full_iq0),
        .din(ctrl_sigs_dc),
        .dout(ctrl_sigs_is)
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





endmodule : one_hz_cpu


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

    // TODO: create one in quartus
    fifo51x8 (
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
