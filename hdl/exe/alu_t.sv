import rv32i_types::*;

module alu_t
(
    input   alufnt::alu_func_t fn,
    input   rv32i_word in1,
    input   rv32i_word in2,
    output  rv32i_word out_t
);

always_comb
begin
    unique case (fn)
        alufnt::add  :  out_t = in1 + in2;
        alufnt::sl   :  out_t = in1 << in2[4:0];
        alufnt::sra  :  out_t = $signed(in1) >>> in2[4:0];
        alufnt::sub  :  out_t = in1 - in2;
        alufnt::xoro :  out_t = in1 ^ in2;
        alufnt::sr   :  out_t = in1 >> in2[4:0];
        alufnt::oro  :  out_t = in1 | in2;
        alufnt::ando :  out_t = in1 & in2;
    endcase
end

endmodule : alu_t
