// Command and Control Testbench
// Author: Bhuvana Kakunoori

module cmdcntrl_tb();

reg clk, rst_n;
reg cmd_rdy, ID_vld, in_transit;
reg[7:0] cmd, ID;
reg[7:0] tmp_cmd;
logic clr_cmd_rdy, clr_ID_vld;

reg[10:0] counter;

//Initialize the DUT
Cmdcntrl DUT(clk, rst_n, cmd_rdy, cmd, clr_cmd_rdy, ID_vld, clr_ID_vld, ID, in_transit);

// Initial values to inputs
initial begin
	clk = 0;
	rst_n = 0;
	cmd_rdy = 0;
    ID_vld = 0;

	cmd = 8'h00;
	ID = 8'b00000100;

	counter = 10'h00;
end

// clk signal
always @(clk) #10 clk <= ~clk;

task set_cmd_go;
	cmd = 8'b01010000;
endtask

// Task to send commands
task send_cmd_go;
	cmd_rdy = 1;
	$display("Go command for station ID: %b", cmd);
endtask

task send_cmd_stop;
	cmd = 8'b00000000;
	cmd_rdy = 1;
endtask

task send_cmd_invalid;
	$display("Sending an invalid command");
	cmd = 8'b11000111;
	cmd_rdy = 1;
endtask

task send_ID;
	ID = ID + 1;
	ID_vld = 1;
	$display("Sending ID %b", ID);
endtask

always @(clr_cmd_rdy, clr_ID_vld) begin
	if(clr_cmd_rdy)
		cmd_rdy = 0;
	if(clr_ID_vld) 
		ID_vld = 0;
end

always @(in_transit) begin
	if(in_transit)
		$display("Moving");
	else begin
		$display("Stopped. Station ID : %b, Destination ID: %b", ID[5:0], cmd[5:0]);
		$stop;
	end
end

initial begin

	repeat (5)@(posedge clk);
	// Bring the DUT out of reset
	@(negedge clk) rst_n = 1;
	repeat (5)@(posedge clk);

	send_cmd_stop;
	
	repeat (5)@(posedge clk);

	set_cmd_go;
	send_cmd_go;
	
	for(counter = 0; counter < 10'd100; counter = counter + 1) begin
		repeat (200)@(posedge clk);
		send_ID;
	end
	
end

// Send a rogue command
initial begin
	repeat (900)@(posedge clk);
	tmp_cmd = cmd;
	send_cmd_invalid;

	repeat (5) @(posedge clk);
	cmd = tmp_cmd;
end

//Send another go command with different dest_ID
initial begin
	repeat (1100)@(posedge clk);
	cmd = cmd+1;
	send_cmd_go;

end

//Send a stop command
initial begin 
	repeat (1500)@(posedge clk);
	send_cmd_stop;
end


endmodule