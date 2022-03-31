module mp4(
    input clk,
    input rst,
    output  rv32i_word  pc,
    input   rv32i_word  instr,
    output  logic       imem_read,
    input   logic       imem_resp,
    output  rv32i_word  mem_address,
    input   rv32i_word  mem_rdata,
    output  rv32i_word  mem_wdata,
    output  logic       mem_read,
    output  logic       mem_write,
    output  logic [3:0] mem_byte_enable,
    input   logic       mem_resp
);

one_hz_cpu cpu(.*);

endmodule : mp4
