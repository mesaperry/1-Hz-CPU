/*
module top (
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
*/
module testbench();
    timeunit 1ns;

    logic clk;
    logic rst;

    logic [28:0]   new_PC;
    logic [29:0]   new_target;
    logic [1:0]    new_btype;
    logic          load;

    logic [28:0]   fetch_PC;

    logic [29:0]   target;
    logic [1:0]    btype; // TODO: make enum
    logic          hit;
    
    time timestamp;
    task finish();
        repeat (100) @(posedge clk);
        //$finish;
    endtask : finish

    // Generate clk signal
    always #5 clk = (clk === 1'b0);

    initial timestamp = 0;
    always @(posedge clk) timestamp += 1;

    branch_target_buffer BTB (.*);

    default clocking tb_clk @(negedge clk); endclocking

    task reset();
        rst <= 1'b1;
        repeat (5) @(tb_clk);
        rst <= 1'b0;
        repeat (5) @(tb_clk);
    endtask

    task read(input logic [28:0] key);
    begin
        fetch_PC <= key;
        ##1;
    end
    endtask

    task write(input logic [28:0] key, input logic [31:0] value);
    begin
        load <= 1'b1;
        new_PC <= key;
        {new_target, new_btype} <= value;
        ##1;
        load <= 1'b0;
    end
    endtask

    logic [31:0] out_val;
    assign out_val = {target, btype};
    logic [28:0] test_key;
    logic [31:0] test_val;

    initial begin
        $display("starting BTB tests");

        reset();

        read(29'b0);

        assert (hit == 1'b0) else $error("%0t TB: expected miss after reset", $time);

        test_key <= 29'b01010101010101010101010101010;
        test_val <= 32'b01010101010101010101010101010101;
        ##1;

        write(test_key, test_val);

        read(test_key);

        assert (hit == 1'b1) else $error("%0t TB: no hit after read to just written key", $time);


        assert(out_val == test_val) else $error("%0t TB: read val does not match just written val", $time);

        for (test_key = 0; test_key < 16; test_key++) begin
            write(test_key, {3'b000, test_key});
        end

        for (test_key = 0; test_key < 16; test_key++) begin
            read(test_key);
        assert (hit == 1'b1) else $error("%0t TB: no hit after read to prev cycle write", $time);
            assert(out_val == {3'b000, test_key}) else $error("%0t TB: no hit after read prev cycle write", $time);
        end

        finish();

    end


endmodule : testbench
//endmodule : top

