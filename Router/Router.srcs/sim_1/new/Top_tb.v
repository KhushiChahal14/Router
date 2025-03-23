`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 13:48:39
// Design Name: 
// Module Name: Top_tb
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


module router_top_tb();
      reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
		reg [7:0]data_in;
		wire [7:0] data_out_0,data_out_1,data_out_2;
		wire valid_out_0,valid_out_1,valid_out_2,error,busy;
		
		router_top DUT(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,error,busy);
      //clock generation
      always
      begin
	      clock=1'b0;
	      #5 clock=~clock;
	      #5;
      end
      //reset gener
      task rst();
	      begin
		      @(negedge clock)
		      resetn=1'b0;
		      @(negedge clock)
		      resetn=1'b1;
	      end
      endtask
      //payload is equal to 14
      task pkt_gen_14_0();
	      reg [7:0]payload_data,parity,header;
	      reg [5:0]payload_len;
	      reg [1:0]addr;
	     integer i;
		  begin
		      @(negedge clock);
		      wait(~busy)
		      @(negedge clock);
		      payload_len=6'd14;
		      addr=2'b00;
		      header={payload_len,addr};
		      parity=8'b0;
		      data_in=header;
		      pkt_valid=1'b1;
		      parity=parity^header;
		      @(negedge clock);
		      wait(~busy)
		      for(i=0;i<payload_len;i=i+1)
		      begin
			      @(negedge clock);
			      wait(~busy)
			      payload_data={$random}%256;
			      data_in=payload_data;
			      parity=parity^payload_data;
		      end
		      @(negedge clock);
		      wait(~busy)
		      pkt_valid=1'b0;
		      data_in=parity;
	      end
      endtask

      //payload is lessthan  14
      task pkt_gen_14_1();
	      reg [7:0]payload_data,parity,header;
	      reg [5:0]payload_len;
	      reg [1:0]addr;
	      begin:b1
			integer j;
		      @(negedge clock);
		      wait(~busy)
		      @(negedge clock);
		      payload_len=6'd9;
		      addr=2'b01;
		      header={payload_len,addr};
		      parity=1'b0;
		      data_in=header;
		      pkt_valid=1'b1;
		      parity=parity^header;
		      @(negedge clock);
		      wait(~busy)
		      for(j=0;j<payload_len;j=j+1)
		      begin
			      @(negedge clock);
			      wait(~busy)
			      payload_data={$random}%256;
			      data_in=payload_data;
			      parity=parity^payload_data;
		      end
		      @(negedge clock);
		      wait(~busy)
		      pkt_valid=1'b0;
		      data_in=parity;
	      end
      endtask 


     //payload is equal to 16
      task pkt_gen_16_2();
	      reg [7:0]payload_data,parity,header;
	      reg [5:0]payload_len;
	      reg [1:0]addr;
	      begin:b2
		      integer k;
		      @(negedge clock);
		      wait(~busy)
		      @(negedge clock);
		      payload_len=6'd16;
		      addr=2'b10;
		      header={payload_len,addr};
		      parity=1'b0;
		      data_in=header;
		      pkt_valid=1'b1;
		      parity=parity^header;
		      @(negedge clock);
		      wait(~busy)
		      for(k=0;k<payload_len;k=k+1)
		      begin
			      @(negedge clock);
			      wait(~busy)
			      payload_data={$random}%256;
			      data_in=payload_data;
			      parity=parity^payload_data;
		      end
		      @(negedge clock);
		      wait(~busy)
		      pkt_valid=1'b0;
		      data_in=parity;
	      end
      endtask 
      //calling task
      initial
      begin
		
		
	     rst;
		  fork
		  //begin
	    repeat(3)@(negedge clock);
		 begin
	   pkt_gen_14_0;
	  @(negedge clock);
	 read_enb_0=1'b1;
	wait(~valid_out_0)
       @(negedge clock) ;
       read_enb_0=1'b0;
		 end
		 
	     //begin
	    repeat(3)@(negedge clock);
		 begin
	   pkt_gen_14_1;
	   @(negedge clock);
	   read_enb_1=1'b1;
	    wait(~valid_out_1)
       @(negedge clock) ;
       read_enb_1=1'b0;      
       end
       //begin
	    repeat(3)@(negedge clock);
		 begin
	   pkt_gen_16_2;
	  @(negedge clock);
	 read_enb_2=1'b1;
	wait(~valid_out_2)
       @(negedge clock);
       read_enb_2=1'b0;
		 end
		 join
   // #1000 $finish; 
   end  
endmodule
