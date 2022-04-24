module cacheline_adaptor
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);
    
    // no counting necessary, can assume 
    // full burst is recieved when resp goes low
    // PERF: gotta register main mem outputs for timing

    /*
    logic req;
    assign req = read_i | write_i;

    logic resp_rec;
    always_ff @(posedge clk) begin
        if (req & resp_i) resp_rec <= 1'b1;
        else resp_rec <= 1'b0;
    end

    assign resp_o = resp_rec & ~resp_i;

    logic read_sel;
    always_ff @(posedge clk) begin
        if (~reset_n) read_sel <= 1'b0;
        else if (resp_o) read_sel <= 1'b0;
        else if (read_i) read_sel <= 1'b1;
    end
    assign read_o = read_sel ? ~resp_o : 1'b0;

    logic write_sel;
    always_ff @(posedge clk) begin
        if (~reset_n) write_sel <= 1'b0;
        else if (resp_o) write_sel <= 1'b0;
        else if (write_i) write_sel <= 1'b1;
    end
    assign write_o = write_sel ? ~resp_o : 1'b0;
    */


    // PERF: the fitter might put us really fucking far from the resp_i pin,
    // at which point it's better for timing to do a counter like the 
    // given adapter
    ca_ctrl ctrl (
        .clk,
        .reset_n,
        .read_i,
        .write_i,
        .resp_o,
        .read_o,
        .write_o,
        .resp_i
    );

    always_ff @(posedge clk) begin
        address_o <= address_i;
    end

    shiftin64x4 shi (
        .clk,
        .ld(resp_i & read_o),
        .din(burst_i),
        .dout(line_o)
    );

    // TODO: ensure this is correct
    shiftout64x4 sho (
        .clk,
        .ld(write_i & ~write_o),
        .rd(resp_i & write_o),
        .din(line_i),
        .dout(burst_o)
    );
    

endmodule : cacheline_adaptor

module shiftout64x4 (
    input                 clk,
    input   logic         ld,
    input   logic         rd,
    input   logic [255:0] din,
    output  logic [63:0]  dout
);

    localparam width = 64;
    localparam depth = 4;
    localparam size = width * depth;

    logic [size-1:0] data;
    assign dout = data[width-1:0];

    always_ff @(posedge clk) begin
        if (ld) data[size-1:size-width] <= din[size-1:size-width];
    end

    always_ff @(posedge clk) begin
        if (ld) data[size-width-1:0] <= din[size-width-1:0];
        else if (rd) data[size-width-1:0] <= data[size-1:width];
    end

endmodule : shiftout64x4

module shiftin64x4 (
    input                 clk,
    input   logic         ld,
    input   logic [63:0]  din,
    output  logic [255:0] dout
);
    
    localparam width = 64;
    localparam depth = 4;
    localparam size = width * depth;

    always_ff @(posedge clk) begin
        if (ld) dout <= {din, dout[size-1:width]};
    end

endmodule : shiftin64x4


module ca_ctrl (
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    output logic read_o,
    output logic write_o,
    input resp_i
);
    
    enum int unsigned {
        no,
        r0,
        r1,
        r2,
        r3,
        w0,
        w1,
        w2,
        w3,
        ok
    } state, next_state;
    
    // TODO: evaluate perf: instruction reads currently have
    // added one cycle latency vs data.
    // this can be swapped if we want
    // TODO: maybe don't continually assign pmem_rdata to 
    // both rdata signals. could store last access in reg 
    // and return that?
    // may add latency
    function void set_defaults();
        read_o = 1'b0;
        write_o = 1'b0;
        resp_o = 1'b0;
    endfunction

    always_comb
    begin : state_actions
        /* Default output assignments */
        set_defaults();
        /* Actions for each state */
        case (state)
            no : ;
            r0 : read_o = 1'b1;
            r1 : read_o = 1'b1;
            r2 : read_o = 1'b1;
            r3 : read_o = 1'b1;
            w0 : write_o = 1'b1;
            w1 : write_o = 1'b1;
            w2 : write_o = 1'b1;
            w3 : write_o = 1'b1;
            ok : resp_o = 1'b1;
        endcase
    end

    always_comb
    begin : next_state_logic
        /* Next state information and conditions (if any)
         * for transitioning between states */
        next_state = no;
        case (state)
            // ignores simultaneous reads and writes
            no : begin
                     unique case ({read_i, write_i})
                         2'b10   : next_state = r0;
                         2'b01   : next_state = w0;
                         default : next_state = no;
                     endcase
                 end
            r0 : next_state = resp_i ? r1 : r0;
            r1 : next_state = r2;
            r2 : next_state = r3;
            r3 : next_state = ok;
            w0 : next_state = resp_i ? w1 : w0;
            w1 : next_state = w2;
            w2 : next_state = w3;
            w3 : next_state = ok;
            ok : next_state = no;
        endcase
    end

    // PERF: adding posedge rst here
    // slightly improved timings
    always_ff @(posedge clk)
    begin: next_state_assignment
        if (~reset_n)
            state <= no;
        else
            state <= next_state;
    end

endmodule : ca_ctrl

module ca_ctrl_given (
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    output logic read_o,
    output logic write_o,
    input resp_i
);
    typedef enum bit [2:0] {IDLE, WAITR, WAITW, R, W, DONE} macro_t;
    struct packed {
        macro_t macro;
        logic [1:0] count;
    } state;
    localparam logic [1:0] maxcount = 2'b11;


    assign read_o = ((state.macro == WAITR) || (state.macro == R));
    assign write_o = ((state.macro == WAITW) || (state.macro == W));
    assign resp_o = state.macro == DONE;
    enum bit [1:0] {READ_OP, WRITE_OP, NO_OP} op;
    assign op = read_i ? READ_OP : write_i ? WRITE_OP : NO_OP;

    always_ff @(posedge clk) begin
        if (~reset_n) begin
            state.macro <= IDLE;
        end
        else begin
            case (state.macro)
            IDLE: begin
                case (op)
                    NO_OP: ;
                    WRITE_OP: begin
                        state.macro <= WAITW;
                        state.count <= 2'b00;
                    end
                    READ_OP: begin
                        state.macro <= WAITR;
                    end
                endcase
            end
            WAITR: begin
                if (resp_i) begin
                    state.macro <= R;
                    state.count <= 2'b01;
                end
            end
            WAITW: begin
                if (resp_i) begin
                    state.macro <= W;
                    state.count <= 2'b01;
                end
            end
            R: begin
                if (state.count == maxcount) begin
                    state.macro <= DONE;
                end
                state.count <= state.count + 2'b01;
            end
            W: begin
                if (state.count == maxcount) begin
                    state.macro <= DONE;
                end
                state.count <= state.count + 2'b01;
            end
            DONE: begin
                state.macro <= IDLE;
            end
            endcase
        end
    end
endmodule : ca_ctrl_given
