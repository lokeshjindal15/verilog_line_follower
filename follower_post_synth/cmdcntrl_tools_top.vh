// Command and Control Testbench
// Author: Bhuvana Kakunoori
//
//  Tasks and accompanying models for 
//   interfaces owned by cmd oonctroller


// Setup Initial values to inputs
task init_cmd;
	trmt = 0;
  tx_data = 0;

  send = 0;
  period = 22'h0;
  ID_send = 8'h0;

	counter = 10'h00;
endtask

// task to send Blutooth cmd
task send_via_bluetooth;
  input [7:0] icmd;
  tx_data = icmd;

	trmt = 1;
	repeat(2)@(negedge clk);
	trmt = 0;
endtask

// Task to send commands
task send_cmd_go;
  input [7:0] icmd;
  send_via_bluetooth(icmd);
	$display("Go command for station ID: %b", icmd);
endtask

task send_cmd_stop;

  send_via_bluetooth(8'h00);
	$display("Send command stop!");
endtask

task send_cmd_invalid;
 input [7:0] icmd;
  send_via_bluetooth(icmd);
 $display("Sending an invalid command: %b", icmd);
endtask


///////////////////////////////////////
/// bar code relate
///////////////////////////////////////

// Task to send barcode id
task send_ID;
  input [7:0] iID;
	ID_send = iID;
  period = PERIOD;
  
  send = 1;
  @(posedge clk);
  send = 0;

	$display("Sending ID %b", ID);
endtask

//  Just print our logical state //
always @(in_transit) begin
	if(in_transit)
		$display("Moving");
	else begin
		//$display("Stopped. Station ID : %b, Destination ID: %b", ID[5:0], iDut.cmd[5:0]);
		$display("Stopped at Station ID: %b",ID[5:0]);
	end
end


