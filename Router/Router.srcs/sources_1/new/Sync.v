`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 13:45:29
// Design Name: 
// Module Name: Sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module router_sync (detect_add,data_in,write_enb_reg,clock,resetn,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);

       input detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
       input [1:0]data_in;
       output vld_out_0,vld_out_1,vld_out_2;
       output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;
       output reg [2:0]write_enb;
       reg [1:0]addr;
       reg [4:0]count_0,count_1,count_2;
       wire w0,w1,w2;
       //for data input
       always@(posedge clock)
       begin
	       if(!resetn)
		       addr<=2'b0;
	       else if(detect_add==1'b1)
		       addr<=data_in;
       end
       //for write enabling
       always@(*)
       begin
	       if(write_enb_reg)
	       begin
		       case(addr)
			       2'b00:write_enb=3'b001;
			       2'b01:write_enb=3'b010;
			       2'b10:write_enb=3'b100;
			       default:write_enb=3'b000;
		       endcase
	       end
	       else
		       write_enb=3'b000;
       end
       //for full condition
       always@(*)
       begin
	       case(addr)
		       2'b00:fifo_full=full_0;
		       2'b01:fifo_full=full_1;
		       2'b10:fifo_full=full_2;
		       default:fifo_full=1'b0;
	       endcase
       end
       //continues concurrent assignments to check fifo empty condition
       assign vld_out_0=~empty_0;
       assign vld_out_1=~empty_1;
       assign vld_out_2=~empty_2;
       //for soft reseting the fifo
		
		 assign w0=(count_0==30)?1'b1:1'b0;
       always@(posedge clock)
       begin
	       if(~resetn)
	       begin
		       soft_reset_0<=1'b0;
		       count_0<=5'h1;
	       end
	       else if(!vld_out_0)
	       begin
		       soft_reset_0<=1'b0;
		       count_0<=5'h1;
	       end
	       else
	       begin
		       if(read_enb_0)
		       begin
				   if(w0)
					begin
			       soft_reset_0<=1'b1;
			       count_0<=5'h1;
					end
		         else
		         begin
			       soft_reset_0<=1'b0;
			       count_0<=count_0+5'h1;
		         end
				 end
	       end
       end
       //enabling softreset_1
		 //wire [4:0]w1;
		 assign w1=(count_1==30)?1'b1:1'b0;
		 always@(posedge clock)
       begin
	       if(~resetn)
	       begin
		       soft_reset_1<=1'b0;
		       count_1<=5'h1;
	       end
	       else if(!vld_out_1)
	       begin
		       soft_reset_1<=1'b0;
		       count_1<=5'h1;
	       end
	       else
	       begin
		       if(read_enb_1)
		       begin
				    if(w1)
					 begin
			       soft_reset_1<=1'b1;
			       count_1<=5'h1;
		          end
		           else
		           begin
			         soft_reset_1<=1'b0;
			         count_1<=count_1+5'h1;
		            end
				 end
	       end
       end
       //enabling softreset_2
		// wire [4:0]w2;
		 assign w2=(count_2==30)?1'b1:1'b0;
		 always@(posedge clock)
       begin
	       if(~resetn)
	       begin
		       soft_reset_2<=1'b0;
		       count_2<=5'h1;
	       end
	       else if(!vld_out_2)
			 
			 /*
			 else if(vld_out_2)
			 begin
			 if(!read_enb_2)
			 begin
			 if(count_2==5'd30)
			 begin
			 soft_reset_2<=1'b1;
			 count_2<=5'h1;
			 end
			 else
			 begin
			 count_2<=count_2+5'h1;
			 soft_reset_2<=1'b0;
			 end
			 end
			 else
			 count_2<=5'h1;
			 end
			 end
			 */
			 
			 
	       begin
		       soft_reset_2<=1'b0;
		       count_2<=5'h1;
	       end
	       else
	       begin
		       if(read_enb_2)
		       begin
				    if(w2)
					 begin
			       soft_reset_2<=1'b1;
			       count_2<=5'h1;
		          end
		          else
		          begin
			          soft_reset_2<=1'b0;
			         count_2<=count_2+5'h1;
		          end
				 end
	       end
       end
       endmodule
