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
add wave -noupdate -expand -group digcore /dig_core_tb/clk
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/lft
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/rht
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/OK2Move
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/in_transit
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/go
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/cmd_rdy
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/cmd
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/ID
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/ID_vld
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/led
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/piezo_en
add wave -noupdate -expand -group digcore /dig_core_tb/iDUT/pz_cnt
add wave -noupdate /dig_core_tb/iDUT/buzz
add wave -noupdate /dig_core_tb/iDUT/buzz_n
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/A2D_res
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/cnv_cmplt
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/go
add wave -noupdate -group {motion block} -color Yellow /dig_core_tb/iDUT/iMotion/Accum
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/Pcomp
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/Pterm
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/Fwd
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/Error
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/Intgrl
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/Icomp
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/Iterm
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/dst
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/dst2accum
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/dst2error
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/dst2intgrl
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/dst2icomp
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/dst2pcomp
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/dst2lft
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/dst2rht
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/state
add wave -noupdate -group {motion block} /dig_core_tb/iDUT/iMotion/nxt_state
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/cmd_rdy
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/ID_vld
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/cmd
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/ID
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/in_transit
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/clr_cmd_rdy
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/clr_ID_vld
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/state
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/next_state
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/set_in_transit
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/clr_in_transit
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/cmd_go
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/cmd_stop
add wave -noupdate -expand -group {cmd_ctrl block} /dig_core_tb/iDUT/iCmdctrl/dst_ID
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7500035 ns} 0}
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
WaveRestoreZoom {15595585 ns} {15601224 ns}
