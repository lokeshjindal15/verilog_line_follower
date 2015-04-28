/*
Author: Lokesh Jindal
e-mail: lokeshjindal15@cs.wisc.edu
Date:	March, 2015

UART Transmitter module for line follower
*/
module	uart_trans(clk, rst_n, trmt, tx_data, TX, tx_done);

localparam BAUD_CYCLES = 12'd2604;

input	clk, rst_n, trmt;
input	[7:0] tx_data;		//data to be transmitted
output	wire TX;
output	reg tx_done;

reg	[11:0] baud_cnt;		//counter to track the count of baud cycles
wire	shift;

reg	[3:0] bit_cnt;			//counter to track the number of bits transmitted

reg	load, transmitting, set_done, clr_done;

reg	[9:0] tx_shft_reg;

/*
reset the baud count when starting to transmit the new byte
as well as when done transmitting a single bit
keep incrementing as long as transmitting otherwise
*/
always@(posedge(clk))
begin
	if (load | shift)
		baud_cnt <= 12'b000000000000;
	else if(transmitting)
		baud_cnt <= baud_cnt + 1;
end

assign shift = (baud_cnt == (BAUD_CYCLES - 1));

/*
reset the bit count when starting to transmit a new BYTE
increment when done transmitting a single bit
*/
always@(posedge(clk))
begin
	if(load)
		bit_cnt <= 4'b000;
	else if (shift)
		bit_cnt <= bit_cnt + 1;
end

/*
shift register at the output
load in a new value when starting to transmit a new BYTE
shift right when signalled shift by baud count
*/
always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		tx_shft_reg <= 0;
	else if (load)
		tx_shft_reg <= {1'b1, tx_data, 1'b0};
	else if (shift)
		tx_shft_reg <= {1'b1, tx_shft_reg[9:1]};
end

assign TX = tx_shft_reg[0];

//state machine states
typedef enum reg {IDLE, TRANSMITTING} state_t;
state_t state, nxt_state;

always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
end

//state machine transition logic
always@(bit_cnt, trmt, state)
begin
	nxt_state = IDLE;
	set_done = 0;
	clr_done = 0;
	load = 0;
	transmitting = 0;
	
	case(state)
		IDLE://wait for trmt to signal transmitting of a new BYTE
			if (trmt)
			begin
				nxt_state = TRANSMITTING;
				load = 1;
				transmitting = 1;
				clr_done = 1;
			end
			else
			begin
				set_done = 1;
			end

		TRANSMITTING://keep transmitting the bits until done with 10 bits
			if (bit_cnt == 10)
			begin
				set_done = 1;
				nxt_state = IDLE;
			end
			else
			begin
				transmitting = 1;
				nxt_state = TRANSMITTING;
			end

	endcase

end

wire tx_done_in;
assign tx_done_in = set_done ? 1 :
		    clr_done ? 0 :
		    0;

//flop the done signal
always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		tx_done <= 1;
	else
		tx_done <= tx_done_in;
end
	
endmodule


