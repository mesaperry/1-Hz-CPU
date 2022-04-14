import rv32i_types::*;

module arbiter (
    input                   clk,
    input                   rst,

    input   rv32i_word      inst_cline_addr,
    output  logic [255:0]   inst_cline_rdata,
    input   logic           inst_cline_read,
    output  logic           inst_cline_resp,

    input   rv32i_word      data_cline_addr,
    output  logic [255:0]   data_cline_rdata,
    input   logic [255:0]   data_cline_wdata,
    input   logic           data_cline_read,
    input   logic           data_cline_write,
    output  logic           data_cline_resp,

    output  rv32i_word      pmem_address,
    input   logic [255:0]   pmem_rdata,
    output  logic [255:0]   pmem_wdata,
    output  logic           pmem_read,
    output  logic           pmem_write,
    input   logic           pmem_resp        
);

    

endmodule : arbiter
