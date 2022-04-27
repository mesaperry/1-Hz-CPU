`ifndef RVFI_ITF
`define RVFI_ITF

interface rvfi_itf(input clk, input rst);

    logic [3:0] halt;
    logic [3:0] commit;
    logic [255:0] order;
    logic [127:0] inst;
    logic [3:0] trap;
    logic [19:0] rs1_addr;
    logic [19:0] rs2_addr;
    logic [127:0] rs1_rdata;
    logic [127:0] rs2_rdata;
    logic [19:0] rd_addr;
    logic [127:0] rd_wdata;
    logic [127:0] pc_rdata;
    logic [127:0] pc_wdata;
    logic [127:0] mem_addr;
    logic [15:0] mem_rmask;
    logic [15:0] mem_wmask;
    logic [127:0] mem_rdata;
    logic [127:0] mem_wdata;

    logic [15:0] errcode;

endinterface

`endif
