/////////////////////////////////////////////
// helper tasks for timeouts
/////////////////////////////////////////////
/*
task check_if_stops_on_id;
  fork
    begin : check_lft_rht
     while( |lft || |rht) #1; 
	 disable simple_timeout;
	end
	begin : simple_timeout
	 repeat(ID_DELAY) @(posedge clk);
	 disable check_lft_rht;
	 $display ("TIMEOUT ERROR::  Bot did not stop on correct ID\n");
	 $stop();
	end
  join
endtask

task check_if_stops_on_obs;
  fork
    begin : check_lft_rht1
     while( |lft || |rht) #1; 
	 disable simple_timeout1;
	end
	begin : simple_timeout1
	 repeat(OBS_DELAY) @(posedge clk);
	 disable check_lft_rht1;
	 $display ("TIMEOUT ERROR::  Bot did not stop on obstacle\n");
	 $stop();
	end
  join
endtask
*/

task check_if_stops_on_id;
  integer timer;
  timer = 0;
  while( ( |lft || |rht) && timer <= ID_DELAY) begin
	@(posedge clk);
    timer = timer + 1;
  end

  if(lft==11'b0 && rht==11'b0)
    ; // ok
  else begin
     $display ("TIMEOUT ERROR:: func check_if_stops_on_id:  Bot did not stop on correct ID\n");
	 $stop();
  end
  
endtask

task check_if_stops_on_obs;
  fork
    begin : check_lft_rht1
     while( |lft || |rht) #1; 
	 disable simple_timeout1;
	end
	begin : simple_timeout1
	 repeat(OBS_DELAY) @(posedge clk);
	 disable check_lft_rht1;
	 $display ("TIMEOUT ERROR:: func check_if_stops_on_obs:  Bot did not stop on obstacle\n");
	 $stop();
	end
  join
endtask

task check_if_stops_on_cmdstop;
  fork
    begin : check_lft_rht2
     while( |lft || |rht) #1; 
	 disable simple_timeout2;
	end
	begin : simple_timeout2
	 repeat(CMD_DELAY) @(posedge clk);
	 disable check_lft_rht2;
	 $display ("TIMEOUT ERROR:: func check_if_stops_on_cmdstop:  Bot did not stop on obstacle\n");
	 $stop();
	end
  join
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
  repeat(50 * 15000) @(posedge clk);
  send_ID(8'b00010000);
 
  check_if_stops_on_id();
 
  $display("SimpleTest: PASSED!\n");
endtask

// FakeIDtest send a go cmd, and send few fakeIDs
// before sending the correct stop ID. Check if the bot
// stops at the correct station ID.
task fakeID_test;
  logic [7:0] tmp_ID;
  
  $display("Starting FakeID Test...");
  
  OK2Move = 1;
  send_cmd_go(8'b01010000);
  repeat(10 * 15000) @(posedge clk);
  tmp_ID = 8'b00001000;
  send_ID(tmp_ID);
  
  for(counter = 0; counter < 9; counter = counter + 1) begin
      repeat(ID_DELAY) @(posedge clk);
      if( ~(|lft || |rht) && (ID[5:0] != 6'b010000)) begin
       $display("Error: Bot stopped at the wrong ID %b", ID[5:0]);
       $stop;
      end
      repeat(10 * 15000) @(posedge clk);
      tmp_ID = tmp_ID + 1;
      send_ID(tmp_ID);
  end

  $display("FAKEIDTest: PASSED!\n");

endtask

// Send a go cmd, while the bot is moving set OK2Move 
// to 0 for a while, and then let it go,
// check if bot gets to the final destiantion or not
task blockedbot_test;

  disable_motion_check = 1;
  $display("Starting Blocked bot test ..");

  OK2Move = 1;
  send_cmd_go(8'b01010000);
  repeat(25 * 15000) @(posedge clk);

  OK2Move = 0;
  check_if_stops_on_obs();

  repeat(25 * 15000) @(posedge clk);
  OK2Move = 1;
  
  repeat(10 * 15000) @(posedge clk);
  send_ID(8'b00010000);
  
  check_if_stops_on_id();

  $display("Blocked Bot test Passed!! ");

endtask

// send a cmdgo to station A, send a cmdstop,check if it stops, then send a cmdg to station B,
// send ID A, then send ID B, bot should not stop at A but only at B

task stop_test;
  
  disable_motion_check = 1;
  $display("Starting stopped test ..");
  
  OK2Move = 1;
  send_cmd_go(8'b01010000);

  repeat(10 * 15000) @(posedge clk);
  send_cmd_stop();
  
  check_if_stops_on_cmdstop();

  repeat(10 * 15000) @(posedge clk);
  send_cmd_go(8'b01011000);
  
  repeat(10 * 15000) @(posedge clk);
  send_ID(8'b00010000);

  if(~(|lft || |rht) ) begin
    $display("Stop test failed. Stopped at wrong ID %b", ID[5:0]);
    $stop;
  end

  repeat(10 * 15000) @(posedge clk);
  send_ID(8'b00011000);  

  check_if_stops_on_id();
  
  $display("Stop test passed !!");

endtask

// rogue cmd1: we set the bot on motion, to station id A, 
//   stop it at an obstacle, and at this point send a rogue cmd, 
//   then pull out the obstactle, wanna check it still stops 
//     at the correct destination

task rogue_cmd_test1;

  disable_motion_check = 1;

  $display("Starting: rogue cmd test 1\n");

  OK2Move = 1;
  // send cmd go for ID A = 101001
  send_cmd_go(8'b01_101001);

  repeat(25 * 15000) @(posedge clk);

  OK2Move = 0;
  check_if_stops_on_obs();

  // send rogue cmd go for ID B =  101011
  send_cmd_invalid(8'b11_101011);

  repeat(2 * CMD_DELAY) @(posedge clk);

  repeat(2 * 15000) @(posedge clk);
  
  OK2Move = 1;    // let the possibly confused bot go
  //init_motion();  // HACK!! checker does not account for FWD being reset
                  //  so lets reset to older values again
                  // DUH!!! now Intgr is not getting reset so wtf?
  //disable motion_checker;       // no more motion checks, TODO : FIXME
  repeat(25 * 15000) @(posedge clk);
  
  // send erroenous ID B = 101011
  send_ID(8'b00_101011);
  repeat(ID_DELAY) @(posedge clk);

  // did the bot stop?
  if( lft==11'b0 && rht==11'b0 ) begin
    $display("ERROR: bot stops at erroneous ID");
    $stop();
  end

  repeat(1000) @(posedge clk); 

  // send valid ID A
  send_ID(8'b00_101001);
  repeat(ID_DELAY) @(posedge clk);

  check_if_stops_on_id();

  $display("Rogue cmd Test1: PASSED!\n");
endtask

// rogue cmd2: send a rogue cmd when the bot is stationary, it should not move 
//   then send a cmdgo, also send a few rogue cmd in between , make sure it doesn't
//   stop on the way, and finally send the right ID

task rogue_cmd_test2;
 
  $display("Starting: rogue cmd test 2\n");
  
  OK2Move = 1;
  // send a rogue cmd for ID 1
  send_cmd_invalid(8'b10_101011);
  repeat(2*CMD_DELAY) @(posedge clk);
  
 // did the bot move?
  if( |lft || |rht ) begin
    $display("ERROR1: bot moved on rogue CMD");
    $stop();
  end
  
  // send cmd go for ID A = 101010
  send_cmd_go(8'b01_101010);

  repeat(25 * 15000) @(posedge clk);

  // send rogue cmd go for ID B = 001000
  send_cmd_invalid(8'b11_001000);
  repeat(2 * CMD_DELAY) @(posedge clk);

  repeat(25 * 15000) @(posedge clk);
  
  // send erroenous ID B = 001000
  send_ID(8'b00_001000);
  repeat(ID_DELAY) @(posedge clk);

  // send erroneous ID 1  101011
  send_ID(8'b00_101011);
  repeat(ID_DELAY) @(posedge clk);

  // did the bot stop?
  if( lft==11'b0 && rht==11'b0 ) begin
    $display("ERROR2: bot stops at erroneous ID");
    $stop();
  end

  repeat(1000) @(posedge clk); 

  // send valid ID A = 101010
  send_ID(8'b00_101010);
  repeat(ID_DELAY) @(posedge clk);

  check_if_stops_on_id();

  $display("Rogue cmd Test2: PASSED!\n");
  
 endtask

task reroute_test();

  $display ("Sarting: Reroute Test ...");
  
  OK2Move = 1;
  // send go cmd for ID1 -  011101
  send_cmd_go(8'b01_011101);
  
  repeat(25 * 15000) @(posedge clk);
  
  // re-route to a different ID2 - 011100
  send_cmd_go(8'b01_011100);
  
  repeat(25 * 15000) @(posedge clk);
  
  // send old ID1
  send_ID(8'b00_011101);
  
  repeat(ID_DELAY) @(posedge clk);
    // did the bot stop?
  if( lft==11'b0 && rht==11'b0 ) begin
    $display("ERROR2: bot stops at erroneous ID");
    $stop();
  end
  
   // send old ID1
  send_ID(8'b00_011100);
  
  repeat(ID_DELAY) @(posedge clk);

  check_if_stops_on_id();

  $display("Reroute Test: PASSED!\n");

endtask

  
/////////////////////////////////////////////////
/*----------------------------------------------
 *  main test run wrapper:
 *   Args:  test_name : (string) name of test    
 *--------------------------------------------*/
task run_digi_test();

  if(test_name == "simple_test")
    simple_test();
  else if(test_name == "fakeID_test")
    fakeID_test();
  else if(test_name == "blockedbot_test")
    blockedbot_test();
  else if(test_name == "reroute_test")
    reroute_test();
  else if(test_name == "stop_test")
    stop_test();
  else if(test_name == "rogue_cmd_test1")
    rogue_cmd_test1();
  else if(test_name == "rogue_cmd_test2")
    rogue_cmd_test2();
  else if(test_name == "all")
    $display("SORRY: disabled all as it does not work ");
    //run_all_digi_tests();
  else
    $display("Digi Test: Sorry no matching test found digi tests for %s", test_name);
  
endtask

/* -- run all tests :NOT WORKING--*/
task run_all_digi_tests();
  simple_test();
  fakeID_test();
  blockedbot_test();
  reroute_test();
  stop_test();
  rogue_cmd_test1();
  rogue_cmd_test2();
endtask

