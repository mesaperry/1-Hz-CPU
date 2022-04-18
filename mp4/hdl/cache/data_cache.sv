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

    // cache lines are 256 bits
    // pages are 512 bits
    // there is a 500 ns delay per request
    // the delay is halved if accessing same page

    localparam x_len = 32;
    localparam s_line = 256;
    localparam n_sets = 32;

    localparam bytes_per_line = s_line / 8;
    localparam s_offset = $clog2(bytes_per_line);
    localparam s_index = $clog2(n_sets);
    localparam s_tag = x_len - (s_offset + s_index);

    // FIXME: very hacky state machine stuff
    // so i think this gives us a clock cycle delay
    // after a stall where we don't change stages
    // this allows the pc_f0 to be corrected
    logic start;
    always_ff @(posedge clk) begin
        if (rst)
            start <= 1'b1;
        else if (mem_read)
            start <= 1'b0;
        else
            start <= 1'b1;
    end


    // decl //
    // stage 0 //
    rv32i_word address_0;
    logic [s_tag-1:0] tag_0;
    logic [s_index-1:0] index_0;
    logic [s_offset-1:0] offset_0;
    logic read_0;

    // stage 1 //
    rv32i_word address_1;
    logic [s_tag-1:0] tag_1;
    logic [s_index-1:0] index_1;
    logic [s_offset-1:0] offset_1;
    logic read_1;

    logic valid_1;
    logic hit_1;
    logic [s_tag-1:0] tag_o;


    // impl
    // stage 0
    assign address_0 = mem_address;
    assign {tag_0, index_0, offset_0} = address_0;
    assign read_0 = mem_read;


    // stage 0 -> stage 1
    always_ff @(posedge clk) begin
        if (rst) begin
            address_1 <= '0;
        end
        // TODO: maybe use or redir as condition as well
        else if (hit_1 & mem_read | start) begin
            address_1 <= address_0;
        end
    end

    // stage 1
    assign {tag_1, index_1, offset_1} = address_1;

    assign hit_1 = valid_1 ? (tag_1 == tag_o) : 1'b0;


    assign mem_resp = hit_1 & ~start;
    // PERF: on critical path starting from tag_o
    assign pmem_read = ~hit_1 & ~start;
    assign pmem_address = {tag_1, index_1, {s_offset{1'b0}}};


    logic [s_line-1:0] rline;
    assign mem_rdata = rline[offset_1[s_offset-1:2] * x_len +: x_len];


    // WARNING: these guys do not support simultaneous read and write
    bram256x32 data (
        .address (pmem_read ? index_1 : index_0),
        .clock   (clk),
        .data    (pmem_rdata),
        .wren    (pmem_resp),
        .q       (rline)
    );

    bram22x32 tags (
        .address (pmem_read ? index_1 : index_0),
        .clock   (clk),
        .data    (tag_1),
        .wren    (pmem_resp),
        .q       (tag_o)
    );

    logic [n_sets-1:0] valids;

    assign valid_1 = valids[index_1];

    always_ff @(posedge clk) begin
        if (rst) 
            valids <= '0;
        else if (pmem_resp)
            valids[index_1] <= 1'b1;
    end

endmodule : inst_cache

