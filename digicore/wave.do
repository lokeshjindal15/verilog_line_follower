onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dig_core_tb/clk
add wave -noupdate /dig_core_tb/rst_n
add wave -noupdate /dig_core_tb/IR_in_en
add wave -noupdate /dig_core_tb/IR_mid_en
add wave -noupdate /dig_core_tb/IR_out_en
add wave -noupdate /dig_core_tb/lft
add wave -noupdate /dig_core_tb/rht
add wave -noupdate /dig_core_tb/lft_reg_sgex
add wave -noupdate /dig_core_tb/rht_reg_sgex
add wave -noupdate /dig_core_tb/lft_ref
add wave -noupdate /dig_core_tb/rht_ref
add wave -noupdate /dig_core_tb/go
add wave -noupdate /dig_core_tb/strt_cnv
add wave -noupdate -color Red /dig_core_tb/cnv_cmplt
add wave -noupdate /dig_core_tb/chnnl
add wave -noupdate /dig_core_tb/A2D_res
add wave -noupdate /dig_core_tb/A2D_mem
add wave -noupdate /dig_core_tb/ptr
add wave -noupdate /dig_core_tb/motor_ref
add wave -noupdate /dig_core_tb/refptr
add wave -noupdate /dig_core_tb/i
add wave -noupdate /dig_core_tb/cmd_rdy
add wave -noupdate /dig_core_tb/ID_vld
add wave -noupdate /dig_core_tb/in_transit
add wave -noupdate /dig_core_tb/cmd
add wave -noupdate /dig_core_tb/ID
add wave -noupdate /dig_core_tb/clr_cmd_rdy
add wave -noupdate /dig_core_tb/clr_ID_vld
add wave -noupdate /dig_core_tb/counter
add wave -noupdate /dig_core_tb/OK2Move
add wave -noupdate /dig_core_tb/iDUT/iMotion/state
add wave -noupdate /dig_core_tb/iDUT/iMotion/nxt_state
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/A2D_res
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/cnv_cmplt
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/go
add wave -noupdate -expand -group {motion block} -color Yellow /dig_core_tb/iDUT/iMotion/Accum
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/Pcomp
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/Pterm
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/Fwd
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/Error
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/Intgrl
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/Icomp
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/Iterm
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/dst
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/dst2accum
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/dst2error
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/dst2intgrl
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/dst2icomp
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/dst2pcomp
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/dst2lft
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/dst2rht
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/state
add wave -noupdate -expand -group {motion block} /dig_core_tb/iDUT/iMotion/nxt_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9000095 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 271
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
WaveRestoreZoom {8912589 ns} {9025917 ns}
