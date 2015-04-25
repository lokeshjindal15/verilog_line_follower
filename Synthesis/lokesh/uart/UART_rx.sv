/*
Author: Lokesh Jindal
e-mail: lokeshjindal15@cs.wisc.edu
Date:	March, 2015

UART receiver module for line follower
*/
module uart_recv(clk, rst_n, clr_rdy, RX, rdy, cmd);

localparam BAUD_CYCLES = 12'd2604;
localparam BAUD_CYCLES_1_5 = 12'd3906;

input	clk, rst_n, clr_rdy, RX;
output	reg rdy;
output	[7:0] cmd;

reg		[8:0] shift_cmd;

reg		strt_recv;//signal to reset baud_counter and bit_counter

reg		[3:0] bit_cnt;
reg		[11:0] baud_cnt;

wire	shift;//signal to l on completion of waiting for BAUD_CYCLES
reg		recving;//signal to datapath to indiacte we are recving the bits
wire	baud1_5_done;
reg		counting_baud1_5;

reg 	set_rdy;
reg		rx1, rx_flop;
//double flop RX before using
always@(posedge(clk) or negedge(rst_n))
if (!rst_n)
	begin
	rx1 <= 1;
	rx_flop <= 1;
	end
else
	begin
	rx1 <= RX;
	rx_flop <= rx1;
	end

//baud_count counter that tracks how many baud cycles have passed
//reset the counter after waiting for BAUD_CYCLES or during start of rcving a byte
always@(posedge(clk))
begin
	if (strt_recv || (shift && recving) || baud1_5_done)
		baud_cnt <= 12'b000000000000;
	else if(recving || counting_baud1_5)
		baud_cnt <= baud_cnt + 1;
end

assign	shift = (baud_cnt == (BAUD_CYCLES - 1));
assign	baud1_5_done = (baud_cnt == (BAUD_CYCLES_1_5 - 1));

//bit_counter to track how many bits have been recved
//reset on start of 8-byte
always@(posedge(clk))
begin
	if(strt_recv)
		bit_cnt <= 4'b000;
	else if (shift)
		bit_cnt <= bit_cnt + 1;
end

//final cmd formation
//shift in rx_flop signal when signalled shift
//shift extra 0 stop bit afte done shifting in real 8 bits
always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		shift_cmd <= 0;
	else if ((shift && recving) || baud1_5_done)
		shift_cmd <= {rx_flop, shift_cmd[8:1]};
end

assign cmd = shift_cmd[7:0];//remove the extra stop bit sampled

//FSM states
typedef enum reg [1:0] {IDLE, CNT1_5, RECVING, DONE} state_t;
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
	set_rdy = 1'b0;
	strt_recv = 1'b0;
	recving = 1'b0;
	nxt_state = IDLE;
	counting_baud1_5 = 1'b0;
	
	case(state)
	IDLE://wait for negedge of RX signal
		if(!rx_flop)
		begin
			nxt_state = CNT1_5;
			strt_recv = 1'b1;
		end
	CNT1_5://count to 1.5XBAUD CYCLE before start sampling real bits
		if(baud1_5_done)
		begin
			nxt_state = RECVING;
			recving = 1;
		end
		else
		begin
			nxt_state = CNT1_5;
			counting_baud1_5 = 1'b1;
		end
	RECVING://keep shifting in bits until done with 9 bits including stop bit
		if(bit_cnt == 4'd9)
		begin
			//nxt_state = DONE;
			nxt_state = IDLE;
			set_rdy = 1'b1;
		end
		else
		begin
			nxt_state = RECVING;
			recving = 1;
		end
/*
	DONE://wait till someone acknowledges cmd and asserts the clr_rdy signal
		if(clr_rdy)
		begin
			nxt_state = IDLE;
			set_rdy = 1'b0;
		end
		else
		begin
			nxt_state = DONE;
			set_rdy = 1'b1;
		end
*/
	endcase
end

/*
if done transmitting set rdy and stay there
if clr_rdy asserted by external agent - reset
if move out of idle state - reset
*/
always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		rdy <= 0;
	else if(set_rdy)
		rdy <= 1;
	else if(clr_rdy)
		rdy <= 0;
	else if(strt_recv)
		rdy <= 0;
end
	
endmodule

