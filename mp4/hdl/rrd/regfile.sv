module regfile #(
    parameter s_index = 5,
    parameter s_width = 32,
    parameter num_read_ports = 4,
    parameter num_write_ports = 2,
    parameter nrp = num_read_ports,
    parameter nwp = num_write_ports
)
(
    input clk,

    // TODO: figure out priority stuff again
    //input logic [swl-1:0] prefer_a,
    input logic [nwp-1:0] ld,
    input logic [s_index-1:0] dest [nwp-1:0],
    input logic [s_width-1:0] in [nwp-1:0],

    input logic [s_index-1:0] src [nrp-1:0],
    output logic [s_width-1:0] out [nrp-1:0]
);

    localparam num_regs = 2**s_index;
    localparam s_write_sel = $clog2(nwp);
    localparam swl = s_write_sel;

    logic [s_width-1:0] data [num_regs];

    genvar rp;
    generate
        for (rp = 0; rp < nrp; rp++) begin : reads
            assign out[rp] = src[rp] != 0 ? data[src[rp]] : '0;
        end
    endgenerate

    always_ff @(posedge clk) begin
        for (int i = 0; i < nwp; i++) begin
            if (ld[i]) begin
                data[dest[i]] <= in[i];
            end
        end
    end

endmodule : regfile
