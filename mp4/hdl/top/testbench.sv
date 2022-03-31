`include "../../hvl/tb_itf.sv"
import rv32i_types::*;

module testbench ();
    
    tb_itf itf();
    rv32i_word instr;
    logic rst;
    assign itf.rst = rst;
    logic clk;
    assign clk = itf.clk;
    default clocking tb_clk @(posedge clk); endclocking

    one_hz_cpu cpu(
        .clk             (itf.clk       ),    
        .rst             (itf.rst       ),
        .pc              (itf.inst_addr ),
        .instr           (instr),//(itf.inst_rdata),
        .imem_read       (itf.inst_read ),
        .imem_resp       (itf.inst_resp ),
        .mem_address     (itf.data_addr ),
        .mem_rdata       (itf.data_rdata),  
        .mem_wdata       (itf.data_wdata),
        .mem_read        (itf.data_read ),
        .mem_write       (itf.data_write),
        .mem_byte_enable (itf.data_mbe  ),
        .mem_resp        (itf.data_resp )
    );



    task reset();
        rst <= 1'b1;
        repeat (5) @(tb_clk);
        rst <= 1'b0;
        repeat (5) @(tb_clk);
    endtask

    initial begin
        $display("starting BTB tests");

        reset();

        instr <= 32'b000000001111_00000_000_00001_0010011;
        ##1;
        instr <= 32'b000000011111_00000_000_00010_0010011;
        ##1;
        instr <= 32'b000000111111_00000_000_00011_0010011;
        ##1;
        instr <= 32'b000001111111_00000_000_00100_0010011;
        ##1 
        instr <= 32'b000011111111_00000_000_00101_0010011;
        ##1;
        instr <= 32'b000111111111_00000_000_00111_0010011;
        ##1 
        instr <= 32'b001111111111_00000_000_01000_0010011;
        ##1;
        instr <= 32'b011111111111_00000_000_01001_0010011;
        ##1;
        instr <= 32'b0000000_00010_00001_000_01010_0110011;


        
    end

endmodule : testbench
