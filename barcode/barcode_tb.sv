/*-----------------------------------------------------------
  Barcode Reader Testbench:
     self checking testbench for the bar code reader
     uses barcode_mimic module
 
-------------------------------------------------------------*/

module barcode_tb();

reg clk, rst_n;

logic clr_ID_vld;
logic [7:0] ID_mon, ID_send;
logic  BC_stim;            // the bar code stimulus
logic  ID_vld_mon;         // indicate that the byte is ready
logic  false_start_n;      // use to test false start bit

logic [21:0] period;        // chosen random period of barcode signal
logic send, bc_done;

/*---
  Key things to check : 
  1-try various combinations of station ids,
	2-see if invalid ones are ignored
  2-see if valid ids are sent correctly
	4-clr id vld check
  5-check spurious inputs
--*/

/*-- DUT --*/
barcode iDUT(.clk(clk), .rst_n(rst_n), .BC(BC_stim & false_start_n), .ID(ID_mon),
                .ID_vld(ID_vld_mon), .clr_ID_vld(clr_ID_vld));

/*-- barcode mimic block --*/
barcode_mimic iModel(.clk(clk), .rst_n(rst_n), .period(period), .BC(BC_stim),
                      .send(send), .station_ID(ID_send), .BC_done(bc_done));

integer i;
reg rbit;
                      
initial begin
  clk = 0;
  rst_n = 0;
  send = 0;
  period = 22'h0;
  ID_send = 8'h0;
  clr_ID_vld = 0;

  false_start_n = 1;    // keep things in normal mode
  
  @(posedge clk);
  @(negedge clk) rst_n = 1;
  
  @(posedge clk);
  
  period = 22'h200;
  $display("\n Testing for period %d\n", period);
  loop_ids();
  $display("\n Test 1 passed");
 
  period = 22'h1000;
  $display("\n Testing for period %d\n", period);
  loop_ids();
  $display("\n Test 2 passed");
  
  
  period = 22'h20000f;
  $display("\n Testing for period %d\n", period);
  /*-- too big a period, try a few random
     combinations , sometimes don't clear vld bit!--*/
  for(i = 0; i < 1; i = i+1) begin
    {rbit,ID_send} = $random & 8'h1ff;
    send_recv_barcode();
    if(rbit) check_clr_vld();
    while(!bc_done) #1;
  end
  $display("\n Test 3 passed");
  
  
  
  $display("\n Testing for false start bit\n");
  false_start_n = 0;
  repeat(30) @(posedge clk);
  false_start_n = 1;

  repeat(100) @(posedge clk);

  // now the state machine must be in idle state and 
  //  capable of receiving a new transaction
  period = 22'h20a; #1;
  $display("\n Testing single data send for %d period", period);
  ID_send = 8'h19;
  #1; //remove to manifest mimic issue
  send_recv_barcode();
  $display("\n Start bit Test passed too :D\n");
  
  $display("Yea! :) : ALL TESTS PASSED");
  $stop();
  
end

always
  #2 clk = ~clk;


task loop_ids;
  /*-- first check all valid combinations --*/
  for(ID_send = 8'h0; ID_send < 8'h40; ID_send = ID_send + 1) begin: loop
    send_recv_barcode();
    check_clr_vld();
    while(!bc_done) #1;
  end
  
  /*-- now try random transmissions where invalid 
     codes can be sent -don't clear vld bit!--*/
  for(i = 0; i < 36; i = i+1) begin
    ID_send = $random & 8'hff;
    send_recv_barcode();
    while(!bc_done) #1;
  end
     
endtask
  
task send_recv_barcode; 
  send = 1;
  @(posedge clk);
  send = 0;
  
  fork
    begin: good_wait
      @(posedge ID_vld_mon);
      disable time_out;
    end
    begin: time_out
      @(posedge bc_done);
      disable good_wait;
    end
  join
  
  /*-- time-out case -*/
  if(ID_send[7:6] == 2'b00 && ~ID_vld_mon) begin
    $display("ERROR: Timed out on receiving data");
    $stop();
  end
  
   /*-- bad id valid -*/
  if(ID_send[7:6] != 2'b00 && ID_vld_mon) begin
    $display("ERROR: ID valid set on invalid data");
    $stop();
  end
  
  if(ID_send[7:6] != 2'b00) begin 
    $display("Cool: Spurious data = %x, ignored", ID_send);
    disable send_recv_barcode;       // ie : continue
  end
  
  if(ID_mon == ID_send) begin
    $display("Cool: Sent data = %x, Received data = %x", ID_send, ID_mon);
  end
  else begin
    $display("ERROR: Sent data = %x, Received data = %x", ID_send, ID_mon);
    $stop();
  end
endtask

task check_clr_vld;
  
  clr_ID_vld = 1;
  @(posedge clk);
  @(negedge clk);
  if(ID_vld_mon) begin
    $display("ERROR: ID_vld not cleared when should have");
    $stop();
  end
  
  clr_ID_vld = 0;
endtask  
  
endmodule
