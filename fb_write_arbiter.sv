module fb_write_arbiter(
		input logic clear_write, sprite_write,
		input logic [19:0] clear_w_addr, sprite_w_addr,
		input logic [3:0] clear_wdata, sprite_wdata,
		output logic [19:0] fb_w_addr,
		output logic [3:0] fb_wdata,
		output logic fb_write
);

always_comb begin
	fb_wdata = 4'b0000;
	fb_w_addr = 20'd0;
	if (clear_write) begin
		fb_w_addr = clear_w_addr;
		fb_wdata = clear_wdata;
	end
	else if (sprite_write) begin
		fb_w_addr = sprite_w_addr;
		fb_wdata = sprite_wdata;
	end
	fb_write = clear_write | sprite_write;
end
	
endmodule : fb_write_arbiter