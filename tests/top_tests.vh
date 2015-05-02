
// Send a command go to a station ID
// Then on way send invalid IDs (ID[7:6] it not 2'b00) 
// Should stop at correct station ID 
task invalidID_test();

  $display("Starting: invalidID_test");

  OK2Move = 1;
  send_cmd_go(8'b01_010000);
  repeat(50 * 6000) @(posedge clk);
  send_ID(8'b01_010000);
 
  repeat(50 * 6000) @(posedge clk);
  send_ID(8'b10_010100);

  repeat(50 * 6000) @(posedge clk);
  send_ID(8'b00_010000);

  check_if_stops_on_id();
 
  $display("invalidID_test: PASSED!\n");
endtask
	
task glitchBC_test();

  $display("Starting: glitchBC_test");

  disable_motion_check = 1;
  
  // start the bot
  OK2Move = 1;
  send_cmd_go(8'b01_010000);
  repeat(6000) @(posedge clk);
  
  //send a glitch pulse on BC signal to barcode reader
  force iDut.iBC.BC = 0;
  repeat(1000) @(posedge clk);
  release iDut.iBC.BC;
  
  // wiat for barcode reader to resolve from hang
  repeat(4195000) @(posedge clk); // barcode timeout 0x3fffff = 4194303
  
  //send correct station ID
  send_ID(8'b00_010000);
  
  repeat(ID_DELAY)@(posedge clk);

  if(iDut.go == 0)
    ; // ok
  else begin
     $display ("glitchBC_test IMEOUT ERROR:: Bot did not stop on correct ID\n");
	 $stop();
  end
  
  $display("glitchBC_test: PASSED!\n");
  
endtask

/////////////////////////////////////////////////
/*----------------------------------------------
 *  main test run wrapper:
 *   Args:  test_name : (string) name of test    
 *--------------------------------------------*/
task run_top_test();

  if(test_name == "invalidID_test")
    invalidID_test();
  else if(test_name == "glitchBC_test")
    glitchBC_test();

endtask
