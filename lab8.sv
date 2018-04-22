//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
				//output logic [9:0] DrawX,DrawY
				 );
    
    logic Reset_h, Clk;
    logic [15:0] keycode;
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    logic [3:0] fb_rdata0, fb_rdata1, fb_rdata_out, fb_wdata;
	 logic [19:0] fb_w_addr, fb_r_addr;
	 logic fb_write;
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
	 logic [31:0] block_data;
	 logic [1:0] drawing_status;
	 logic [31:0] level_score;
    logic hpi_r, hpi_w, hpi_cs;
	initial begin 
		VGA_CLK = 1'b0;
	end
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),    
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     nios_system nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
									  .block_data_export(block_data),
									  .drawing_status_export(drawing_status),
									  .random_seed_export(DrawX[3:0]),//DrawX should be changing fast enough that it will seem pretty random,
									  .level_score_export(level_score)
    );
  
    // Use PLL to generate the 25MHZ VGA_CLK. Do not modify it.
    // vga_clk vga_clk_instance(
    //     .clk_clk(Clk),
    //     .reset_reset_n(1'b1),
    //     .altpll_0_c0_clk(VGA_CLK),
    //     .altpll_0_areset_conduit_export(),    
    //     .altpll_0_locked_conduit_export(),
    //     .altpll_0_phasedone_conduit_export()
    // );
	 
    always_ff @ (posedge Clk) begin
        if(Reset_h)
            VGA_CLK <= 1'b0;
        else
				
            VGA_CLK <= ~VGA_CLK;
    end
    logic [9:0] DrawX, DrawY;
   
    VGA_controller vga_controller_instance(.Clk(Clk),
														 .Reset(Reset_h),
														 .VGA_HS(VGA_HS),
														 .VGA_VS(VGA_VS),
														 .VGA_CLK(VGA_CLK),
														 .VGA_BLANK_N(VGA_BLANK_N),
														 .VGA_SYNC_N(VGA_SYNC_N),
														 .DrawX(DrawX),
														 .DrawY(DrawY));
	 //Clears the RAM
	 logic [19:0] clear_w_addr;
	 logic [3:0] clear_wdata;
	 assign clear_wdata = 4'b0000;
	 logic beginClear, clearComplete, clear_write;
	 assign beginClear = block_data[25];
	 clear_ram ram_clearer(.Clk(Clk), .beginClear(beginClear), .addr(clear_w_addr), .complete(clearComplete), .clear_write(clear_write));
	 
	 
	 //Draws a block on the screen
	 logic [19:0] sprite_w_addr;
	 logic [3:0] sprite_wdata;
	 logic beginSprite, spriteComplete, sprite_write;
	 assign beginSprite = block_data[24] & ~block_data[25];
	 spriteMapper blockDrawer (.clk(Clk),
										.start_write(beginSprite),
										.x(block_data[9:0]), .y(block_data[19:10]),
										.blockColor(block_data[23:20]),
										.addr(sprite_w_addr), .palletColor(sprite_wdata),
										.complete(spriteComplete),
										.sprite_write(sprite_write));
	 assign drawing_status = {clearComplete,spriteComplete};									
	 //controls if the data from clear should be used or the data from the sprite
	 fb_write_arbiter fbw_arbiter(.*);

    frame_buffer buffer0 (.Clk(Clk),
								  .wdata(fb_wdata),
								  .w_addr(fb_w_addr),
								  .write(fb_write & ~block_data[26]),
								  .r_addr(fb_r_addr),
								  .rdata(fb_rdata0));
								  
	 frame_buffer buffer1 (.Clk(Clk),
								  .wdata(fb_wdata),
								  .w_addr(fb_w_addr),
								  .write(fb_write & block_data[26]),
								  .r_addr(fb_r_addr),
								  .rdata(fb_rdata1));
								  
	 assign fb_rdata_out = block_data[26] ? fb_rdata0 : fb_rdata1;							  
    color_mapper color_inst(.Clk(Clk), .sram_addr(fb_r_addr),.sram_data(fb_rdata_out),
											.DrawX(DrawX),.DrawY(DrawY),
											.VGA_R(VGA_R),.VGA_G(VGA_G),.VGA_B(VGA_B));

    // Display keycode on hex display
    HexDriver hex_inst_0 (level_score[3:0], HEX0);
    HexDriver hex_inst_1 (level_score[7:4], HEX1);
	 assign HEX2 = 7'b1111111;
	 HexDriver hex_inst_3 (level_score[31:28], HEX3);
endmodule
