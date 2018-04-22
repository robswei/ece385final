onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/Clk
add wave -noupdate /testbench/top_level/DrawX
add wave -noupdate /testbench/top_level/DrawY
add wave -noupdate /testbench/top_level/Reset_h
add wave -noupdate /testbench/VGA_R
add wave -noupdate /testbench/VGA_G
add wave -noupdate /testbench/VGA_B
add wave -noupdate /testbench/top_level/vga_controller_instance/VGA_VS
add wave -noupdate /testbench/top_level/vga_controller_instance/DrawX
add wave -noupdate /testbench/top_level/vga_controller_instance/DrawY
add wave -noupdate /testbench/top_level/fbw_arbiter/clear_write
add wave -noupdate /testbench/top_level/fbw_arbiter/sprite_write
add wave -noupdate /testbench/top_level/fbw_arbiter/clear_w_addr
add wave -noupdate /testbench/top_level/fbw_arbiter/sprite_w_addr
add wave -noupdate /testbench/top_level/fbw_arbiter/fb_w_addr
add wave -noupdate /testbench/top_level/fbw_arbiter/fb_wdata
add wave -noupdate /testbench/top_level/blockDrawer/x
add wave -noupdate /testbench/top_level/blockDrawer/y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {258809 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 324
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
WaveRestoreZoom {169451 ps} {1043714 ps}
