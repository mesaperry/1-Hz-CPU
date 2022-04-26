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

    /* IMPLEMENTATION */

    // 1
    struct {
        struct packed {
            logic   [s_tag-1:0]     tag;
            logic   [s_index-1:0]   index;
            logic   [s_offset-1:0]  offset;
        } addr;
        rv32i_word  wdata;
        logic       read;
        logic       write;
        logic [3:0] mbe;
    } input0, input1;

    // 2
    logic [s_index-1:0] data_addr, tags_addr;
    logic input_load;

    // 3
    logic valid, dirty, is_operating, hit, miss;

    // 4
    logic invalidate;

    // 5
    logic [255:0] data_in_5;
    logic data_wren_5, cacheline_loaded;

    // 6
    logic [s_tag-1:0] tags_in;
    logic tags_wren, valid_set;

    // 7
    logic do_write, data_wren_7, dirty_set;
    rv32i_word data_in_7;

    // 8
    logic [3:0] bytes_correct;
    logic wdata_success, input1_success;

    // bram and regs
    logic [s_line-1:0] data_out;
    logic [s_tag-1:0] tags_out;

    logic [n_sets-1:0] valids;
    logic [n_sets-1:0] dirtys;

    // WARNING: these guys do not support simultaneous read and write
    bram256x32 data (
        .address (data_addr),
        .clock   (clk),
        .data    (data_wren_5 ? data_in_5 : data_in_7),
        .wren    (data_wren_5 || data_wren_7),
        .q       (data_out)
    );

    bram22x32 tags (
        .address (tags_addr),
        .clock   (clk),
        .data    (tags_in),
        .wren    (tags_wren),
        .q       (tags_out)
    );


    /* IMPLEMENTATION */

    /* 1. wait until cache is not busy */
    assign mem_resp = input1_success;
    assign input_load = input1_success || (!input1.read && !input1.write);
    
    /* 2. load input data into pipeline buffer, access brams */
    assign input0 = '{mem_address, mem_wdata, mem_read, mem_write, mem_mbe};

    always_ff @(posedge clk) begin : INPUT_LOAD
        input1 <= input_load ? input0 : input1;
    end

    assign data_addr = input_load ? input0.addr.index : input1.addr.index;
    assign tags_addr = input_load ? input0.addr.index : input1.addr.index;

    /* 3. check that tag matches and index is valid (hit) */
    assign valid = valids[input1.addr.index];
    assign dirty = dirtys[input1.addr.index];
    assign is_operating = input1.write || input1.read;
    assign hit = is_operating && valid && (input1.addr.tag == tags_out);
    assign miss = is_operating && !hit;

    /* 4. if missed index is valid and dirty -> invalidate and evict cacheline to mem */
    assign pmem_write = miss && valid && dirty;
    assign pmem_wdata = data_out;
    assign pmem_address = {input1.addr.tag, input1.addr.index, {s_offset{1'b0}}};
    assign invalidate = pmem_write && pmem_resp; // invalidation takes 1 cycle

    /* 5. if missed index is invalid -> load cacheline from mem into data bram */
    assign pmem_read = miss && !valid;
    // pmem_address already set
    assign data_in_5 = pmem_rdata;
    assign cacheline_loaded = pmem_read && pmem_resp;
    assign data_wren_5 = cacheline_loaded;

    /* 6. update tag, and set valid */
    assign tags_in = input1.addr.tag;
    assign tags_wren = cacheline_loaded;
    assign valid_set = cacheline_loaded;

    /* 7. mem_write -> write to brams, set dirty */
    assign do_write = hit && mem_write;
    assign data_wren_7 = do_write;
    assign dirty_set = do_write;
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : OVERWRITE_CACHE_DATA
            assign data_in_7[i*8 +: 8] = input1.mbe[i] ?
                input1.wdata[i*8 +: 8] : data_out[i*8 +: 8];
        end
    endgenerate

    /* 8. check operation success */
    assign mem_rdata = data_out[input1.addr.offset[s_offset-1:2] * x_len +: x_len];

    generate
        for (i = 0; i < 4; i++) begin : CHECK_MATCHING_BYTES
            assign bytes_correct[i] = mem_rdata[i*8 +: 8] == input1.wdata[i*8 +: 8];
        end
    endgenerate
    assign wdata_success = (input1.mbe & bytes_correct) == input1.mbe;
    assign input1_success = hit && (input1.read || (input1.write && wdata_success)); // means system has input1 read or write applied

    always_ff @(posedge clk) begin : VALIDS_ASSIGNMENT
        if (rst) 
            valids <= '0;
        else if (invalidate)
            valids[input1.addr.index] <= 1'b0;
        else if (valid_set)
            valids[input1.addr.index] <= 1'b1;
    end

    always_ff @(posedge clk) begin : DIRTYS_ASSIGNMENT
        if (rst) 
            dirtys <= '0;
        else if (invalidate)
            dirtys[input1.addr.index] <= 1'b0;
        else if (dirty_set)
            dirtys[input1.addr.index] <= 1'b1;
    end

endmodule : data_cache

