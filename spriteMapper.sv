module spriteMapper(
	input logic clk, start_write,
	input logic [9:0] x, y,
	input logic [3:0] blockColor,
	output logic [19:0] addr,
	output logic [3:0] palletColor,
	output logic complete,
	output logic sprite_write
);

enum logic {
	waiting,
	drawing
} state, next_state;
logic [7:0] counter;
logic [9:0] x_hold, y_hold;
logic [3:0] blockColor_hold;
logic last_start_write;

initial begin
	state = waiting;
	last_start_write = 1'b0;
end
always_ff @(posedge clk)
begin
		if(state == waiting) begin
			counter <= 6'd0;
			x_hold <= x;
			y_hold <= y;
			blockColor_hold <= blockColor;
		end
		else begin
			counter++;
		end
		state <= next_state;
		last_start_write <= start_write;
end

//Next_state logic
always_comb begin
	next_state = state;
	case(state)
		waiting: begin
			if(start_write > last_start_write)
				next_state = drawing;
			else
				next_state = waiting;
		end
		drawing: begin
			if(counter == 8'd255)
				next_state = waiting;
			else
				next_state = drawing;
		end
	endcase
end

//Output logic
always_comb begin
	complete = 1'b0;
	addr = 19'b0;
	palletColor = blockColor_hold;
	sprite_write = 1'b0;
	case(state)
		waiting: begin
			complete = 1'b1;
			palletColor = 4'b0000;
		end
		drawing: begin
			sprite_write = 1'b1;
			if(counter[7:4] == 4'b0000 || counter[7:4] == 4'b1111)
				palletColor = /*blockColor_hold == 4'h2 ? 4'hA :*/ 4'h0;
			else if(counter[3:0] == 4'b0000)
				palletColor = /*blockColor_hold == 4'h2 ? 4'hA :*/ 4'h0;
			else if (counter[3:0] == 4'b1111)
				palletColor = /*blockColor_hold == 4'h2 ? 4'hA :*/ 4'h0;
			addr = ((counter[7:4] + y_hold) << 9) + ((counter[7:4] + y_hold) << 7) + counter[3:0] + x_hold;
		end
	endcase
end

endmodule : spriteMapper