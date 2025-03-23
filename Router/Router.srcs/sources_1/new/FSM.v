`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 13:37:17
// Design Name: 
// Module Name: FSM
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


module router_fsm(clock,resetn,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
       input clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
       input [1:0]data_in;
       output detect_add,ld_state,laf_state,busy,full_state,write_enb_reg,rst_int_reg,lfd_state;
		 reg [1:0]addr;
       parameter DECODE_ADDRESS    =3'B000,
	    LOAD_FIRST_DATA    =3'B001,
		 WAIT_TILL_EMPTY   =3'B010,
		 LOAD_DATA         =3'B011,
		 LOAD_PARITY       =3'B100,
		 FIFO_FULL_STATE   =3'B101,
		 CHECK_PARITY_ERROR=3'B110,
		 LOAD_AFTER_FULL   =3'B111;
       reg [2:0]prt_st,nxt_st;
		 //addr assignment block
		 always@(posedge clock)
		 begin
		     if(!resetn)
			   addr<=2'b0;
			else
			   addr<=data_in;
		 end
       //present state sequential logic
       always@(posedge clock)
       begin
	       if(~resetn)
		       prt_st<=DECODE_ADDRESS;
			 else if(soft_reset_0|soft_reset_1|soft_reset_2)
			    prt_st<=DECODE_ADDRESS;
	       else
		       prt_st<=nxt_st;
       end
       //combinational logic for next state
       always@(*)
       begin
	       nxt_st=DECODE_ADDRESS;
	       case(prt_st)
		       DECODE_ADDRESS:if((pkt_valid && (data_in[1:0]==0)) && (fifo_empty_0) || (pkt_valid && (data_in[1:0]==1)) && (fifo_empty_1) || (pkt_valid && (data_in[1:0]==2)) && (fifo_empty_2))
		       nxt_st=LOAD_FIRST_DATA;
	       else if((pkt_valid && (data_in[1:0]==0)) && !(fifo_empty_0) || (pkt_valid && (data_in[1:0]==1)) && !(fifo_empty_1) || (pkt_valid && (data_in[1:0]==2)) && !(fifo_empty_2))
			    nxt_st=WAIT_TILL_EMPTY;
			 else
			    nxt_st=DECODE_ADDRESS;
				 LOAD_FIRST_DATA: nxt_st=LOAD_DATA;
				 WAIT_TILL_EMPTY:if((fifo_empty_0 && (addr==0))||(fifo_empty_1 && (addr==1)) && (fifo_empty_2 && (addr==2)))
				  nxt_st=LOAD_FIRST_DATA;
				  else
				    nxt_st=WAIT_TILL_EMPTY;
				 LOAD_DATA:if(fifo_full)
				            nxt_st=FIFO_FULL_STATE;
								else if(!fifo_full && !pkt_valid)
								 nxt_st=LOAD_PARITY;
								else
								 nxt_st=LOAD_DATA;
				 /*LOAD_PARITY:if(!fifo_full)
				              nxt_st=LOAD_AFTER_FULL;
								 else if(fifo_full)
								  nxt_st=FIFO_FULL_STATE;*/
				 LOAD_PARITY: nxt_st=CHECK_PARITY_ERROR;
				 
				 CHECK_PARITY_ERROR : if(fifo_full)
				                     nxt_st=FIFO_FULL_STATE;
											 else if(!fifo_full)
											 nxt_st=DECODE_ADDRESS;
				 FIFO_FULL_STATE : if(!fifo_full)
				                   nxt_st=LOAD_AFTER_FULL;
										 else if(fifo_full)
										 nxt_st=FIFO_FULL_STATE;
				 LOAD_AFTER_FULL:if(!parity_done && !low_pkt_valid)
				                 nxt_st=LOAD_DATA;
									  else if(!parity_done && low_pkt_valid)
									     nxt_st=LOAD_PARITY;
									  else if(parity_done)
									     nxt_st=DECODE_ADDRESS;
					default: nxt_st=DECODE_ADDRESS;
					endcase
				end
				//continous concurent assignment for output
				assign detect_add=(prt_st==DECODE_ADDRESS);
				assign lfd_state=(prt_st==LOAD_FIRST_DATA);
				assign ld_state=(prt_st==LOAD_DATA);
				assign full_state=(prt_st==FIFO_FULL_STATE);
				assign rst_int_reg=(prt_st==CHECK_PARITY_ERROR);
				assign write_enb_reg=(prt_st==LOAD_DATA || prt_st==LOAD_PARITY || prt_st==LOAD_AFTER_FULL);
				assign laf_state=(prt_st==LOAD_AFTER_FULL);
				assign busy=(prt_st==LOAD_FIRST_DATA||prt_st==LOAD_PARITY||prt_st==LOAD_AFTER_FULL||prt_st==CHECK_PARITY_ERROR||prt_st==WAIT_TILL_EMPTY||prt_st==FIFO_FULL_STATE);

				endmodule