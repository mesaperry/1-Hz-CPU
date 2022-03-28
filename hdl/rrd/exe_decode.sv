import rv32i_types::*;

module exe_decode (
    CTRLWord cw
);

    always_comb begin
        unique case (cw.uopc)
            uopc::lui    :
            uopc::auipc  :

            uopc::jal    :
            uopc::jalr   :

            uopc::beq    :
            uopc::bne    :
            uopc::blt    : 
            uopc::bge    :
            uopc::bltu   :
            uopc::bgeu   :

            uopc::addi   :
            uopc::slti   :
            uopc::sltiu  :
            uopc::xori   :
            uopc::ori    :
            uopc::andi   :
            uopc::slli   : 
            uopc::srli   :
            uopc::srai   :

            uopc::add    :
            uopc::sub    :
            uopc::sll    :
            uopc::slt    :
            uopc::sltu   :
            uopc::xoro   :
            uopc::srl    :
            uopc::sra    :
            uopc::oro    :
            uopc::ando   :
            default      :
        endcase
    end

    

endmodule : exe_decode
