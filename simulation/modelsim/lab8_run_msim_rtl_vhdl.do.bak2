transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/color_mapper.sv}
vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/spriteMapper.sv}
vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/VGA_controller.sv}
vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/HexDriver.sv}
vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/frame_buffer.sv}
vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/clear_ram.sv}
vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/fb_write_arbiter.sv}
vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/lab8.sv}
vlib nios_system
vmap nios_system nios_system

vlog -sv -work work +incdir+E:/Downloads/Lab8/Lab8 {E:/Downloads/Lab8/Lab8/testbench.sv}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneive -L rtl_work -L work -L nios_system -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 10000 ns
