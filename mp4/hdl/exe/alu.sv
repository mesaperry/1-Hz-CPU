import rv32i_types::*;
import ctrl_sigs::*;

module alu (
    input   alufnt::alu_func_t fn,
    input   rv32i_word in1,
    input   rv32i_word in2,
    output  rv32i_word out,
    output  rv32i_word adder_out,
    output  rv32i_word cmp_out
);

    logic is_sub;
    logic is_cmp;
    logic cmp_unsigned;
    logic cmp_inverted;
    logic cmp_eq;

    assign is_sub = fn[3];
    assign is_cmp = fn >= alufnt::slt;
    assign cmp_unsigned = fn[1];
    assign cmp_inverted = fn[0];
    assign cmp_eq = !fn[3];

    rv32i_word in2_inv;
    rv32i_word in1_xor_in2;

    assign in2_inv = is_sub ? ~in2 : in2;
    assign in1_xor_in2 = in1 ^ in2;
    assign adder_out = in1 + in2_inv + is_sub;

    logic slt;

    assign slt = in1[31] == in2[31] 
               ? adder_out[31] 
               : cmp_unsigned ? in2[31] : in1[31];
    assign cmp_out = cmp_inverted ^ (cmp_eq ? in1_xor_in2 == 0 : slt);

    logic [4:0] shamt;
    rv32i_word shin_r;
    rv32i_word shin_l;

    assign shamt = in2[4:0];
    assign shin_r = in1;
    always_comb begin
        for (int n = 0; n < 32; n++) begin
            shin_l[n] <= in1[31-n];
        end
    end

    rv32i_word shin;
    rv32i_word shout_r;
    rv32i_word shout_l;
    rv32i_word shout;

    assign shin = fn == alufnt::sr || fn == alufnt::sra ? shin_r : shin_l;
    assign shout_r = $signed({is_sub & shin[31], shin}) >>> shamt;
    always_comb begin
        for (int n = 0; n < 32; n++) begin
            shout_l[n] <= shout_r[31-n];
        end
    end
    assign shout = (fn == alufnt::sr || fn == alufnt::sra ? shout_r : '0) | 
                   (fn == alufnt::sl                      ? shout_l : '0);

    rv32i_word logic_out;
    rv32i_word shift_logic;

    assign logic_out = (fn == alufnt::xoro || fn == alufnt::oro ? in1_xor_in2 : '0) | 
                       (fn == alufnt::oro || fn == alufnt::ando ? in1 & in2 : '0);
    assign shift_logic = (is_cmp & slt) | logic_out | shout;

    assign out = fn == alufnt::add || fn == alufnt::sub ? adder_out : shift_logic;


endmodule : alu

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
