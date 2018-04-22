module frame_buffer(input logic Clk, 
							input logic [3:0] wdata, 
							input logic [19:0] w_addr,
							input logic write,
							input logic [19:0] r_addr,
							output logic [3:0] rdata);

logic [3:0] data [0:307199];
/*initial begin
	int i;
	for(i = 0; i < 307200; i++)
		data[i] = 4'b0000;
end*/
							
always_ff @(posedge Clk) begin
	if(write)
		data[w_addr] = wdata;
	rdata = data[r_addr];
end
endmodule : frame_buffer
					