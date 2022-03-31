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

## DATE    "Wed Mar 30 17:55:43 2022"

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
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_resp}]
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
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_rdata[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_resp}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {rst}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {imem_read}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_address[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_byte_enable[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_byte_enable[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_byte_enable[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_byte_enable[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_read}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_wdata[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {mem_write}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {pc[31]}]


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

