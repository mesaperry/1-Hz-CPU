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

    // cache lines are 256 bits
    // pages are 512 bits
    // there is a 500 ns delay per request
    // the delay is halved if accessing same page

    localparam x_len = 32;
    localparam s_line = 256;
    localparam n_sets = 64;

    localparam bytes_per_line = s_line / 8;
    localparam s_offset = $clog2(bytes_per_line);
    localparam s_index = $clog2(n_sets);
    localparam s_tag = x_len - (s_offset + s_index);

    /* DECLARATION */

    // 1
    struct {
        struct packed {
            logic   [s_tag-1:0]     tag;
            logic   [s_index-1:0]   index;
            logic   [s_offset-1:0]  offset;
        } addr;
        logic       read;
    } input0, input1;
    logic is_operating;
    logic pipeline_move;

    // 2
    logic [s_index-1:0] data_addr, tags_addr;

    // 3
    logic valid, hit, miss;

    // 4
    logic evict;
    logic [255:0] data_in;
    logic [s_tag-1:0] tags_in;
    logic data_wren, tags_wren, valid_set;

    // bram and regs
    logic [s_line-1:0] data_out;
    logic [s_tag-1:0] tags_out;

    logic [n_sets-1:0] valids;
    logic [n_sets-1:0] dirtys;

    // WARNING: these guys do not support simultaneous read and write
    bram256x64 data (
        .address (data_addr),
        .clock   (clk),
        .data    (data_in),
        .wren    (data_wren),
        .q       (data_out)
    );

    bram21x64 tags (
        .address (tags_addr),
        .clock   (clk),
        .data    (tags_in),
        .wren    (tags_wren),
        .q       (tags_out)
    );


    /* IMPLEMENTATION */

    /* 1. wait until cache is not busy to move pipeline */
    assign is_operating = input1.read;
    assign mem_resp = hit;
    assign pipeline_move = hit || !is_operating;
    
    /* 2. load input data into pipeline buffer, access brams */
    assign input0 = '{mem_address, mem_read};

    always_ff @(posedge clk) begin : INPUT_LOAD
        if (rst) input1 <= '{'0, '0};
        else input1 <= pipeline_move ? input0 : input1;
    end

    assign data_addr = pipeline_move ? input0.addr.index : input1.addr.index;
    assign tags_addr = pipeline_move ? input0.addr.index : input1.addr.index;

    /* 3. check if tag matches and index is valid (hit) */
    assign valid = valids[input1.addr.index];
    assign hit = is_operating && valid && (input1.addr.tag == tags_out);
    assign miss = is_operating && !hit;

    /* 4. if current cacheline is wrong -> evict and load in correct one */
    assign evict = miss && valid;
    assign pmem_read = evict || (!valid && is_operating);
    assign pmem_address = {input1.addr.tag, input1.addr.index, {s_offset{1'b0}}};
    assign data_in = pmem_rdata;
    assign data_wren = pmem_resp;
    assign tags_in = input1.addr.tag;
    assign tags_wren = pmem_resp;
    assign valid_set = pmem_resp;
    
    /* 5. output correct word */
    assign mem_rdata = data_out[input1.addr.offset[s_offset-1:2] * x_len +: x_len];

    always_ff @(posedge clk) begin : VALIDS_ASSIGNMENT
        if (rst) 
            valids <= '0;
        else if (evict)
            valids[input1.addr.index] <= 1'b0;
        else if (valid_set)
            valids[input1.addr.index] <= 1'b1;
    end

endmodule : inst_cache

