module branch_target_buffer #(
    parameter s_offset = 3,
    parameter s_tag    = 32 - s_offset,
    parameter n_ways   = 16,
    parameter s_data   = 32 // target (fetch PC + bidx) + ret + jmp
)
(
    input clk,
    input rst,

    input   logic [28:0]   new_PC,
    input   logic [29:0]   new_target,
    input   logic [1:0]    new_btype,
    input   logic          load,

    input   logic [28:0]   fetch_PC,

    output  logic [29:0]   target,
    output  logic [1:0]    btype, // TODO: make enum
    output  logic          hit
);

    logic [s_tag-1:0] tag;
    logic [s_tag-1:0] new_tag;
    assign tag = fetch_PC;
    assign new_tag = new_PC;


    logic [n_ways-1:0] read_way;
    logic [n_ways-1:0] write_way;
    assign hit = |read_way;


    logic [s_data-1:0] dataout;
    logic [s_data-1:0] datain;
    assign {target, btype} = dataout;
    assign datain = {new_target, new_btype};

    data_ways #(
        n_ways,
        s_data
    )
    data_ways_inst (
        .clk,
        .read_way,
        .write_way,
        .load,
        .datain,
        .dataout
    );

    way_selector #(
        n_ways,
        s_tag
    )
    way_selector_inst (
        .clk,
        .rst,
        .tag,
        .new_tag,
        .write_way,
        .load,
        .read_way
    );

    plru_tracker #(
        n_ways
    )
    plru_tracker_inst (
        .clk,
        .rst,
        .load,
        .read_way,
        .write_way
    );

endmodule : branch_target_buffer


module plru_tracker #(
    parameter n_ways
)
(
    input   logic               clk,
    input   logic               rst,
    input   logic               load,
    input   logic [n_ways-1:0]  read_way,
    output  logic [n_ways-1:0]  write_way
);

    logic [n_ways-2:0] s;
    logic [n_ways-2:0] n_s;

    always_comb
    begin
        // TODO: if we rewind all the way back to fetch on branch misspredict,
        // then remove the ternary below, since the read in fetch will
        // refresh plru
        unique case (load ? write_way : read_way) // adding this condition to input fixes testbench, but made it slightly slower
            16'b0000000000000001 : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05], s[04],  1'b0,  1'b0,  1'b0,  1'b0};
            16'b0000000000000010 : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05], s[04],  1'b1,  1'b0,  1'b0,  1'b0};
            16'b0000000000000100 : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05],  1'b0, s[03],  1'b1,  1'b0,  1'b0}; 
            16'b0000000000001000 : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05],  1'b1, s[03],  1'b1,  1'b0,  1'b0}; 
            16'b0000000000010000 : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07],  1'b0,  1'b0, s[04], s[03], s[02],  1'b1,  1'b0}; 
            16'b0000000000100000 : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07],  1'b1,  1'b0, s[04], s[03], s[02],  1'b1,  1'b0}; 
            16'b0000000001000000 : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08],  1'b0, s[06],  1'b1, s[04], s[03], s[02],  1'b1,  1'b0}; 
            16'b0000000010000000 : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08],  1'b1, s[06],  1'b1, s[04], s[03], s[02],  1'b1,  1'b0}; 
            16'b0000000100000000 : n_s = {s[14], s[13], s[12], s[11],  1'b0,  1'b0,  1'b0, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}; 
            16'b0000001000000000 : n_s = {s[14], s[13], s[12], s[11],  1'b1,  1'b0,  1'b0, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}; 
            16'b0000010000000000 : n_s = {s[14], s[13], s[12],  1'b0, s[10],  1'b1,  1'b0, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}; 
            16'b0000100000000000 : n_s = {s[14], s[13], s[12],  1'b1, s[10],  1'b1,  1'b0, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}; 
            16'b0001000000000000 : n_s = {s[14],  1'b0,  1'b0, s[11], s[10], s[09],  1'b1, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}; 
            16'b0010000000000000 : n_s = {s[14],  1'b1,  1'b0, s[11], s[10], s[09],  1'b1, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}; 
            16'b0100000000000000 : n_s = { 1'b0, s[13],  1'b1, s[11], s[10], s[09],  1'b1, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}; 
            16'b1000000000000000 : n_s = { 1'b1, s[13],  1'b1, s[11], s[10], s[09],  1'b1, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}; 
            default              : n_s = {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05], s[04], s[03], s[02], s[01], s[00]};
        endcase
    end

    /*
    logic [n_ways-2:0] n_s_arr[n_ways];
    assign n_s_arr =
        '{
            {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05], s[04],  1'b0,  1'b0,  1'b0,  1'b0},
            {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05], s[04],  1'b1,  1'b0,  1'b0,  1'b0},
            {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05],  1'b0, s[03],  1'b1,  1'b0,  1'b0},
            {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07], s[06], s[05],  1'b1, s[03],  1'b1,  1'b0,  1'b0},
            {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07],  1'b0,  1'b0, s[04], s[03], s[02],  1'b1,  1'b0},
            {s[14], s[13], s[12], s[11], s[10], s[09], s[08], s[07],  1'b1,  1'b0, s[04], s[03], s[02],  1'b1,  1'b0},
            {s[14], s[13], s[12], s[11], s[10], s[09], s[08],  1'b0, s[06],  1'b1, s[04], s[03], s[02],  1'b1,  1'b0},
            {s[14], s[13], s[12], s[11], s[10], s[09], s[08],  1'b1, s[06],  1'b1, s[04], s[03], s[02],  1'b1,  1'b0},
            {s[14], s[13], s[12], s[11],  1'b0,  1'b0,  1'b0, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1},
            {s[14], s[13], s[12], s[11],  1'b1,  1'b0,  1'b0, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1},
            {s[14], s[13], s[12],  1'b0, s[10],  1'b1,  1'b0, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1},
            {s[14], s[13], s[12],  1'b1, s[10],  1'b1,  1'b0, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1},
            {s[14],  1'b0,  1'b0, s[11], s[10], s[09],  1'b1, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1},
            {s[14],  1'b1,  1'b0, s[11], s[10], s[09],  1'b1, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1},
            { 1'b0, s[13],  1'b1, s[11], s[10], s[09],  1'b1, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1},
            { 1'b1, s[13],  1'b1, s[11], s[10], s[09],  1'b1, s[07], s[06], s[05], s[04], s[03], s[02], s[01],  1'b1}
        };


    one_hot_mux #(n_ways-1, n_ways)
    way_mux (
        .sel(read_way),
        .data_ways(n_s_arr),
        .data_out(n_s)
    );
    */

    always_comb
    begin
        unique casez (s)
            15'b???????????1111 : write_way <= 16'b0000000000000001;
            15'b???????????0111 : write_way <= 16'b0000000000000010;
            15'b??????????1?011 : write_way <= 16'b0000000000000100;
            15'b??????????0?011 : write_way <= 16'b0000000000001000;
            15'b????????11???01 : write_way <= 16'b0000000000010000;
            15'b????????01???01 : write_way <= 16'b0000000000100000;
            15'b???????1?0???01 : write_way <= 16'b0000000001000000;
            15'b???????0?0???01 : write_way <= 16'b0000000010000000;
            15'b????111???????0 : write_way <= 16'b0000000100000000;
            15'b????011???????0 : write_way <= 16'b0000001000000000;
            15'b???1?01???????0 : write_way <= 16'b0000010000000000;
            15'b???0?01???????0 : write_way <= 16'b0000100000000000;
            15'b?11???0???????0 : write_way <= 16'b0001000000000000;
            15'b?01???0???????0 : write_way <= 16'b0010000000000000;
            15'b1?0???0???????0 : write_way <= 16'b0100000000000000;
            15'b0?0???0???????0 : write_way <= 16'b1000000000000000;
            default             : write_way <= 16'b0000000000000000;
        endcase
    end
        

    always_ff @(posedge clk)
    begin
        if (rst) begin
            s <= '0;
        end
        else begin
            s <= n_s;
        end
    end

endmodule : plru_tracker


module way_selector #(
    parameter n_ways,
    parameter s_tag
)
(
    input   logic               clk,
    input   logic               rst,
    input   logic [s_tag-1:0]   tag,
    input   logic [s_tag-1:0]   new_tag,
    input   logic [n_ways-1:0]  write_way,
    input   logic               load,
    output  logic [n_ways-1:0]  read_way
);

    genvar i;
    generate
        for (i = 0; i < n_ways; i++) begin : gen_tag_ways
            // TODO: explore synthesis ramstyle options
            logic [s_tag-1:0] tag_data;
            logic valid;

            always_ff @(posedge clk)
            begin
                if (rst) begin
                    tag_data <= '0;
                    valid <= 1'b0;
                end
                else if(write_way[i] & load) begin
                    tag_data <= new_tag;
                    valid <= 1'b1;
                end
            end

            assign read_way[i] = (tag == tag_data) & valid;
        end
    endgenerate
    
endmodule : way_selector



module data_ways #(
    parameter n_ways,
    parameter s_data
)
(
    input   logic               clk,
    input   logic [n_ways-1:0]  read_way,
    input   logic [n_ways-1:0]  write_way,
    input   logic               load,
    input   logic [s_data-1:0]  datain,
    output  logic [s_data-1:0]  dataout
);

    logic [s_data-1:0] data_out_way[n_ways];

    one_hot_mux #(s_data, n_ways)
    way_mux (
        .sel(read_way),
        .data_ways(data_out_way),
        .data_out(dataout)
    );

    // slower
    /*
    always_comb
    begin
        unique case (read_way)
            16'b0000000000000001 : dataout = data_out_way[0];
            16'b0000000000000010 : dataout = data_out_way[1];
            16'b0000000000000100 : dataout = data_out_way[2];
            16'b0000000000001000 : dataout = data_out_way[3];
            16'b0000000000010000 : dataout = data_out_way[4];
            16'b0000000000100000 : dataout = data_out_way[5];
            16'b0000000001000000 : dataout = data_out_way[6];
            16'b0000000010000000 : dataout = data_out_way[7];
            16'b0000000100000000 : dataout = data_out_way[8];
            16'b0000001000000000 : dataout = data_out_way[9];
            16'b0000010000000000 : dataout = data_out_way[10];
            16'b0000100000000000 : dataout = data_out_way[11];
            16'b0001000000000000 : dataout = data_out_way[12];
            16'b0010000000000000 : dataout = data_out_way[13];
            16'b0100000000000000 : dataout = data_out_way[14];
            16'b1000000000000000 : dataout = data_out_way[15];
            default              : dataout = 'X;
        endcase
    end
    */


    genvar i;
    generate
        for (i = 0; i < n_ways; i++) begin : gen_data_ways
            // TODO: explore synthesis ramstyle options
            always_ff @(posedge clk)
            begin
                if(write_way[i] & load) begin
                    data_out_way[i] <= datain;
                end
            end
        end
    endgenerate


endmodule : data_ways

module one_hot_mux #(
    parameter width,
    parameter n_ways
)
(
    input   logic [n_ways-1:0] sel,
    input   logic [width-1:0]  data_ways[n_ways],
    output  logic [width-1:0]  data_out
);

    always_comb begin
        data_out = '0;
        for (int unsigned i = 0; i < n_ways; i++) begin: gen_mux_out
            data_out |= {width{sel[i]}} & data_ways[i];
        end
    end

endmodule : one_hot_mux

