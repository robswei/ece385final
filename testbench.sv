module testbench();

timeunit 10ns;

timeprecision 1ns;

logic Clk = 0;
logic [9:0] DrawX, DrawY;
logic [7:0] VGA_R, VGA_G, VGA_B;
logic [3:0] KEY;

lab8 top_level(.CLOCK_50(Clk), .KEY(KEY), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .DrawX(DrawX), .DrawY(DrawY));

always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin : CLOCK_INITIALIZATION
	Clk = 0;
end

initial begin : TEST_VECTORS
	KEY[0] = 1'b0;
	#8 KEY[0] = 1'b1;
end
endmodule