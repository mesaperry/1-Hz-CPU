import rv32i_types::*;

module CPU ();
    
    tb_itf itf();

    one_hz_cpu cpu(
        .clk             (itf.clk       ),    
        .rst             (itf.rst       ),
        .pc              (itf.inst_addr ),
        .instr           (itf.inst_rdata),
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

endmodule : CPU
