## Generated SDC file "1-Hz-CPU.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

## DATE    "Sun Mar 27 19:44:24 2022"

##
## DEVICE  "EP2AGX45DF25I3"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 5.000 -waveform { 0.000 2.500 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {clk}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {instr[31]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {exu_type[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {exu_type[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {has_rd}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {has_rs1}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {has_rs2}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imm_type[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imm_type[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imm_type[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {iq_type}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {is_br}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {is_jal}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {is_jalr}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {packed_imm[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {shadowable}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {uopcode[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {uopcode[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {uopcode[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {uopcode[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {uopcode[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {uopcode[5]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

