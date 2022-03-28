module regfile #(
	parameter s_width = 32,
	parameter s_index = 5
)
(
	input clk,

	input prefer_a,
	input ld_a, ld_b,
	input [s_index-1:0] dest_a, dest_b,
	input [s_width-1:0] in_a, in_b,

	input [s_index-1:0] src_a, src_b,
	output logic [s_width-1:0] reg_a, reg_b
);

localparam num_regs = 2**s_index;

logic [s_width-1:0] data [num_regs];

assign reg_a = data[src_a];
assign reg_b = data[src_b];

always_ff @(posedge clk)
begin
	if (ld_a && ld_b && dest_a == dest_b) begin
		// loads to same reg is requested, look towards priority bit
		data[dest_a] <= prefer_a ? in_a : in_b;
	end else begin
		if (ld_a) begin
			data[dest_a] <= in_a;
		end
		if (ld_b) begin
			data[dest_b] <= in_b;
		end
	end
end

endmodule : regfile