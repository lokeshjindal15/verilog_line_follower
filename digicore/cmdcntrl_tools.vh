// Command and Control Testbench
// Author: Bhuvana Kakunoori
//
//  Tasks and accompanying models for 
//   interfaces owned by cmd oonctroller


// Setup Initial values to inputs
task init_cmd;
	cmd_rdy = 0;
  ID_vld = 0;

	cmd = 8'h00;
	ID = 8'b00000100;

	counter = 10'h00;
endtask

task set_cmd_go;
	cmd = 8'b01010000;
endtask

// Task to send commands
task send_cmd_go;
  input [7:0] icmd;
  cmd = icmd;
	cmd_rdy = 1;
	$display("Go command for station ID: %b", cmd);
endtask

task send_cmd_stop;
	cmd = 8'b00000000;
	cmd_rdy = 1;
endtask

task send_cmd_invalid;
 input [7:0] icmd;
  cmd = icmd;
  cmd_rdy = 1;
 $display("Sending an invalid command: %b", cmd);
endtask

// Task to send barcode id
task send_ID;
  input [7:0] iID;
	ID = iID;
	ID_vld = 1;
	$display("Sending ID %b", ID);
endtask

task inc_ID;
	ID = ID + 1;
	ID_vld = 1;
	$display("Sending ID %b", ID);
endtask


// Models for UART Barcode interface  //

always @(clr_cmd_rdy, clr_ID_vld) begin
	if(clr_cmd_rdy)
		cmd_rdy = 0;
	if(clr_ID_vld) 
		ID_vld = 0;
end

//  Just print our logical state //
always @(in_transit) begin
	if(in_transit)
		$display("Moving");
	else begin
		$display("Stopped. Station ID : %b, Destination ID: %b", ID[5:0], cmd[5:0]);
	end
end


