
/*------------------------------------------------------------------
*
*  Motion Controller: Tb Utilities
*    couple of things we do here include -
*     i- checking the PI math
*     2- looking for braking condition
*     
*------------------------------------------------------------------*/


/*
enum {IDLE = 0, WAIT_4095, 
                  A2D_RIGHT, IN_RIGHT, MID_RIGHT, OUT_RIGHT,
                  WAIT_32, 
                  A2D_LEFT, IN_LEFT, MID_LEFT, OUT_LEFT,
                  INTGL, ICOMP, PCOMP,
                  ACCUM_RIGHT, RIGHT_REG,
                  ACCUM_LEFT, LEFT_REG,
                  UPDATE_IR_ALL} fsm_state;
*/

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

  A2D_res = ~( {4'b0000, A2D_mem[ptr*8+chnnl]} );
  cnv_cmplt = 1;
  ptr = ptr + 1;

  // dump IR values
  //$display("   [a2d model] returning value %h", ~A2D_res);
end


// Checker to see if PI math is correct //
always @(posedge iDUT.iMotion.dst2lft) begin

  @(posedge clk);
  @(posedge clk);

  /*-- note we look at 15:1 for reference only --*/
  rht_ref = motor_ref[(refptr * 2)];
  lft_ref = motor_ref[(refptr * 2) + 1];
  
  // strip out LSB
  rht_ref_15b = rht_ref[15:1];
  lft_ref_15b = lft_ref[15:1];

  if((lft_reg_sgex != lft_ref_15b) || (rht_reg_sgex != rht_ref_15b)) begin
    $display("[iter=%d] WARN: mismatch Expected: lht=%x rht=%x, found lht = %x, rht = %x, left diff=%d, right diff=%d",
                      	i, lft_ref_15b, rht_ref_15b, lft_reg_sgex, rht_reg_sgex, lft_reg_sgex - lft_ref_15b, rht_reg_sgex - rht_ref_15b);
    if( ((lft_reg_sgex - lft_ref_15b) > 1) || ((lft_reg_sgex - lft_ref_15b) < -1) || ((rht_reg_sgex - rht_ref_15b) > 1) || ((rht_reg_sgex - rht_ref_15b) < -1) ) begin
	   $display( "ERROR: intolerable difference");
       $stop();
	end
	
  end
  else begin
    $display("[iter=%d] OK: values match lht = %x, rht = %x", i, lft_reg_sgex, rht_reg_sgex);
  end

  refptr = refptr + 1;
  i = i + 1;

  @(posedge clk);

end

// Init motion tb signals//
task init_motion;

  A2D_res = 0;
  cnv_cmplt = 0;
  go = 0;
  ptr = 0;
  refptr = 0;
  i = 0;                 // trial number
  
endtask
  
