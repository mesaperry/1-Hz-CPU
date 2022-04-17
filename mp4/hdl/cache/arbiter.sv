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

    enum int unsigned {
        idle = 0,
        srvi = 2,
        srvd = 4,
        siqd = 8,
        sdqi = 16
    } state, next_state;
    
    // TODO: evaluate perf: instruction reads currently have
    // added one cycle latency vs data.
    // this can be swapped if we want
    // TODO: maybe don't continually assign pmem_rdata to 
    // both rdata signals. could store last access in reg 
    // and return that?
    // may add latency
    function void set_defaults();
        inst_cline_rdata = pmem_rdata;
        inst_cline_resp = 1'b0;
        data_cline_rdata = pmem_rdata;
        data_cline_resp = 1'b0;
        pmem_address = data_cline_addr;
        pmem_wdata = data_cline_wdata;
        pmem_read = data_cline_read;
        pmem_write = data_cline_write;
    endfunction

    logic inst_sig;
    logic data_sig;
    assign inst_sig = inst_cline_read;
    assign data_sig = data_cline_read | data_cline_write;

    always_comb
    begin : state_actions
        /* Default output assignments */
        set_defaults();
        /* Actions for each state */
        case (state)
            idle : ;
            srvi : begin
                       inst_cline_resp = pmem_resp;
                       pmem_address = inst_cline_addr;
                       pmem_read = inst_cline_read;
                       pmem_write = 1'b0;
                   end
            srvd : data_cline_resp = pmem_resp;
            siqd : begin
                       inst_cline_resp = pmem_resp;
                       pmem_address = inst_cline_addr;
                       pmem_read = inst_cline_read;
                       pmem_write = 1'b0;
                   end
            sdqi : data_cline_resp = pmem_resp;
        endcase
    end

    always_comb
    begin : next_state_logic
        /* Next state information and conditions (if any)
         * for transitioning between states */
        next_state = idle;
        case (state)
            idle : begin
                       unique case ({inst_sig, data_sig})
                           2'b10   : next_state = srvi;
                           2'b01   : next_state = srvd;
                           2'b11   : next_state = sdqi;
                           default : next_state = idle;
                       endcase
                   end
            srvi : next_state = pmem_resp ? idle : data_sig ? siqd : srvi;
            srvd : next_state = pmem_resp ? idle : inst_sig ? sdqi : srvd;
            siqd : next_state = pmem_resp ? srvd : siqd;
            sdqi : next_state = pmem_resp ? srvi : sdqi;
        endcase
    end

    // PERF: adding posedge rst here
    // slightly improved timings
    always_ff @(posedge clk or posedge rst)
    begin: next_state_assignment
        if (rst)
            state <= idle;
        else
            state <= next_state;
    end

endmodule : arbiter
