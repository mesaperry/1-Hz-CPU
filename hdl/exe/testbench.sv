import rv32i_types::*;

module testbench();
    timeunit 1ns;

    logic clk;

    alufnt::alu_func_t fn;
    rv32i_word in1;
    rv32i_word in2;
    rv32i_word out;
    rv32i_word out_t;
    rv32i_word adder_out;
    rv32i_word cmp_out;
    
    time timestamp;
    task finish();
        repeat (100) @(posedge clk);
        //$finish;
    endtask : finish

    // Generate clk signal
    always #5 clk = (clk === 1'b0);

    initial timestamp = 0;
    always @(posedge clk) timestamp += 1;

    alu ALU (.*);
    alu_t alutest(.*);

    default clocking tb_clk @(negedge clk); endclocking

    initial begin
        $display("starting ALU tests");
        for (in1 = 0; in1 < 10; in1++) begin
            for (in2 = 0; in2 < 10; in2++) begin
                fn <= alufnt::add;
                ##1;
                assert (out == out_t) else $error("%0t TB: ALUs don't match", $time);

                fn <= alufnt::sl;
                ##1;
                assert (out == out_t) else $error("%0t TB: ALUs don't match", $time);

                fn <= alufnt::sra;
                ##1;
                assert (out == out_t) else $error("%0t TB: ALUs don't match", $time);

                fn <= alufnt::sub;
                ##1;
                assert (out == out_t) else $error("%0t TB: ALUs don't match", $time);

                fn <= alufnt::xoro;
                ##1;
                assert (out == out_t) else $error("%0t TB: ALUs don't match", $time);

                fn <= alufnt::sr;
                ##1;
                assert (out == out_t) else $error("%0t TB: ALUs don't match", $time);

                fn <= alufnt::oro;
                ##1;
                assert (out == out_t) else $error("%0t TB: ALUs don't match", $time);

                fn <= alufnt::ando;
                ##1;
                assert (out == out_t) else $error("%0t TB: ALUs don't match", $time);

            end
        end

        finish();

    end


endmodule : testbench

