onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /follower_tb/iDut/clk
add wave -noupdate /follower_tb/iDut/rst_n
add wave -noupdate /follower_tb/iDut/lft
add wave -noupdate /follower_tb/iDut/rht
add wave -noupdate -expand -group {internal adc interface} /follower_tb/iDut/IR_in_en
add wave -noupdate -expand -group {internal adc interface} /follower_tb/iDut/IR_mid_en
add wave -noupdate -expand -group {internal adc interface} /follower_tb/iDut/IR_out_en
add wave -noupdate -expand -group {internal adc interface} /follower_tb/iDut/A2D_res
add wave -noupdate -expand -group {internal adc interface} /follower_tb/iDut/chnnl
add wave -noupdate -expand -group {internal adc interface} /follower_tb/iDut/cnv_cmplt
add wave -noupdate -expand -group {internal adc interface} /follower_tb/iDut/strt_cnv
add wave -noupdate -expand -group {ADC port} /follower_tb/iDut/MISO
add wave -noupdate -expand -group {ADC port} /follower_tb/iDut/a2d_SS_n
add wave -noupdate -expand -group {ADC port} /follower_tb/iDut/SCLK
add wave -noupdate -expand -group {ADC port} /follower_tb/iDut/MOSI
add wave -noupdate -expand -group {internal barcode intf} /follower_tb/iDut/ID
add wave -noupdate -expand -group {internal barcode intf} /follower_tb/iDut/clr_ID_vld
add wave -noupdate -expand -group {internal barcode intf} /follower_tb/iDut/ID_vld
add wave -noupdate -expand -group {Barcode interface} /follower_tb/iDut/BC
add wave -noupdate -expand -group {cmd interface} -radix binary /follower_tb/iDut/cmd
add wave -noupdate -expand -group {cmd interface} /follower_tb/iDut/cmd_rdy
add wave -noupdate -expand -group {cmd interface} /follower_tb/iDut/clr_cmd_rdy
add wave -noupdate -expand -group {UART interface} /follower_tb/iDut/RX
add wave -noupdate -color Green /follower_tb/iDut/go
add wave -noupdate -color Yellow /follower_tb/iDut/OK2Move
add wave -noupdate /follower_tb/iDut/buzz
add wave -noupdate /follower_tb/iDut/buzz_n
add wave -noupdate -color Yellow /follower_tb/iDut/in_transit
add wave -noupdate -expand -group {Cmdctrl FSM} /follower_tb/iDut/iCORE/iCmdctrl/in_transit
add wave -noupdate -expand -group {Cmdctrl FSM} /follower_tb/iDut/iCORE/iCmdctrl/state
add wave -noupdate -expand -group {Cmdctrl FSM} /follower_tb/iDut/iCORE/iCmdctrl/next_state
add wave -noupdate -expand -group {Cmdctrl FSM} /follower_tb/iDut/iCORE/iCmdctrl/dst_ID
add wave -noupdate -expand -group {motion FSM} /follower_tb/iDut/iCORE/iMotion/channel_cnt
add wave -noupdate -expand -group {motion FSM} /follower_tb/iDut/iCORE/iMotion/intgdec
add wave -noupdate -expand -group {motion FSM} /follower_tb/iDut/iCORE/iMotion/state
add wave -noupdate -expand -group {motion FSM} /follower_tb/iDut/iCORE/iMotion/nxt_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {27927550 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 208
configure wave -valuecolwidth 101
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
WaveRestoreZoom {0 ns} {17945225 ns}
