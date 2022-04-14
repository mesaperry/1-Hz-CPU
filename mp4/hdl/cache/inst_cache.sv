import rv32i_types::*;

module inst_cache (
    input                   clk,
    input                   rst,

    input   rv32i_word      mem_address,
    output  rv32i_word      mem_rdata,
    input   logic           mem_read,
    output  logic           mem_resp,
    output  rv32i_word      pmem_address,
    input   logic [255:0]   pmem_rdata,
    output  logic           pmem_read,
    input   logic           pmem_resp
);

    localparam x_len = 32;
    localparam s_line = 256;
    localparam n_sets = 32;

    localparam bytes_per_line = s_line / 8;
    localparam s_offset = $clog2(bytes_per_line);
    localparam s_index = $clog2(n_sets);
    localparam s_tag = x_len - (s_offset + s_index);

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
            address_1 <= 32'h60;
            read_1 <= 1'b0;
        end
        else if (mem_resp | ~read_1) begin
            address_1 <= address_0;
            read_1 <= read_0;
        end
    end

    // stage 1
    assign {tag_1, index_1, offset_1} = address_1;

    assign hit_1 = (tag_1 == tag_o) & valid_1;


    assign mem_resp = hit_1 & read_1;
    assign pmem_read = ~hit_1 & read_1;
    assign pmem_address = {tag_1, index_1, {s_offset{1'b0}}};


    logic [s_line-1:0] rline;
    assign mem_rdata = rline[offset_1[s_offset-1:2] * 32 +: 32];


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

