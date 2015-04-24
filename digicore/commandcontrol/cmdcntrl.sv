// Command and Control module
// Author: Bhuvana Kakunoori

module Cmdcntrl(clk, rst_n, cmd_rdy, cmd, clr_cmd_rdy, ID_vld, clr_ID_vld, ID, in_transit);

input clk, rst_n;
input cmd_rdy, ID_vld;
input[7:0] cmd;
input[7:0] ID;

output reg in_transit;
output reg clr_cmd_rdy;
output reg clr_ID_vld;

typedef enum reg[2:0] {IDLE, CMD_CHK1, MOVING, CMD_CHK2, ID_CHK} state_t;	// States 
state_t state, next_state;

logic set_in_transit, clr_in_transit;
logic cmd_go, cmd_stop;

reg[5:0] dst_ID;

assign cmd_go = (cmd[7:6] == 2'b01) ? 1'b1 : 1'b0;
assign cmd_stop = (cmd[7:6] == 2'b00) ? 1'b1 : 1'b0;


///////////// Infer state flops ////////////
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
    end else
        state <= next_state;
end

//////// Logic to set the output in_transit signal. Infers a flop /////////////
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        in_transit <= 1'b0;
		else if(set_in_transit)
        in_transit <= 1'b1; 
    else if(clr_in_transit)
        in_transit <= 1'b0;
    //else retain the value
end

always_comb begin
	
    clr_in_transit = 1'b0;
	set_in_transit = 1'b1;
	clr_cmd_rdy = 1'b0;
	clr_ID_vld = 1'b0;
	next_state = IDLE;

	case(state)
		IDLE: begin
			clr_in_transit = 1'b1;
			set_in_transit = 1'b0;
			if(cmd_rdy)
				next_state = CMD_CHK1;
		end

		CMD_CHK1:
			if(cmd_go) begin
				dst_ID = cmd[5:0];
				clr_cmd_rdy = 1'b1;
				next_state = MOVING;
			end
			else begin
				clr_cmd_rdy = 1'b1;
				clr_in_transit = 1'b1;
				set_in_transit = 1'b0;
				next_state = IDLE;
			end

		MOVING:
			if(ID_vld) begin
				next_state = ID_CHK;
			end
			else if(cmd_rdy) begin
				next_state = CMD_CHK2;
			end
			else begin
				next_state = MOVING;
			end

		CMD_CHK2:
			if(cmd_go) begin
				next_state = CMD_CHK1;
			end
			else if(cmd_stop) begin
				clr_cmd_rdy = 1'b1;
				clr_in_transit = 1'b1;
				set_in_transit = 1'b0;
				next_state = IDLE;
			end
			else begin
				clr_cmd_rdy = 1'b1;
				next_state = MOVING;
			end

		ID_CHK: begin
			clr_ID_vld = 1'b1;
			if(ID[5:0] == dst_ID[5:0]) begin
				clr_in_transit = 1'b1;
				set_in_transit = 1'b0;				
				next_state = IDLE;
			end
			else begin
				next_state = MOVING;
			end
		end

	endcase

end


endmodule
