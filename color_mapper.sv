//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module color_mapper( input logic Clk, input logic [3:0] sram_data, output logic [19:0] sram_addr,
                       input logic [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    logic [3:0] palletNum;
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 
    // Assign color based on is_ball signal
    always_comb
    begin
			Red = 8'h00;
			Green = 8'h00;
			Blue = 8'h00;
			sram_addr = DrawX + (DrawY << 9) + (DrawY << 7);
			case(sram_data)
				4'd0: begin //BLACK
					Red = 8'h00; 
					Green = 8'h00;
					Blue = 8'h00;
				end
				4'd1: begin //WHITE
					Red = 8'hFF; 
					Green = 8'hFF;
					Blue = 8'hFF;
				end
				4'd2: begin //GREY
					Red = 8'hA9; 
					Green = 8'hA9;
					Blue = 8'hA9;
				end
				4'd3: begin //RED
					Red = 8'hFF; 
					Green = 8'h00;
					Blue = 8'h00;
				end
				4'd4: begin //ORANGE
					Red = 8'hFF; 
					Green = 8'hA5;
					Blue = 8'h00;
				end
				4'd5: begin //YELLOW
					Red = 8'hFF; 
					Green = 8'hFF;
					Blue = 8'h00;
				end
				4'd6: begin //GREEN
					Red = 8'h22; 
					Green = 8'h8B;
					Blue = 8'h22;
				end
				4'd7: begin //BLUE
					Red = 8'h00; 
					Green = 8'h00;
					Blue = 8'hFF;
				end
				4'd8: begin //PURPLE
					Red = 8'hFF; 
					Green = 8'h00;
					Blue = 8'hFF;
				end
				4'd9: begin //LIGHTBLUE
					Red = 8'h00; 
					Green = 8'hBF;
					Blue = 8'hFF;
				end
				4'hA: begin //LIGHTBLUE
					Red = 8'h90; 
					Green = 8'h90;
					Blue = 8'h90;
				end
				default : begin
					Red = 8'hF; 
					Green = 8'hFF;
					Blue = 8'hFF;
				end
			endcase
    end 
    
endmodule : color_mapper
