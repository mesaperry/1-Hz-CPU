import rv32i_types::*;

module mp4(
    input   clk,
    input   rst,
    output  rv32i_word   pmem_address,
    input   logic [63:0] pmem_rdata,
    output  logic [63:0] pmem_wdata,
    output  logic        pmem_read,
    output  logic        pmem_write,
    input   logic        pmem_resp
);


// CPU instr <-> [bus adapter <-> icache] <-v 
//                                       arbiter <-> cacheline adapter <-> burst
// CPU data  <-> [bus adapter <-> dcache] <-^

/*************************** CPU <-> Instruction Cache ************************/
rv32i_word inst_addr, inst_rdata;
logic inst_read, inst_resp;
/******************************************************************************/
/*************************** CPU <-> Data Cache *******************************/
rv32i_word data_addr, data_rdata, data_wdata;
logic data_read, data_write, data_resp;
logic [3:0] data_mbe;
/******************************************************************************/

/******************** Instruction Cache <-> Arbiter Signals *******************/
rv32i_word inst_cline_address;
logic [255:0] inst_cline_rdata;
logic inst_cline_read, inst_cline_resp;
/******************************************************************************/
/******************** Data Cache <-> Arbiter Signals **************************/
rv32i_word data_cline_address;
logic [255:0] data_cline_rdata, data_cline_wdata;
logic data_cline_read, data_cline_write, data_cline_resp;
/******************************************************************************/

/******************** Arbiter <-> Cacheline Adapter Signals *******************/
rv32i_word cline_address;
logic [255:0] cline_rdata, cline_wdata;
logic cline_read, cline_write, cline_resp;
/******************************************************************************/

one_hz_cpu cpu (
    .clk          (clk        ),
    .rst          (rst        ),
    .pc           (inst_addr  ),
    .inst_rdata   (inst_rdata ),
    .inst_read    (inst_read  ),
    .inst_resp    (inst_resp  ),
    .data_address (data_addr  ),
    .data_rdata   (data_rdata ),  
    .data_wdata   (data_wdata ),
    .data_read    (data_read  ),
    .data_write   (data_write ),
    .data_mbe     (data_mbe   ),
    .data_resp    (data_resp  )
);

inst_cache icache (
    .clk          (clk                ),
    .rst          (rst                ),
    .mem_address  (inst_addr          ),
    .mem_rdata    (inst_rdata         ),
    .mem_read     (inst_read          ),
    .mem_resp     (inst_resp          ),
    .pmem_address (inst_cline_address ),
    .pmem_rdata   (inst_cline_rdata   ),
    .pmem_read    (inst_cline_read    ),
    .pmem_resp    (inst_cline_resp    )
);

data_cache dcache (
    .clk          (clk                ),
    .rst          (rst                ),
    .mem_address  (data_addr          ),
    .mem_rdata    (data_rdata         ),
    .mem_wdata    (data_wdata         ),
    .mem_read     (data_read          ),
    .mem_write    (data_write         ),
    .mem_mbe      (data_mbe           ),
    .mem_resp     (data_resp          ),
    .pmem_address (data_cline_address ),
    .pmem_rdata   (data_cline_rdata   ),
    .pmem_wdata   (data_cline_wdata   ),
    .pmem_read    (data_cline_read    ),
    .pmem_write   (data_cline_write   ),
    .pmem_resp    (data_cline_resp    )
);

arbiter arb (
    .clk              (clk                ),
    .rst              (rst                ),
    .inst_cline_addr  (inst_cline_address ),
    .inst_cline_rdata (inst_cline_rdata   ),
    .inst_cline_read  (inst_cline_read    ),
    .inst_cline_resp  (inst_cline_resp    ),
    .data_cline_addr  (data_cline_address ),
    .data_cline_rdata (data_cline_rdata   ),
    .data_cline_wdata (data_cline_wdata   ),
    .data_cline_read  (data_cline_read    ),
    .data_cline_write (data_cline_write   ),
    .data_cline_resp  (data_cline_resp    ),
    .pmem_address     (cline_address      ),
    .pmem_rdata       (cline_rdata        ),
    .pmem_wdata       (cline_wdata        ),
    .pmem_read        (cline_read         ),
    .pmem_write       (cline_write        ),
    .pmem_resp        (cline_resp         )
);


cacheline_adaptor cacheline_adaptor
(
    .clk       (clk           ),
    .reset_n   (~rst          ),
    .line_i    (cline_wdata   ),
    .line_o    (cline_rdata   ),
    .address_i (cline_address ),
    .read_i    (cline_read    ),
    .write_i   (cline_write   ),
    .resp_o    (cline_resp    ),
    .burst_i   (pmem_rdata    ),
    .burst_o   (pmem_wdata    ),
    .address_o (pmem_address  ),
    .read_o    (pmem_read     ),
    .write_o   (pmem_write    ),
    .resp_i    (pmem_resp     )
);

endmodule : mp4

