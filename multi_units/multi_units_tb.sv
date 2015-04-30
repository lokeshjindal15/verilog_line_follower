/*-----------------------------------------------
* Multi Unit test bench
*   
*   This tb is basically an intermediate stage 
*     for integrating the dut : 
*   the main idea is - 
 *----------------------------------------------*/

module multi_unit_tb();

parameter TEST_NAME = "simple_test";
string test_name;

logic clk, rst_n;

/*-- motion control stuff --*/
logic IR_in_en, IR_mid_en, IR_out_en;
logic [10:0] lft, rht;
logic signed [14:0] lft_reg_sgex, rht_reg_sgex, lft_ref_15b, rht_ref_15b;
logic signed [15:0] lft_ref, rht_ref;
logic go, strt_cnv, cnv_cmplt;

logic [2:0 ]chnnl;
logic [11:0]A2D_res;
logic [7:0] temp_id;
  
/*-- a2d and reference memories --*/
//reg [11:0] A2D_mem[0:65535];    // this is now done by ADC model
//reg [15:0] ptr;			// address pointer into array that contains analog values
reg [15:0] motor_ref[0:65535];
reg [15:0] refptr;			// address pointer into array that contains analog values
integer i;

/*-- out going interfaces from dut blocks--*/
logic BC;               // for bar code reader input

logic RX;               // for UART/CMD interface

logic SCLK;             // A2D interface to the actual A2D
logic MISO;
logic MOSI;
logic a2d_SS_n;

/*-- command block --*/
reg cmd_rdy, ID_vld, in_transit;
reg[7:0] cmd, ID;
logic clr_cmd_rdy, clr_ID_vld;
reg[10:0] counter;

logic OK2Move;      // simulate proximity sensor
logic disable_motion_check;			// set to turn off motion checker

/*-- and finally model related signals--*/
logic	[7:0] tx_data;
logic	tx_done, trmt;

logic [21:0] period;        // chosen random period of barcode signal
logic send, bc_done;
logic [7:0] ID_send;


/////////////////////////////////////////
/// Test parameters 
localparam PERIOD = 12'h20a;
localparam ID_DELAY = 10*PERIOD;		// clock cycles for correct ID to cause the robot to stop
localparam OBS_DELAY = 3;		// clock cycles for the robot to stop on seeing an obstacle
localparam CMD_DELAY = 26040 + 5000;		// clock cycles for tobot to receive and process a cmd : courtesy lokesh tb

////////////////////////////////////////
// Digi Core instance               ////
////////////////////////////////////////
dig_core i_CORE(
  .clk(clk),
  .rst_n(rst_n),
  .cmd_rdy(cmd_rdy),
  .cmd(cmd),
  .clr_cmd_rdy(clr_cmd_rdy),
  .ID(ID),
  .ID_vld(ID_vld),
  .clr_ID_vld(clr_ID_vld),
  .buzz(),      // TODO : export to DUT interface 
  .buzz_n(),    // TODO : export to DUT interface 
  .in_transit(in_transit),
  .OK2Move(OK2Move),
  // motion block
  .lft(lft),
  .rht(rht),
  .cnv_cmplt(cnv_cmplt),
  .strt_cnv(strt_cnv),
  .chnnl(chnnl),
  .A2D_res(A2D_res),
  .IR_in_en(IR_in_en),      // TODO : export to DUT interface 
  .IR_mid_en(IR_mid_en), 
  .IR_out_en(IR_out_en),
  .go(go),
  .led()      // TODO export to DUT ??
);

////////////////////////////////////////
// Barcode reader instance            //
////////////////////////////////////////

barcode i_Barcode(
  .clk(clk), 
  .rst_n(rst_n),
  .BC(BC), 
  .ID_vld(ID_vld), 
  .ID(ID), 
  .clr_ID_vld(clr_ID_vld)
);


////////////////////////////////////////
// A2D interface  Instance           //
////////////////////////////////////////

A2D_intf i_A2D_intf(
  .clk(clk), 
  .rst_n(rst_n), 
  .strt_cnv(strt_cnv), 
  .cnv_cmplt(cnv_cmplt), 
  .chnnl(chnnl), 
  .res(A2D_res), 
  .a2d_SS_n(a2d_SS_n), 
  .SCLK(SCLK), 
  .MOSI(MOSI), 
  .MISO(MISO)
);  

////////////////////////////////////////
// UART Interface Instance            //
////////////////////////////////////////

UART_rx i_UART_rx(
  .clk(clk), 
  .rst_n(rst_n), 
  .clr_rdy(clr_cmd_rdy), 
  .RX(RX), 
  .rdy(cmd_rdy), 
  .cmd(cmd)                                                                                                                                            
);

// Quick hacks to read sign extended values
assign rht_reg_sgex = { {4{rht[10]}} , rht};
assign lft_reg_sgex = { {4{lft[10]}} , lft};



/////////////////////////////////////////
//  Testbench related models  
//////////////////////////////////////////

//Initialize the ADC128S module
ADC128S t_A2D_Model(.clk(clk), .rst_n(rst_n), .SS_n(a2d_SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));

/*-- barcode mimic block --*/
barcode_mimic t_Barcode_mimic(.clk(clk), .rst_n(rst_n), .period(period), .BC(BC),
                      .send(send), .station_ID(ID_send), .BC_done(bc_done));

// Instance Blue tooth  UART model
uart_trans t_UART_TX(        // TBD: rename to UART_tx
.clk(clk), 
.rst_n(rst_n), 
.TX(RX), 
.trmt(trmt),          /*-- these thre are driven by testbench --*/
.tx_data(tx_data), 
.tx_done(tx_done)
);


///////////////////////////////////////////
// include tb tasks and blocks
//      
///////////////////////////////////////////

`include "cmdcntrl_tools_mu.vh"
`include "motion_tools_mu.vh"
`include "../tests/digi_tests.vh"

task clk_n_rst;

  clk = 0;
  rst_n = 0;
  OK2Move = 1;

	repeat (5)@(posedge clk);
	// Bring the DUT out of reset
	@(negedge clk) rst_n = 1;
	repeat (5)@(posedge clk);

endtask

initial begin

  clk_n_rst();
  init_cmd(); 
  init_motion();

  test_name = TEST_NAME;
  run_digi_test(); // test_name set above

  repeat(1000) @(posedge clk);
  $stop();
end

// clk
always
  #10 clk = ~clk;



endmodule
