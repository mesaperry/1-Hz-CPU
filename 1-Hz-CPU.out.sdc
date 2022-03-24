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

## DATE    "Thu Mar 24 02:16:38 2022"

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
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {fetch_PC[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {load}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_PC[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_btype[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_btype[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {new_target[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {rst}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {btype[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {btype[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {hit}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  0.000 [get_ports {target[29]}]


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

