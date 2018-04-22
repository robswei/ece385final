module sram_arbiter (
	input logic clk, VGA_CLK,
	input logic [19:0] SRAM_ADDR_W, SRAM_ADDR_R,
	output logic [19:0] SRAM_ADDR_OUT,
	output logic SRAM_Write
);

always_ff @(posedge clk) begin
	SRAM_Write <= ~VGA_CLK;
end

always_comb begin
	if(SRAM_Write)
		SRAM_ADDR_OUT = SRAM_ADDR_W;
	else
		SRAM_ADDR_OUT = SRAM_ADDR_R;
end

endmodule : sram_arbiter