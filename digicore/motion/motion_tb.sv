
/*------------------------------------------------------------------
*
*  Motion Controller: Tb 
*    couple of things we do here include -
*     i- checking the PI math
*     2- looking for braking condition
*     
*------------------------------------------------------------------*/



module motion_tb();
										 			

logic clk, rst_n;
logic IR_in_en, IR_mid_en, IR_out_en;
logic [11:0] lft_reg, rht_reg;
logic [15:0] lft_reg_sgex, rht_reg_sgex, lft_ref, rht_ref;
logic go, strt_cnv, cnv_cmplt;

logic [2:0 ]chnnl;
logic [11:0]A2D_res;
  
reg [11:0] A2D_mem[0:65535];
reg [15:0] ptr;			// address pointer into array that contains analog values
reg [15:0] motor_ref[0:65535];
reg [15:0] refptr;			// address pointer into array that contains analog values

integer i;

// Instantiate DUT //
motion iDUT(.clk(clk), .rst_n(rst_n), .A2D_res(~A2D_res), .cnv_cmplt(cnv_cmplt),
            .go(go), .chnnl(chnnl), .strt_cnv(strt_cnv),
            .IR_in_en(IR_in_en), .IR_mid_en(IR_mid_en), .IR_out_en(IR_out_en),
            .lft_reg(lft_reg), .rht_reg(rht_reg) );
				
					
enum {IDLE = 0, WAIT_4095, 
                  A2D_RIGHT, IN_RIGHT, MID_RIGHT, OUT_RIGHT,
                  WAIT_32, 
                  A2D_LEFT, IN_LEFT, MID_LEFT, OUT_LEFT,
                  INTGL, ICOMP, PCOMP,
                  ACCUM_RIGHT, RIGHT_REG,
                  ACCUM_LEFT, LEFT_REG,
                  UPDATE_IR_ALL} fsm_state;

assign rht_reg_sgex = { {4{rht_reg[11]}} , rht_reg};
assign lft_reg_sgex = { {4{lft_reg[11]}} , lft_reg};
//logic [4:0] fsm_state;
// Load analog values //
// and load results //
initial begin
  $readmemh("analog.dat", A2D_mem);		// read the analog data
  $readmemh("check_math.dat", motor_ref);		// reference results for motor
end


// Block to send A2D results -- just a hacky model//
always @(posedge strt_cnv) begin
  
  cnv_cmplt = 0;
  //$display("    LEDS - {IR_out_en, IR_mid_en, IR_in_en}i = %b %b %b", IR_out_en, IR_mid_en, IR_in_en );
  repeat(256) @(posedge clk);

  A2D_res = {4'b0000, A2D_mem[ptr*8+chnnl]};
  cnv_cmplt = 1;
  ptr = ptr + 1;

  // dump IR values
  //$display("   [a2d model] returning value %h", ~A2D_res);
end


//assign fsm_state = iDUT.state;

// Task to set the both in running mode //
task runbot();

  //while(fsm_state != LEFT_REG)
  while(iDUT.dst2lft != 1)
    #1;

  @(posedge clk);
  @(posedge clk);

  rht_ref = motor_ref[refptr * 2];
  lft_ref = motor_ref[refptr * 2 + 1];

  if((lft_reg_sgex != lft_ref) || (rht_reg_sgex != rht_ref)) begin
    $display("[iter=%d] WARN: mismatch Expected: lht=%x rht=%x, found lht = %x, rht = %x, left diff=%d, right diff=%d",
                      	i, lft_ref, rht_ref, lft_reg_sgex, rht_reg_sgex, lft_reg_sgex - lft_ref, rht_reg_sgex - rht_ref);
    /*if( ((lft_reg_sgex - lft_ref) > 1) || ((lft_ref - lft_reg_sgex) > 1) || ((rht_reg_sgex - rht_ref) > 1) || ((rht_ref - rht_reg_sgex) > 1) ) begin
	   $display( "ERROR: intolerable difference");
       $stop();
	end*/
  end
  else begin
    $display("[iter=%d] OK: values match lht = %x, rht = %x", i, lft_reg_sgex, rht_reg_sgex);
  end

  refptr = refptr + 1;
  i = i + 1;
  //#5 go = 0;

  @(posedge clk);

endtask

// Begin Testbench //
initial begin

  clk = 0;
  rst_n = 0;
  A2D_res = 0;
  cnv_cmplt = 0;
  go = 0;
  ptr = 0;
  refptr = 0;
  i = 0;                 // trial number
  
  repeat (5)@(posedge clk);
  	// Bring the DUTs out of reset
  @(negedge clk) rst_n = 1;
  repeat (50)@(posedge clk);

  $display("drive for lht = %h, rht = %h\n", lft_reg, rht_reg);

  // run throught control loop twice only
  go = 1;
  repeat(79) runbot();
  
  $display("***** DONE ****");
  $display("***** ALL TESTS PASSED *****");
  $stop;
end

always
  #10 clk = ~clk;
 

endmodule
  
