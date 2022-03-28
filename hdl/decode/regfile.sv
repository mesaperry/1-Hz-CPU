module regfile #(
    parameter s_width = 32,
    parameter s_index = 5
)
(
    input clk,
	 
    input load,
	 input [s_index-1:0] dest,
    input [s_width-1:0] in,
	 
    input [s_index-1:0] src_a, src_b,
    output logic [s_width-1:0] reg_a, reg_b
);

localparam num_regs = 2**s_index;

logic [s_width-1:0] data [num_regs];

always_ff @(posedge clk)
begin
	 if (load) begin
        data[dest] <= in;
    end
end

always_comb
begin
    reg_a = src_a ? data[src_a] : 0;
    reg_b = src_b ? data[src_b] : 0;
end

endmodule : regfile