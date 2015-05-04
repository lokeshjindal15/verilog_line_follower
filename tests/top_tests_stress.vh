
// simple_long_ttest
// This test works ou the bot over a long track ie a long sequence
//  of a2d errors, we are constantly checking the PI math 
//   (expected satureation of PI terms take place here

task simple_long_test;

  OK2Move = 1;
  send_cmd_go(8'b01010000);
  
  repeat(200 * 15000) @(posedge clk);
  send_ID(8'b00010001);		// mimic passing other stations
  
  repeat(200 * 15000) @(posedge clk);
  send_ID(8'b00010011);		
  
  repeat(200 * 15000) @(posedge clk);
  send_ID(8'b00010111);	
  
  repeat(200 * 15000) @(posedge clk);
  send_ID(8'b00011111);
  
  repeat(200 * 15000) @(posedge clk);
  send_ID(8'b00111111)
  
  repeat(200 * 15000) @(posedge clk);
  send_ID(8'b00010000);		// and we are home
 
  check_if_stops_on_id();
 
  $display("sinple_long_test: PASSED!\n");
endtask

// long_stop_go : this test here makes the bot goes on and off
//   stop and go and it should just brake and start at the 
//   correct places

integer iter1;
task long_stop_go_test;
  
  $display("Starting: long_stop_go_test ...");

  disable_motion_check = 1; // since we will stop the bot multiple times
  
  OK2Move = 1;
  send_cmd_go(8'b01_010101);

  for (iter1 = 1; iter1 < 50; iter1 = iter1 + 1)
  begin
    repeat(10 * 15000) @(posedge clk);
    if(|lft || |rht ) 
    ; // OK we are moving
    else begin
      $display("iter1 = %d : ERROR FAIL! long_stop_go_test. Stopped at wrong ID %b with lft = %h and rht = %h", iter1, ID[5:0], lft, rht);
      $stop;
    end
    
    send_cmd_stop();

    // check_if_stops_on_cmdstop();
    repeat(CMD_DELAY) @(posedge clk);
    if (!(&lft && &rht))
	    ; // OK we stopped
    else
    begin
	    $display("iter1 = %d : ERROR FAIL! long_stop_go_test. DID NOT stop with lft = %h and rht = %h", iter1, lft, rht);
    end

    send_cmd_go(8'b01_010101);
  end

  send_ID(8'b00_010101);
  
  check_if_stops_on_id();
  
  $display("long_stop_go_test test passed !!");

endtask



integer iter2;
class random_id_t;
	rand bit [7:0] id;
	constraint id_not_destination{
		id[7:5] == 3'b000;
	}
endclass

random_id_t rogueid;

// long_stop_go : and now for some more fun this test here sends cmds to
//   stop and go and the bot should just brake and start at the  correct places
//   in the meanwhile we pass by stations we are not interested in !!

task long_stop_go_test2;
 
  rogueid = new();

  $display("Starting: long_stop_go_test2 ...");

  disable_motion_check = 1; // since we will stop the bot multiple times
  
  OK2Move = 1;
  send_cmd_go(8'b01_100000);

  for (iter2 = 1; iter2 < 50; iter2 = iter2 + 1)
  begin
    repeat(10 * 15000) @(posedge clk);
    if(|lft || |rht ) 
    ; // OK we are moving
    else begin
      $display("iter2 = %d : ERROR FAIL! long_stop_go_test2. Stopped at wrong ID %b with lft = %h and rht = %h", iter2, ID[5:0], lft, rht);
      $stop;
    end
    
    send_cmd_stop();

    // check_if_stops_on_cmdstop();
    repeat(CMD_DELAY) @(posedge clk);
    if (!(&lft && &rht))
	    ; // OK we stopped
    else
    begin
	    $display("iter2 = %d : ERROR FAIL! long_stop_go_test2. DID NOT stop with lft = %h and rht = %h", iter2, lft, rht);
    end

    send_cmd_go(8'b01_100000);
    repeat(10 * 15000) @(posedge clk);
    rogueid.randomize();
    $display("iter2 = %d Sending rogue ID : %h\n", iter2, rogueid.id);
    send_ID(rogueid.id);
  end

  send_ID(8'b00_100000);
  
  check_if_stops_on_id();
  
  $display("long_stop_go_test2 test passed !!");

endtask


integer iter3;
class random_id_t3;
	rand bit [7:0] id;
	constraint id_not_destination{
		id[7:5] == 3'b000;
	}
endclass

// long_stop_go_3: keep putting obstacles in the bots path and 
//   make sure the bot starts up again. 
//   in the meanwhile we pass by stations we are not interested in !!

random_id_t3 rogueid3;

task long_stop_go_test3;
 
  rogueid3 = new();

  $display("Starting: long_stop_go_test3 ...");

  disable_motion_check = 1; // since we will stop the bot multiple times
  
  OK2Move = 1;
  send_cmd_go(8'b01_100000);

  for (iter3 = 1; iter3 < 50; iter3 = iter3 + 1)
  begin
    repeat(10 * 15000) @(posedge clk);
    if(|lft || |rht ) 
    ; // OK we are moving
    else begin
      $display("iter3 = %d : ERROR FAIL! long_stop_go_test3. Stopped at wrong ID %b with lft = %h and rht = %h", iter3, ID[5:0], lft, rht);
      $stop;
    end
    
    // stop the bot
    OK2Move = 0;

    // check_if_stops_on_cmdstop();
    repeat(CMD_DELAY) @(posedge clk);
    if (!(&lft && &rht))
	    ; // OK we stopped
    else
    begin
	    $display("iter3 = %d : ERROR FAIL! long_stop_go_test3. DID NOT stop with lft = %h and rht = %h", iter3, lft, rht);
    end

    OK2Move = 1;
    repeat(10 * 15000) @(posedge clk);
    rogueid3.randomize();
    $display("iter3 = %d Sending rogue ID : %h\n", iter3, rogueid3.id);
    send_ID(rogueid3.id);
  end

  send_ID(8'b00_100000);
  
  check_if_stops_on_id();
  
  $display("long_stop_go_test3 test passed !!");

endtask


/////////////////////////////////////////////////
/*----------------------------------------------
 *  main test run wrapper:
 *   Args:  test_name : (string) name of test    
 *--------------------------------------------*/
task run_top_test_stress();

if(test_name == "simple_long_test")
    simple_long_test();
if(test_name == "long_stop_go_test")
    long_stop_go_test();
if(test_name == "long_stop_go_test2")
    long_stop_go_test2();
if(test_name == "long_stop_go_test3")
    long_stop_go_test3();

endtask
