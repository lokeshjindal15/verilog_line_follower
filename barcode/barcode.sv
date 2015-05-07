/*
Author: Lokesh Jindal
e-mail: lokeshjindal15@cs.wisc.edu
Date:	March, 2015

Barcode reader for line follower robot
*/

module barcode(BC, ID_vld, ID, clr_ID_vld, clk, rst_n);

input clk, rst_n;
input BC;
input clr_ID_vld;
output reg ID_vld;
output reg [7:0] ID;

reg set_ID_vld;  // output from SM to indicate a valid ID

reg BC_flop;  //used to minimally double flop the BC input OR better use the 3-sampling circuit

reg start_cnt_low, latch_cnt_low, shift;  // signals going from SM to data path: 22-b counter and bit_count specifically

reg [21:0] counter;  //22-b counter used to count clock cycles for sampling
reg [3:0]  bit_counter; //4-bit counter to track how many bits have been recvd

reg recving, cnting_low, waiting_bc_negedge, done_waiting_bc_negedge;  //signals from SM to datapath: 22-b counter enable/disable signal

reg [21:0] low_count_reg; //22-b reg that stores the number of low-period clk cycles
logic [21:0] low_count_regX2;

// making barcode reader robust 3-sampling circuit
reg BC0, BC1, BC2, BC3; 
always@(posedge(clk) or negedge(rst_n))
if (!rst_n)
	begin
	BC0 <= 1;
	BC1 <= 1;
	BC2 <= 1;
	BC3 <= 1;
	end
else
	begin
	BC0 <= BC;
	BC1 <= BC0;
	BC2 <= BC1;
	BC3 <= BC2;
	end

wire BC_flop_in;
	
always@(posedge(clk) or negedge(rst_n))
if (!rst_n)
	begin
	BC_flop <= 1;
	end
else
	begin
	BC_flop <= BC_flop_in;
	end

wire set_BC, clr_BC;

//and SETBC(set_BC, BC1, BC2, BC3);
assign set_BC = BC1 & BC2 & BC3;
//nor CLRBC(clr_BC, BC1, BC2, BC3);
assign clr_BC = ~(BC1 | BC2 | BC3);

assign BC_flop_in = set_BC ? 1'b1:
					clr_BC ? 1'b0:
					BC_flop;
	
/*
reg BC1;  //used to double flop the BC input
//double flop BC before using
always@(posedge(clk) or negedge(rst_n))
if (!rst_n)
	begin
	BC1 <= 1;
	BC_flop <= 1;
	end
else
	begin
	BC1 <= BC;
	BC_flop <= BC1;
	end	
*/
	
// 22-bit counter used to count clk cycles for sampling BC
// resets when start_cnt_low = 1 | latch_cnt_low = 1 | shift = 1
// counts up when in states cnting_low or recving
always@(posedge(clk))
begin
	//if (start_cnt_low || latch_cnt_low || shift)
	if (start_cnt_low || latch_cnt_low || shift || done_waiting_bc_negedge) // reset after detecting a negedge. used for time-out
		counter <= 22'h000000;
	//else if(recving || cnting_low)
	else if(recving || cnting_low || waiting_bc_negedge) // enable counter even when waiting for negedge and time-out on overflow
		counter <= counter + 1;
end 

// store the value of counter in register when done counting during low period of start bit
always@(posedge(clk) or negedge(rst_n))
	if (!rst_n)
		low_count_reg <= 22'h000000;
	else
		if (latch_cnt_low)
			low_count_reg <= counter;
		

assign low_count_regX2 = {low_count_reg[20:0], 1'b0};
	
//bit_counter to track how many bits have been recved
//reset on start of every transaction
always@(posedge(clk))
begin
	if(start_cnt_low)
		bit_counter <= 4'b000;
	else if (shift)
		bit_counter <= bit_counter + 1;
end

// final ID formation
// shift in BC_flop at LSB when signalled shift
always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		ID <= 0;
	else if (shift)
		ID <= {ID[6:0],BC_flop};
end

//FSM states
typedef enum reg [2:0] {IDLE, CNT_LOW, WAIT_BC_NEGEDGE, WAIT_BC_POSEDGE, RECVING} state_t;
 state_t state, nxt_state;

always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

always@(*)
begin
	start_cnt_low = 0;
	latch_cnt_low = 0;
	shift = 0;
	recving = 0;
	cnting_low = 0;
	nxt_state = IDLE;
	set_ID_vld = 0;
	waiting_bc_negedge = 0;
	done_waiting_bc_negedge = 0;
	
		case(state)
		IDLE: //wait for negedge of BC_flop - start bit
			if (!BC_flop)
			begin
				start_cnt_low = 1;
				nxt_state = CNT_LOW;
			end
		
		CNT_LOW: //wait for posedge of BC_flop
			begin
				cnting_low = 1;
				if (BC_flop)
				begin
					latch_cnt_low = 1;
					nxt_state = WAIT_BC_NEGEDGE;
				end
				else
				begin
					nxt_state = CNT_LOW;
				end
			end

		WAIT_BC_NEGEDGE: //wait for negedge of BC
			begin
			waiting_bc_negedge = 1'b1;
			if (!BC_flop)
			begin
				nxt_state = RECVING;
				done_waiting_bc_negedge = 1'b1 ;
			end
			 // else if (counter == 22'h3fffff)//timeout if it was false start bit and we never see a BC_NEGEDGE
			else if (counter == low_count_regX2[21:0])// ECO //timeout if it was false start bit and we never see a BC_NEGEDGE
				begin
					nxt_state = IDLE;
					done_waiting_bc_negedge = 1'b1;
				end
				else
				begin
					nxt_state = WAIT_BC_NEGEDGE;
				end
			end
		
		WAIT_BC_POSEDGE: //wait until you see a posedge on BC_flop
			if (BC_flop)
			begin
				if (bit_counter == 8) // after shifting in last bit don't go to WAIT_BC_NEGEDGE
				begin
						if (ID[7:6] == 2'b00)
						begin
							set_ID_vld = 1;
						end
						nxt_state = IDLE;
				end
				else
				begin
					nxt_state = WAIT_BC_NEGEDGE;
				end
			end
			else
			begin
				nxt_state = WAIT_BC_POSEDGE;
			end
			
		RECVING: // wait for counter to reach the latched value of low-period
			begin
				recving = 1;
				if (counter == low_count_reg)
				begin
					shift = 1;
					/* Let's move this to WAIT_BC_POSEDGE
					if (bit_counter == 7) // (8 - 1) after shifting in last bit don't go to WAIT_BC_POSGEDGE
					begin
						set_ID_vld = 1;
						nxt_state = IDLE;
					end
					else
					*/
					begin
						nxt_state = WAIT_BC_POSEDGE;
					end
				end
				else
				begin
					nxt_state = RECVING;
				end
			end
		endcase
end

/*
if done recving set vld and stay there
if clr_rdy asserted by external agent - reset
if move out of idle state with start_cnt_low - reset
*/
always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		ID_vld <= 0;
	else if(set_ID_vld)
		ID_vld <= 1;
	else if(clr_ID_vld)
		ID_vld <= 0;
	else if(start_cnt_low)
		ID_vld <= 0;
end

endmodule
