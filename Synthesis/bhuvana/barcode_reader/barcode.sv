////////// Verilog code for barcode reader //////////
////////// Author: Bhuvana Kakunoori //////////

module barcode(clk, rst_n, BC, ID_vld, clr_ID_vld, ID);

input clk, rst_n;				// Input clk, active low reset
input BC;						// Input from the barcode_mimic module
input clr_ID_vld;				// Input to clear the ID_vld signal
	
output reg ID_vld; 				// Output asserted when all the 8 bits are recevied
output reg[7:0] ID;				// Output ID value recevied

typedef enum reg[2:0] {IDLE, START, SHIFT, WAIT, WAIT_LOW} state_t;		// States in the State Machine
state_t state, next_state;					

logic [21:0] strt_cntr, bit_cntr;								// counters for sampling the inputs
logic [3:0] cnt;												// Count for the 8 input bits						
logic clr_strt, inc_strt, clr_cnt, inc_cnt, shift, set_ID_vld;	// Signals generated by the State Machine

//Wires for flopped input signals
logic BC_FF1, BC_FF2, BC_FF3,BC_FF4, BC_filtered;

// Double flop for meta-stability issues. Other two flops are used to eliminate false falling edges
always @(posedge clk) begin
	BC_FF1 <= BC;
	BC_FF2 <= BC_FF1;
  	BC_FF3 <= BC_FF2;
	BC_FF4 <= BC_FF3;
end

// Set if all the 3 flops are high
assign set = BC_FF2 & BC_FF3 & BC_FF4;

//Clear if all the 3 flops are low.
assign clear = ~(BC_FF2 | BC_FF3 | BC_FF4);

// BC_filtered is the flopped output.
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		BC_filtered <= 1'b1;
	else if(set)
		BC_filtered <= 1'b1;
	else if(clear)
		BC_filtered <= 1'b0;

//Counter for counting the period of input signal
always @(posedge clk, negedge rst_n) 
	if(!rst_n) 
		strt_cntr <= 22'h0000;
	else if(clr_strt)
		strt_cntr <= 22'h0000;
	else if(inc_strt)
		strt_cntr <= strt_cntr + 1;


//Counter for counting the 8 input bits
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		cnt <= 4'h0;
	else if(clr_cnt)
		cnt <= 4'h0;
	else if(inc_cnt)
		cnt <= cnt+1;

// Shift register to left-shift and store the input BC signal
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		ID <= 8'h00;
	else if(shift) begin
		ID <= {ID[6:0], BC_filtered};
	end

// Combinational logic to set/clear the ID_vld output
always @(posedge clk)
	if(set_ID_vld)
		ID_vld = 1;
	else if(clr_ID_vld)
		ID_vld = 0;
		
///////////// Infer state flops ////////////
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) 
        state <= IDLE;
    else
        state <= next_state;
end

//The combinational logic for the barcode reader. We have 5 states. SM starts in IDLE. On first falling edge, 
// the state changes to START, which counts the period of the low cycle. Then, moves to WAIT to wait for the 
// next falling edge. On falling edge, the counter counts for the period and shifts. If the BC is low, then it 
// moves to WAIT_LOW to wait for the next falling edge. This is repeated 8 times until all 8 inputs are received
// and then moves to IDLE after setting ID_vld to high.
// If a falling edge is not received for 1.5 times the period, move to IDLE.

always_comb begin
	//Initialize the values to prevent latches
	clr_strt = 1'b1;
	inc_strt = 1'b0;
	clr_cnt = 1'b0;
	inc_cnt = 1'b0;
	shift = 1'b0;
	set_ID_vld = 0;
	case(state)
		IDLE: if(BC)
			next_state = IDLE;
		else begin
			next_state = START;
		end
		START: if(!BC) begin
			clr_cnt = 1'b1;
			clr_strt = 1'b0;
			inc_strt = 1'b1;
			next_state = START;
		end else begin
			next_state = WAIT;
			bit_cntr = strt_cntr;
			clr_strt = 1;
		end
	
		WAIT: if(BC)	begin		//Wait for the falling edge
			if(strt_cntr < (bit_cntr*1.5)) begin	// If you dont see a falling edge for 1.5 times period, IDLE
				clr_strt = 0;
				inc_strt = 1;	
				next_state = WAIT;
			end else
				next_state = IDLE;
		end else begin
			clr_strt = 1;
			next_state = SHIFT;		
		end
			
		SHIFT: begin
			if(cnt < 8) begin
				if(strt_cntr < bit_cntr) begin
					clr_strt = 0;
					inc_strt = 1;
					next_state = SHIFT;
				end else begin
					clr_strt = 1;
					shift = 1;
					inc_cnt = 1;
					clr_cnt = 0;
					if(BC)
					    next_state = WAIT;
					else
					    next_state = WAIT_LOW;
				end
			end else begin
				set_ID_vld = 1;
				next_state = IDLE;
			end
		end

		WAIT_LOW: if(!BC)		//Wait for the rising edge
			next_state = WAIT_LOW;
		else
			next_state = WAIT;
		
	endcase

end

endmodule 