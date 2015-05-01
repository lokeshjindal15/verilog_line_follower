onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /multi_unit_tb/clk
add wave -noupdate /multi_unit_tb/rst_n
add wave -noupdate /multi_unit_tb/lft
add wave -noupdate /multi_unit_tb/rht
add wave -noupdate -expand -group {adc interface} /multi_unit_tb/IR_in_en
add wave -noupdate -expand -group {adc interface} /multi_unit_tb/IR_mid_en
add wave -noupdate -expand -group {adc interface} /multi_unit_tb/IR_out_en
add wave -noupdate -expand -group {adc interface} /multi_unit_tb/strt_cnv
add wave -noupdate -expand -group {adc interface} /multi_unit_tb/cnv_cmplt
add wave -noupdate -expand -group {adc interface} /multi_unit_tb/chnnl
add wave -noupdate -expand -group {adc interface} /multi_unit_tb/A2D_res
add wave -noupdate -color Yellow /multi_unit_tb/go
add wave -noupdate -expand -group {ADC Interface} /multi_unit_tb/SCLK
add wave -noupdate -expand -group {ADC Interface} /multi_unit_tb/MISO
add wave -noupdate -expand -group {ADC Interface} /multi_unit_tb/MOSI
add wave -noupdate -expand -group {ADC Interface} /multi_unit_tb/a2d_SS_n
add wave -noupdate -expand -group {barcode to Digicore} /multi_unit_tb/ID_vld
add wave -noupdate -expand -group {barcode to Digicore} /multi_unit_tb/ID
add wave -noupdate -expand -group {barcode to Digicore} /multi_unit_tb/clr_ID_vld
add wave -noupdate -expand -group {bar code interface} /multi_unit_tb/BC
add wave -noupdate -expand -group {UART to Digcore} /multi_unit_tb/cmd_rdy
add wave -noupdate -expand -group {UART to Digcore} /multi_unit_tb/cmd
add wave -noupdate -expand -group {UART to Digcore} /multi_unit_tb/clr_cmd_rdy
add wave -noupdate -expand -group {Bluetooth RX} /multi_unit_tb/RX
add wave -noupdate -expand -group move -color Yellow /multi_unit_tb/OK2Move
add wave -noupdate -expand -group move /multi_unit_tb/i_CORE/buzz
add wave -noupdate -expand -group move /multi_unit_tb/i_CORE/buzz_n
add wave -noupdate -expand -group move /multi_unit_tb/i_CORE/piezo_en
add wave -noupdate -expand -group {Command FSM} /multi_unit_tb/i_CORE/iCmdctrl/dst_ID
add wave -noupdate -expand -group {Command FSM} /multi_unit_tb/i_CORE/iCmdctrl/in_transit
add wave -noupdate -expand -group {Command FSM} /multi_unit_tb/i_CORE/iCmdctrl/state
add wave -noupdate -expand -group {Command FSM} /multi_unit_tb/i_CORE/iCmdctrl/next_state
add wave -noupdate /multi_unit_tb/i_CORE/iMotion/go
add wave -noupdate -expand -group {Motion FSM} /multi_unit_tb/i_CORE/iMotion/lft_reg
add wave -noupdate -expand -group {Motion FSM} /multi_unit_tb/i_CORE/iMotion/rht_reg
add wave -noupdate -expand -group {Motion FSM} /multi_unit_tb/i_CORE/iMotion/channel_cnt
add wave -noupdate -expand -group {Motion FSM} /multi_unit_tb/i_CORE/iMotion/intgdec
add wave -noupdate -expand -group {Motion FSM} /multi_unit_tb/i_CORE/iMotion/state
add wave -noupdate -expand -group {Motion FSM} /multi_unit_tb/i_CORE/iMotion/nxt_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5212 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 225
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {310094 ps}
