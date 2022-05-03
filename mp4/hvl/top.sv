module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// For local simulation, add signal for Modelsim to display by default
// Note that this signal does nothing and is not used for anything
bit f;

/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP2

/*
The following signals need to be set:
Instruction and trap:
    rvfi.inst
    rvfi.trap

Regfile:
    rvfi.rs1_addr
    rvfi.rs2_add
    rvfi.rs1_rdata
    rvfi.rs2_rdata
    rvfi.rd_addr
    rvfi.rd_wdata

PC:
    rvfi.pc_rdata
    rvfi.pc_wdata

Memory:
    rvfi.mem_addr
    rvfi.mem_rmask
    rvfi.mem_wmask
    rvfi.mem_rdata
    rvfi.mem_wdata

Please refer to rvfi_itf.sv for more information.
*/
RvfiBundle rvfi_is0();
RvfiBundle rvfi_ex_alu0();
RvfiBundle rvfi_ex_agu0();
RvfiBundle rvfi_ex_mem0();
RvfiBundle rvfi_ex_bru0();
RvfiBundle rvfi_wb_alu0();
RvfiBundle rvfi_wb_lsu0();
RvfiBundle rvfi_wb_bru0();
logic [63:0] order;
initial order = 0;

logic [4:0] rs1_is0, rs2_is0;

assign {
    rvfi_is0.insn,
    rvfi_is0.trap, 
    rs1_is0, 
    rs2_is0, 
    rvfi_is0.rd_addr, 
    rvfi_is0.pc_rdata
} = dut.cpu.debug_sigs_is;

assign rvfi_is0.rs1_addr = dut.cpu.ctrl_sigs_rd.has_rs1 ? rs1_is0 : 5'b0;
assign rvfi_is0.rs2_addr = dut.cpu.ctrl_sigs_rd.has_rs2 ? rs2_is0 : 5'b0;

assign rvfi_is0.valid = dut.cpu.pop_iq0;
assign rvfi_is0.order = order;

always @(posedge itf.clk) begin
    if (rvfi_is0.valid & ~dut.cpu.mispred)
        order <= order + 1;
end

rvfi_is_ex is_alu_reg (
    .clk(itf.clk),
    .rst(itf.rst | dut.cpu.mispred),
    .ld(1'b1),
    .uses_unit(dut.cpu.ctrl_sigs_is.exu_type == exut::alu),
    .rvfi_is(rvfi_is0),
    .rvfi_ex(rvfi_ex_alu0)
);

assign rvfi_ex_alu0.rs1_rdata = rvfi_ex_alu0.rs1_addr != 5'b0 ? dut.cpu.rs1_out : '0;
assign rvfi_ex_alu0.rs2_rdata = rvfi_ex_alu0.rs2_addr != 5'b0 ? dut.cpu.rs2_out : '0;
assign rvfi_ex_alu0.halt = 1'b0;
assign rvfi_ex_alu0.pc_wdata = rvfi_ex_alu0.pc_rdata + 4;
assign rvfi_ex_alu0.mem_addr = '0;
assign rvfi_ex_alu0.mem_rmask = 4'h0;
assign rvfi_ex_alu0.mem_wmask = 4'h0;
assign rvfi_ex_alu0.mem_wdata = '0;


rvfi_ex_wb wb_alu_reg (
    .clk(itf.clk),
    .rvfi_ex(rvfi_ex_alu0),
    .rvfi_wb(rvfi_wb_alu0)
);

assign rvfi_wb_alu0.rd_wdata = ~dut.cpu.alu_has_rd_wb | (dut.cpu.alu_rd_wb == 5'b0)
                             ? '0
                             : dut.cpu.alu_res_wb;
assign rvfi_wb_alu0.mem_rdata = '0;


rvfi_is_ex is_lsu_reg (
    .clk(itf.clk),
    .rst(itf.rst | (dut.cpu.mispred & ~dut.cpu.mem_stall)),
    .ld(~dut.cpu.mem_stall),
    .uses_unit(dut.cpu.ctrl_sigs_is.exu_type == exut::mem),
    .rvfi_is(rvfi_is0),
    .rvfi_ex(rvfi_ex_agu0)
);

logic [31:0] lsu_rs1_rdata_in, lsu_rs2_rdata_in;
logic [31:0] agu_rs1_hold, agu_rs2_hold;

assign lsu_rs1_rdata_in = rvfi_ex_agu0.rs1_addr != 5'b0 ? dut.cpu.rs1_out : '0;
assign lsu_rs2_rdata_in = rvfi_ex_agu0.rs2_addr != 5'b0 ? dut.cpu.rs2_out : '0;

always_ff @(posedge itf.clk) begin
    if (~dut.cpu.rmem_stall) begin
        agu_rs1_hold <= lsu_rs1_rdata_in;
        agu_rs2_hold <= lsu_rs2_rdata_in;
    end
end

assign rvfi_ex_agu0.rs1_rdata = dut.cpu.rmem_stall ? agu_rs1_hold : lsu_rs1_rdata_in;
assign rvfi_ex_agu0.rs2_rdata = dut.cpu.rmem_stall ? agu_rs2_hold : lsu_rs2_rdata_in;
assign rvfi_ex_agu0.halt = 1'b0;
assign rvfi_ex_agu0.pc_wdata = rvfi_ex_agu0.pc_rdata + 4;
assign rvfi_ex_agu0.mem_addr = {dut.cpu.agu_addr_ex[31:2], 2'b0};
assign rvfi_ex_agu0.mem_rmask = dut.cpu.agu_ctrl_ex.memfn[1] ? dut.cpu.agu_mbe_ex : 4'b0;
assign rvfi_ex_agu0.mem_wmask = dut.cpu.agu_ctrl_ex.memfn[0] ? dut.cpu.agu_mbe_ex : 4'b0;
assign rvfi_ex_agu0.mem_wdata = dut.cpu.agu_valu_ex;


rvfi_stall agu_mem_reg (
    .clk(itf.clk),
    .stall(dut.cpu.mem_stall),
    .rst(1'b0),
    .rvfi_inp(rvfi_ex_agu0),
    .rvfi_out(rvfi_ex_mem0)
);

assign rvfi_ex_mem0.mem_rdata = dut.cpu.data_rdata;

rvfi_stall mem_wb_reg (
    .clk(itf.clk),
    .rst(itf.rst | ~dut.cpu.data_resp),
    .stall(dut.cpu.mem_stall),
    .rvfi_inp(rvfi_ex_mem0),
    .rvfi_out(rvfi_wb_lsu0)
);




rvfi_is_ex is_bru_reg (
    .clk(itf.clk),
    .rst(itf.rst | dut.cpu.mispred),
    .ld(1'b1),
    .uses_unit(dut.cpu.ctrl_sigs_is.exu_type == exut::jmp),
    .rvfi_is(rvfi_is0),
    .rvfi_ex(rvfi_ex_bru0)
);

assign rvfi_ex_bru0.halt = dut.cpu.bru_says_take 
                         & (dut.cpu.bru_jmp_target == dut.cpu.pc_br);

assign rvfi_ex_bru0.rs1_rdata = rvfi_ex_bru0.rs1_addr != 5'b0 ? dut.cpu.rs1_out : '0;
assign rvfi_ex_bru0.rs2_rdata = rvfi_ex_bru0.rs2_addr != 5'b0 ? dut.cpu.rs2_out : '0;
assign rvfi_ex_bru0.pc_wdata = dut.cpu.bru_target;
assign rvfi_ex_bru0.mem_addr = '0;
assign rvfi_ex_bru0.mem_rmask = 4'h0;
assign rvfi_ex_bru0.mem_wmask = 4'h0;
assign rvfi_ex_bru0.mem_wdata = '0;

rvfi_ex_wb wb_bru_reg (
    .clk(itf.clk),
    .rvfi_ex(rvfi_ex_bru0),
    .rvfi_wb(rvfi_wb_bru0)
);

assign rvfi_wb_bru0.rd_wdata = ~dut.cpu.bru_has_rd_wb | (dut.cpu.bru_rd_wb == 5'b0)
                             ? '0
                             : dut.cpu.bru_res_wb;
assign rvfi_wb_bru0.mem_rdata = '0;



assign rvfi.halt = {
    rvfi_wb_alu0.halt,
    rvfi_wb_lsu0.halt,
    rvfi_wb_bru0.halt,
    1'b0
};
assign rvfi.commit = {
    rvfi_wb_alu0.valid,
    rvfi_wb_lsu0.valid,
    rvfi_wb_bru0.valid,
    1'b0
};
assign rvfi.order = {
    rvfi_wb_alu0.order,
    rvfi_wb_lsu0.order,
    rvfi_wb_bru0.order,
    64'b0
};
assign rvfi.inst = {
    rvfi_wb_alu0.insn,
    rvfi_wb_lsu0.insn,
    rvfi_wb_bru0.insn,
    32'b0
};
assign rvfi.trap = {
    rvfi_wb_alu0.trap,
    rvfi_wb_lsu0.trap,
    rvfi_wb_bru0.trap,
    1'b0
};
assign rvfi.rs1_addr = {
    rvfi_wb_alu0.rs1_addr,
    rvfi_wb_lsu0.rs1_addr,
    rvfi_wb_bru0.rs1_addr,
    5'b0
};
assign rvfi.rs2_addr = {
    rvfi_wb_alu0.rs2_addr,
    rvfi_wb_lsu0.rs2_addr,
    rvfi_wb_bru0.rs2_addr,
    5'b0
};
assign rvfi.rs1_rdata = {
    rvfi_wb_alu0.rs1_rdata,
    rvfi_wb_lsu0.rs1_rdata,
    rvfi_wb_bru0.rs1_rdata,
    32'b0
};
assign rvfi.rs2_rdata = {
    rvfi_wb_alu0.rs2_rdata,
    rvfi_wb_lsu0.rs2_rdata,
    rvfi_wb_bru0.rs2_rdata,
    32'b0
};
assign rvfi.rd_addr = {
    rvfi_wb_alu0.rd_addr,
    rvfi_wb_lsu0.rd_addr,
    rvfi_wb_bru0.rd_addr,
    5'b0
};
assign rvfi.rd_wdata = {
    rvfi_wb_alu0.rd_wdata,
    rvfi_wb_lsu0.rd_wdata,
    rvfi_wb_bru0.rd_wdata,
    32'b0
};
assign rvfi.pc_rdata = {
    rvfi_wb_alu0.pc_rdata,
    rvfi_wb_lsu0.pc_rdata,
    rvfi_wb_bru0.pc_rdata,
    32'b0
};
assign rvfi.pc_wdata = {
    rvfi_wb_alu0.pc_wdata,
    rvfi_wb_lsu0.pc_wdata,
    rvfi_wb_bru0.pc_wdata,
    32'b0
};
assign rvfi.mem_addr = {
    rvfi_wb_alu0.mem_addr,
    rvfi_wb_lsu0.mem_addr,
    rvfi_wb_bru0.mem_addr,
    32'b0
};
assign rvfi.mem_rmask = {
    rvfi_wb_alu0.mem_rmask,
    rvfi_wb_lsu0.mem_rmask,
    rvfi_wb_bru0.mem_rmask,
    4'b0
};
assign rvfi.mem_wmask = {
    rvfi_wb_alu0.mem_wmask,
    rvfi_wb_lsu0.mem_wmask,
    rvfi_wb_bru0.mem_wmask,
    4'b0
};
assign rvfi.mem_rdata = {
    rvfi_wb_alu0.mem_rdata,
    rvfi_wb_lsu0.mem_rdata,
    rvfi_wb_bru0.mem_rdata,
    32'b0
};
assign rvfi.mem_wdata = {
    rvfi_wb_alu0.mem_wdata,
    rvfi_wb_lsu0.mem_wdata,
    rvfi_wb_bru0.mem_wdata,
    32'b0
};





/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/

assign itf.inst_read = dut.inst_read;
assign itf.inst_addr = dut.cpu.pc_f1;
assign itf.inst_resp = dut.inst_resp;
assign itf.inst_rdata = dut.inst_rdata;


assign itf.data_read = dut.cpu.mem_ctrl_ex.memfn[1];
assign itf.data_write = dut.cpu.mem_ctrl_ex.memfn[0];
assign itf.data_mbe = dut.cpu.mem_mbe_ex;
assign itf.data_addr = dut.cpu.mem_addr_ex;
assign itf.data_wdata = dut.cpu.mem_valu_ex;
assign itf.data_resp = dut.cpu.data_resp;
assign itf.data_rdata = dut.cpu.data_rdata;

/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = dut.cpu.rf.data;


// performance counters

logic [63:0] num_cycles;
logic [63:0] num_branches;
logic [63:0] num_branches_taken;
logic [63:0] num_branches_not_taken;
logic [63:0] num_mispredicts;
logic [63:0] num_mispredicts_taken;
logic [63:0] num_mispredicts_not_taken;
logic [63:0] queue_empty;
logic [63:0] queue_full;
logic [63:0] pc_queue_full;
logic [63:0] inst_cache_req;
logic [63:0] inst_cache_miss;


initial num_cycles = 0;
initial num_branches = 0;
initial num_branches_taken = 0;
initial num_branches_not_taken = 0;
initial num_mispredicts = 0;
initial num_mispredicts_taken = 0;
initial num_mispredicts_not_taken = 0;
initial queue_empty = 0;
initial queue_full = 0;
initial pc_queue_full = 0;
initial inst_cache_req = 0;
initial inst_cache_miss = 0;

always_ff @(posedge itf.clk) begin
    if (dut.cpu.inst_resp) begin
        inst_cache_req <= inst_cache_req + 1;
        if (dut.icache.miss) begin
            inst_cache_miss <= inst_cache_miss + 1;
        end
    end
end

always_ff @(posedge itf.clk) begin
    num_cycles <= num_cycles + 1;
end

always_ff @(posedge itf.clk) begin
    if (dut.cpu.empty_iq0)
        queue_empty <= queue_empty + 1;
    if (dut.cpu.full_iq0)
        queue_full <= queue_full + 1;
    if (dut.cpu.full_pq0)
        pc_queue_full <= pc_queue_full + 1;
end

always_ff @(posedge itf.clk) begin
    if (dut.cpu.bru_is_br) begin
        num_branches <= num_branches + 1;
        if (dut.cpu.bru_says_take) begin
            num_branches_taken <= num_branches_taken + 1;
        end
        else begin
            num_branches_not_taken <= num_branches_not_taken + 1;
        end
        if (dut.cpu.bru_redir) begin
            num_mispredicts <= num_mispredicts + 1;
            if (~dut.cpu.bru_says_take) begin
                num_mispredicts_taken <= num_mispredicts_taken + 1;
            end
            else begin
                num_mispredicts_not_taken <= num_mispredicts_not_taken + 1;
            end
        end
    end
end


/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level:
Clock and reset signals:
    itf.clk
    itf.rst

Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

mp4 dut(
    .clk            (itf.clk       ),    
    .rst            (itf.rst       ),
    .pmem_address   (itf.mem_addr  ),
    .pmem_rdata     (itf.mem_rdata ),  
    .pmem_wdata     (itf.mem_wdata ),
    .pmem_read      (itf.mem_read  ),
    .pmem_write     (itf.mem_write ),
    .pmem_resp      (itf.mem_resp  )
);

/***************************** End Instantiation *****************************/

endmodule

interface RvfiBundle;
    logic valid;
    logic [63:0] order;
    logic [31:0] insn;
    logic trap;
    logic halt;
    logic intr;
    logic [1:0] mode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [31:0] rs1_rdata;
    logic [31:0] rs2_rdata;
    logic [4:0] rd_addr;
    logic [31:0] rd_wdata;
    logic [31:0] pc_rdata;
    logic [31:0] pc_wdata;
    logic [31:0] mem_addr;
    logic [3:0] mem_rmask;
    logic [3:0] mem_wmask;
    logic [31:0] mem_rdata;
    logic [31:0] mem_wdata;
    logic mem_extamo;
endinterface

module rvfi_is_ex (
    input clk,
    input rst,
    input ld,
    input uses_unit,
    RvfiBundle rvfi_is,
    RvfiBundle rvfi_ex
);

    always_ff @(posedge clk) begin
        if (rst) begin
            rvfi_ex.valid <= 1'b0;
        end
        else if (ld) begin
            rvfi_ex.valid <= rvfi_is.valid & uses_unit;
            rvfi_ex.order <= rvfi_is.order;
            rvfi_ex.insn <= rvfi_is.insn;
            rvfi_ex.trap <= rvfi_is.trap;
            rvfi_ex.rs1_addr <= rvfi_is.rs1_addr;
            rvfi_ex.rs2_addr <= rvfi_is.rs2_addr;
            rvfi_ex.rd_addr <= rvfi_is.rd_addr;
            rvfi_ex.pc_rdata <= rvfi_is.pc_rdata;
        end
    end

endmodule : rvfi_is_ex

module rvfi_ex_wb (
    input clk,
    RvfiBundle rvfi_ex,
    RvfiBundle rvfi_wb
);

    always_ff @(posedge clk) begin
        rvfi_wb.valid <= rvfi_ex.valid;
        rvfi_wb.order <= rvfi_ex.order;
        rvfi_wb.insn <= rvfi_ex.insn;
        rvfi_wb.trap <= rvfi_ex.trap;
        rvfi_wb.rs1_addr <= rvfi_ex.rs1_addr;
        rvfi_wb.rs2_addr <= rvfi_ex.rs2_addr;
        rvfi_wb.rs1_rdata <= rvfi_ex.rs1_rdata;
        rvfi_wb.rs2_rdata <= rvfi_ex.rs2_rdata;
        rvfi_wb.rd_addr <= rvfi_ex.rd_addr;
        rvfi_wb.pc_rdata <= rvfi_ex.pc_rdata;
        rvfi_wb.halt <= rvfi_ex.halt;
        rvfi_wb.pc_wdata <= rvfi_ex.pc_wdata;
        rvfi_wb.mem_addr <= rvfi_ex.mem_addr;
        rvfi_wb.mem_rmask <= rvfi_ex.mem_rmask;
        rvfi_wb.mem_wmask <= rvfi_ex.mem_wmask;
        rvfi_wb.mem_wdata <= rvfi_ex.mem_wdata;
    end

endmodule : rvfi_ex_wb

module rvfi_stall (
    input clk,
    input rst,
    input stall,
    RvfiBundle rvfi_inp,
    RvfiBundle rvfi_out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            rvfi_out.valid <= 1'b0;
        end
        else if (~stall) begin
            rvfi_out.valid <= rvfi_inp.valid;
            rvfi_out.order <= rvfi_inp.order;
            rvfi_out.insn <= rvfi_inp.insn;
            rvfi_out.trap <= rvfi_inp.trap;
            rvfi_out.rs1_addr <= rvfi_inp.rs1_addr;
            rvfi_out.rs2_addr <= rvfi_inp.rs2_addr;
            rvfi_out.rs1_rdata <= rvfi_inp.rs1_rdata;
            rvfi_out.rs2_rdata <= rvfi_inp.rs2_rdata;
            rvfi_out.rd_addr <= rvfi_inp.rd_addr;
            rvfi_out.pc_rdata <= rvfi_inp.pc_rdata;
            rvfi_out.halt <= rvfi_inp.halt;
            rvfi_out.pc_wdata <= rvfi_inp.pc_wdata;
            rvfi_out.mem_addr <= rvfi_inp.mem_addr;
            rvfi_out.mem_rmask <= rvfi_inp.mem_rmask;
            rvfi_out.mem_wmask <= rvfi_inp.mem_wmask;
            rvfi_out.mem_wdata <= rvfi_inp.mem_wdata;
        end
    end

endmodule : rvfi_stall

