import rv32i_types::*;

module data_cache (
    input                   clk,
    input                   rst,

    input   rv32i_word      mem_address,
    output  rv32i_word      mem_rdata,
    input   rv32i_word      mem_wdata,
    input   logic           mem_read,
    input   logic           mem_write,
    input   logic [3:0]     mem_mbe,
    output  logic           mem_resp,
    output  rv32i_word      pmem_address,
    input   logic [255:0]   pmem_rdata,
    output  logic [255:0]   pmem_wdata,
    output  logic           pmem_read,
    output  logic           pmem_write,
    input   logic           pmem_resp
);

    rv32i_word rmem_address;
    rv32i_word rmem_wdata;
    logic rmem_read;
    logic rmem_write;
    logic [3:0] rmem_mbe;

    always_ff @(posedge clk) begin
        rmem_address <= mem_address;
        rmem_wdata <= mem_wdata;
        rmem_read <= mem_read;
        rmem_write <= mem_write;
        rmem_mbe <= mem_mbe;
    end

    cache given_cache (
        .clk,
        .pmem_resp,
        .pmem_rdata,
        .pmem_address,
        .pmem_wdata,
        .pmem_read,
        .pmem_write,
        .mem_read(rmem_read),
        .mem_write(rmem_write),
        .mem_byte_enable_cpu(rmem_mbe),
        .mem_address(rmem_address),
        .mem_wdata_cpu(rmem_wdata),
        .mem_resp,
        .mem_rdata_cpu(mem_rdata)
    );

endmodule : data_cache

