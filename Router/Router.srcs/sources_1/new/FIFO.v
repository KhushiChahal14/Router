`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 13:40:49
// Design Name: 
// Module Name: FIFO
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


module router_fifo(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);
//port assignment      
       input clock,resetn,write_enb,soft_reset,read_enb,lfd_state;
       input [7:0]data_in;
       output empty,full;
       output reg[7:0]data_out;
       reg [8:0]mem[0:15];
       reg [4:0]write_ptr,read_ptr;
       reg [6:0]count;
		 reg tlfd;
//write operation
       always@(posedge clock)
       begin
	       if(!resetn)
	       begin:b1
		       integer i;
				 write_ptr<=5'b0;
		       for(i=0;i<16;i=i+1)
					begin
			       mem[i]<=8'h0;
					 //data_out<= 8'h0;
					end
	       end
	       else if(soft_reset)
	       begin:b2
		       integer j;
				 write_ptr<=5'b0;
		       for(j=0;j<16;j=j+1)
			       mem[j]<=8'h0;
	       end
	       else if(write_enb && !full)
	       begin
		       mem[write_ptr]<={tlfd,data_in};
		       write_ptr<=write_ptr+1'b1;
	       end
       end
//read operation
       always@(posedge clock)
       begin
	       if(!resetn)
			 begin
		       data_out<=8'b0;
				 read_ptr<=5'b0;
          end
	       else if(soft_reset)
		       data_out<=8'hz;
	       
	       else if(read_enb && !empty)
	       begin
		       data_out<=mem[read_ptr[3:0]][7:0];
		       read_ptr<=read_ptr+1'b1;
	       end
	      else if(count == 0)
		       data_out<=8'hz; 
      end
//internal count operation		
       always@(posedge clock)
       begin
	       if(!resetn)
		       count<=7'b0;
	       else if(soft_reset)
		       count<=7'b0;
	       else if(read_enb && !empty)
	      begin
			   if(mem[read_ptr[3:0]][8] == 1'b1)
	  	 
		      count<=mem[read_ptr[3:0]][7:2]+1'b1;
	            else if (count!=7'h0)
	             //begin
		         count<=count-1'b1;
	                 else
		            count<=count;
	             //end 
	       end
			 else
			 count<=count;
       end
	 //for delaying lfd
		always@(posedge clock)
		 begin
		    if(!resetn)
			   tlfd<=1'b0;
			else
			   tlfd<=lfd_state;
		 end 
      //continous concurrent assignments
      assign full=(write_ptr==5'd16 && read_ptr==0);
       //assign full=(write_ptr+1'b1==read_ptr);
		 assign empty=(write_ptr==read_ptr);
		 
   endmodule