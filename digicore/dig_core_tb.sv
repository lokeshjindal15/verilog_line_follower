/*-----------------------------------------------
* Digital core test bench
*   
*   TBD: description 
 *----------------------------------------------*/

module dig_core_tb();

logic clk, rst_n;

/*-- motion control stuff --*/
logic IR_in_en, IR_mid_en, IR_out_en;
logic [10:0] lft, rht;
logic signed [14:0] lft_reg_sgex, rht_reg_sgex, lft_ref_15b, rht_ref_15b;
logic signed [15:0] lft_ref, rht_ref;
logic go, strt_cnv, cnv_cmplt;

logic [2:0 ]chnnl;
logic [11:0]A2D_res;
  
/*-- a2d and reference memories --*/
reg [11:0] A2D_mem[0:65535];
reg [15:0] ptr;			// address pointer into array that contains analog values
reg [15:0] motor_ref[0:65535];
reg [15:0] refptr;			// address pointer into array that contains analog values
integer i;

/*-- command block --*/
reg cmd_rdy, ID_vld, in_transit;
reg[7:0] cmd, ID;
logic clr_cmd_rdy, clr_ID_vld;
reg[10:0] counter;

logic OK2Move;      // simulate proximity sensor


/////////////////////////////////////////
/// Test parameters 
localparam ID_DELAY = 30;		// clock cycles for correct ID to cause the robot to stop

////////////////////////////////////////
// DUT instance                     ////
////////////////////////////////////////
dig_core iDUT(
  .clk(clk),
  .rst_n(rst_n),
  .cmd_rdy(cmd_rdy),
  .cmd(cmd),
  .clr_cmd_rdy(clr_cmd_rdy),
  .ID(ID),
  .ID_vld(ID_vld),
  .clr_ID_vld(clr_ID_vld),
  .buzz(),
  .buzz_n(),
  .in_transit(in_transit),
  .OK2Move(OK2Move),
  // motion block
  .lft(lft),
  .rht(rht),
  .cnv_cmplt(cnv_cmplt),
  .strt_cnv(strt_cnv),
  .chnnl(chnnl),
  .A2D_res(A2D_res),
  .IR_in_en(IR_in_en), 
  .IR_mid_en(IR_mid_en), 
  .IR_out_en(IR_out_en),
  .go(),
  .led()
);

// Quick hacks to read sign extended values
assign rht_reg_sgex = { {4{rht[10]}} , rht};
assign lft_reg_sgex = { {4{lft[10]}} , lft};

///////////////////////////////////////////
// include tb tasks and blocks
///////////////////////////////////////////

`include "cmdcntrl_tools.vh"
`include "motion_tools.vh"

task clk_n_rst;

  clk = 0;
  rst_n = 0;
  OK2Move = 1;

	repeat (5)@(posedge clk);
	// Bring the DUT out of reset
	@(negedge clk) rst_n = 1;
	repeat (5)@(posedge clk);

endtask

///////////////////////////////////////////////
//  Tests 

// Simple cmd go send and stop once you reach
//  note: this can be re-used in top level tb
//    just ensure reasonable delay ID_DELAY for
//    the new ID to be 
task simple_test;

  OK2Move = 1;
  send_cmd_go(8'b01010000);
  repeat(30 * 15000) @(posedge clk);
  send_ID(8'b00010000);
  
  fork
    begin : check_lft_rht
     while( |lft || |rht) #1; 
	 disable simple_test_timeout;
	end
	begin : simple_test_timeout
	 repeat(ID_DELAY) @(posedge clk);
	 disable check_lft_rht;
	 $display ("ERROR::  SimpleTest: Bot did not stop on reaching right ID\n");
	 $stop();
	end
  join

  $display("SimpleTest: PASSED!\n");
endtask


initial begin

  clk_n_rst();
  init_cmd(); 
  init_motion();

  simple_test();

  repeat(1000) @(posedge clk);
  $stop();
end
/*
initial begin


	send_cmd_stop;
	
	repeat (5)@(posedge clk);

	set_cmd_go;
	send_cmd_go;
	
	for(counter = 0; counter < 10'd100; counter = counter + 1) begin
		repeat (200)@(posedge clk);
		send_ID;
	end
	
end
*/

// Send a rogue command

/*
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

*/

// clk
always
  #10 clk = ~clk;



endmodule
