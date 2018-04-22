//Clears the ram in 3ms
module clear_ram(input logic Clk, beginClear,
						output logic complete,
						output logic [19:0] addr,
						output logic clear_write
						);


enum logic{
	waiting,
	clearing
} state, next_state;

logic [19:0] counter;
logic last_beginClear;

initial begin
	state = waiting;
	last_beginClear = 1'b0;
end

always_ff @(posedge Clk) begin
	if(state == clearing)
		counter++;
	else if (state == waiting) 
		counter = 20'b0;
	state <= next_state;
	last_beginClear <= beginClear;	
end

always_comb begin
	next_state = state;
	if(state == waiting && beginClear > last_beginClear)
		next_state = clearing;
	if(state == clearing && counter == 20'd307199)
		next_state = waiting;
	
	
end

assign addr = counter;
assign complete = (state == waiting);
assign clear_write = (state == clearing);
endmodule : clear_ram