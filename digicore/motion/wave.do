onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /motion_tb/iDUT/clk
add wave -noupdate /motion_tb/iDUT/rst_n
add wave -noupdate /motion_tb/iDUT/A2D_res
add wave -noupdate /motion_tb/iDUT/cnv_cmplt
add wave -noupdate /motion_tb/iDUT/chnnl
add wave -noupdate /motion_tb/iDUT/strt_cnv
add wave -noupdate /motion_tb/iDUT/IR_in_en
add wave -noupdate /motion_tb/iDUT/IR_mid_en
add wave -noupdate /motion_tb/iDUT/IR_out_en
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/Accum
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/Pcomp
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/Pterm
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/Fwd
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/Error
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/Intgrl
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/Icomp
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/Iterm
add wave -noupdate -expand -group {PI Math} /motion_tb/iDUT/dst
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/multiply
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/sub
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/mult2
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/mult4
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/saturate
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/src0sel
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/src1sel
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/rstaccum
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/dst2accum
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/dst2error
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/dst2intgrl
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/dst2icomp
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/dst2pcomp
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/dst2lft
add wave -noupdate -expand -group {Math control} /motion_tb/iDUT/dst2rht
add wave -noupdate /motion_tb/iDUT/lft_reg
add wave -noupdate /motion_tb/iDUT/rht_reg
add wave -noupdate /motion_tb/iDUT/ir_timer
add wave -noupdate /motion_tb/iDUT/channel_cnt
add wave -noupdate /motion_tb/iDUT/intgdec
add wave -noupdate /motion_tb/iDUT/reset_timer
add wave -noupdate /motion_tb/iDUT/en_timer
add wave -noupdate /motion_tb/iDUT/timer_4095
add wave -noupdate /motion_tb/iDUT/timer_32
add wave -noupdate /motion_tb/iDUT/inc_intgdec
add wave -noupdate /motion_tb/iDUT/inc_channel_cnt
add wave -noupdate /motion_tb/iDUT/reset_channel_cnt
add wave -noupdate /motion_tb/iDUT/update_IR_en
add wave -noupdate /motion_tb/iDUT/clear_IR_all
add wave -noupdate /motion_tb/iDUT/go
add wave -noupdate /motion_tb/iDUT/state
add wave -noupdate /motion_tb/iDUT/nxt_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {359 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 217
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
WaveRestoreZoom {0 ns} {840 ns}
