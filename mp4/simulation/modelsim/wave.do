onerror {resume}
quietly virtual function -install /mp4_tb/dut/cpu -env /mp4_tb { &{/mp4_tb/dut/cpu/aluqempty, /mp4_tb/dut/cpu/aluqfull }} aluq_sig
quietly virtual function -install /mp4_tb/dut/cpu -env /mp4_tb { &{/mp4_tb/dut/cpu/memqempty, /mp4_tb/dut/cpu/memqfull }} memq_sig
quietly WaveActivateNextPane {} 0
add wave -noupdate /mp4_tb/f
add wave -noupdate /mp4_tb/f
add wave -noupdate /mp4_tb/f
add wave -noupdate /mp4_tb/f
add wave -noupdate -radix hexadecimal /mp4_tb/f
add wave -noupdate -radix hexadecimal /mp4_tb/dut/cpu/clk
add wave -noupdate -radix hexadecimal /mp4_tb/dut/cpu/rst
add wave -noupdate -radix hexadecimal -childformat {{{/mp4_tb/dut/cpu/pc[31]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[30]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[29]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[28]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[27]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[26]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[25]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[24]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[23]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[22]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[21]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[20]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[19]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[18]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[17]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[16]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[15]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[14]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[13]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[12]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[11]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[10]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[9]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[8]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[7]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[6]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[5]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[4]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[3]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[2]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[1]} -radix hexadecimal} {{/mp4_tb/dut/cpu/pc[0]} -radix hexadecimal}} -subitemconfig {{/mp4_tb/dut/cpu/pc[31]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[30]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[29]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[28]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[27]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[26]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[25]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[24]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[23]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[22]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[21]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[20]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[19]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[18]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[17]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[16]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[15]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[14]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[13]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[12]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[11]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[10]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[9]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[8]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[7]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[6]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[5]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[4]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[3]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[2]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[1]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/pc[0]} {-height 16 -radix hexadecimal}} /mp4_tb/dut/cpu/pc
add wave -noupdate -radix hexadecimal -childformat {{{/mp4_tb/dut/cpu/rf/data[0]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[1]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[2]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[3]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[4]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[5]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[6]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[7]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[8]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[9]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10]} -radix hexadecimal -childformat {{{/mp4_tb/dut/cpu/rf/data[10][31]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][30]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][29]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][28]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][27]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][26]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][25]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][24]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][23]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][22]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][21]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][20]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][19]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][18]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][17]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][16]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][15]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][14]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][13]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][12]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][11]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][10]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][9]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][8]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][7]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][6]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][5]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][4]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][3]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][2]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][1]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][0]} -radix hexadecimal}}} {{/mp4_tb/dut/cpu/rf/data[11]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[12]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[13]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[14]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[15]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[16]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[17]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[18]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[19]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[20]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[21]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[22]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[23]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[24]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[25]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[26]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[27]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[28]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[29]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[30]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[31]} -radix hexadecimal}} -expand -subitemconfig {{/mp4_tb/dut/cpu/rf/data[0]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[1]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[2]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[3]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[4]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[5]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[6]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[7]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[8]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[9]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10]} {-height 16 -radix hexadecimal -childformat {{{/mp4_tb/dut/cpu/rf/data[10][31]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][30]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][29]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][28]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][27]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][26]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][25]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][24]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][23]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][22]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][21]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][20]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][19]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][18]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][17]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][16]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][15]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][14]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][13]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][12]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][11]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][10]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][9]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][8]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][7]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][6]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][5]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][4]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][3]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][2]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][1]} -radix hexadecimal} {{/mp4_tb/dut/cpu/rf/data[10][0]} -radix hexadecimal}}} {/mp4_tb/dut/cpu/rf/data[10][31]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][30]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][29]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][28]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][27]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][26]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][25]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][24]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][23]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][22]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][21]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][20]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][19]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][18]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][17]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][16]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][15]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][14]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][13]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][12]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][11]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][10]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][9]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][8]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][7]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][6]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][5]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][4]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][3]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][2]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][1]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[10][0]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[11]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[12]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[13]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[14]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[15]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[16]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[17]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[18]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[19]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[20]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[21]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[22]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[23]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[24]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[25]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[26]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[27]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[28]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[29]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[30]} {-height 16 -radix hexadecimal} {/mp4_tb/dut/cpu/rf/data[31]} {-height 16 -radix hexadecimal}} /mp4_tb/dut/cpu/rf/data
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/imem_read
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/imem_resp
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/dec_says_take
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/dec_confident
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/dec_redir
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/dec_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/dec_target_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/dec_redir_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/exe_says_take
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/exe_redir
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/exe_btype
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/exe_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/exe_target_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/exe_redir_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/fetch_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/npc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/btb_target_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/nextline_pc
add wave -noupdate -expand -group fetch -radix hexadecimal /mp4_tb/dut/cpu/btb_hit
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/instr
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/taken
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/under_shadow
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/opcode
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/funct3
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/funct7
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/imm3125
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/imm2420
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/imm1107
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/imm1912
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/ctrl
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/rd
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/rs1
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/rs2
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/packed_imm
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/bctrl
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/shadowed
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/btarget
add wave -noupdate -group dec -radix hexadecimal /mp4_tb/dut/cpu/dc0/jtarget
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/aluqpush
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/memqpush
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/aluqpop
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/memqpop
add wave -noupdate -expand -group queue -label aluq_empty_full /mp4_tb/dut/cpu/aluq_sig
add wave -noupdate -expand -group queue -label memq_empty_full /mp4_tb/dut/cpu/memq_sig
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/aluqdin
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/memqdin
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/aluqdout
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/memqdout
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/aluqready
add wave -noupdate -expand -group queue /mp4_tb/dut/cpu/memqready
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/uopcode
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/exu_type
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/has_rd
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/has_rs1
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/has_rs2
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/rd
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/rs1
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/rs2
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/imm_type
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/packed_imm
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/taken
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/shadowed
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/pc
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/ctrl
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/reg_a
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/reg_b
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/imm
add wave -noupdate -group alu_rrd -radix hexadecimal /mp4_tb/dut/cpu/arc0/alu_out
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/uopcode
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/exu_type
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/has_rd
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/has_rs1
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/has_rs2
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/rd
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/rs1
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/rs2
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/imm_type
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/packed_imm
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/taken
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/shadowed
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/pc
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/ctrl
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/reg_a
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/reg_b
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/imm
add wave -noupdate -group alu_exe -radix hexadecimal /mp4_tb/dut/cpu/aec0/alu_out
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/uopcode
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/exu_type
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/has_rd
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/has_rs1
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/has_rs2
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/rd
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/rs1
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/rs2
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/imm_type
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/packed_imm
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/taken
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/shadowed
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/pc
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/ctrl
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/reg_a
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/reg_b
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/imm
add wave -noupdate -group alu_wb -radix hexadecimal /mp4_tb/dut/cpu/awc0/alu_out
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/uopcode
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/exu_type
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/has_rd
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/has_rs1
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/has_rs2
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/rd
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/rs1
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/rs2
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/packed_imm
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/ctrl
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/reg_a
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/reg_b
add wave -noupdate -group mem_rrd -radix decimal /mp4_tb/dut/cpu/mrc0/imm
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/addr
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/mbe
add wave -noupdate -group mem_rrd -radix hexadecimal /mp4_tb/dut/cpu/mrc0/mem_out
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mem_address
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mem_rdata
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mem_wdata
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mem_read
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mem_write
add wave -noupdate -group mem_mem -radix binary /mp4_tb/dut/cpu/mem_byte_enable
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mem_resp
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/uopcode
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/exu_type
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/has_rd
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/has_rs1
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/has_rs2
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/rd
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/rs1
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/rs2
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/packed_imm
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/ctrl
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/reg_a
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/reg_b
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/imm
add wave -noupdate -group mem_mem -radix decimal /mp4_tb/dut/cpu/mmc0/addr
add wave -noupdate -group mem_mem -radix binary /mp4_tb/dut/cpu/mmc0/mbe
add wave -noupdate -group mem_mem -radix hexadecimal /mp4_tb/dut/cpu/mmc0/mem_out
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/uopcode
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/exu_type
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/has_rd
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/has_rs1
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/has_rs2
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/rd
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/rs1
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/rs2
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/packed_imm
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/ctrl
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/reg_a
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/reg_b
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/imm
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/addr
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/mbe
add wave -noupdate -group mem_wb -radix hexadecimal /mp4_tb/dut/cpu/mwc0/mem_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26299 ps} 0} {{Cursor 2} {2134439508 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 362
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {21497 ps} {160759 ps}
