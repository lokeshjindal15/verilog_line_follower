
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
  //$readmemh("analog.dat", A2D_mem);		// read the analog data
  $readmemh("../tests/check_math.dat", motor_ref);		// reference results for motor
end

// Checker to see if PI math is correct //
always @(posedge iDut.iCORE.iMotion.dst2lft) begin : motion_checker

  if(disable_motion_check)
      disable motion_checker;
	  
  @(posedge clk);
  @(posedge clk);

  /*-- note we look at 15:1 for reference only --*/
  rht_ref = motor_ref[(refptr * 2)];
  lft_ref = motor_ref[(refptr * 2) + 1];
  
  // strip out LSB
  rht_ref_15b = rht_ref[15:1];
  lft_ref_15b = lft_ref[15:1];

  // if we are moving check the values
  if(go && ((lft_reg_sgex != lft_ref_15b) || (rht_reg_sgex != rht_ref_15b))) begin
    $display("[iter=%d] WARN: mismatch Expected: lht=%x rht=%x, found lht = %x, rht = %x, left diff=%d, right diff=%d",
                      	i, lft_ref_15b, rht_ref_15b, lft_reg_sgex, rht_reg_sgex, lft_reg_sgex - lft_ref_15b, rht_reg_sgex - rht_ref_15b);
    if( ((lft_reg_sgex - lft_ref_15b) > 1) || ((lft_reg_sgex - lft_ref_15b) < -1) || ((rht_reg_sgex - rht_ref_15b) > 1) || ((rht_reg_sgex - rht_ref_15b) < -1) ) begin
	   $display( "ERROR: intolerable difference");
       $stop();
	end
	
  end
  else begin
    $display("[iter=%d] OK: values match lht = %x, rht = %x, go=%b", i, lft_reg_sgex, rht_reg_sgex, go);
  end

  refptr = refptr + 1;
  i = i + 1;

  @(posedge clk);

end

/*-- IR Checker --*/
logic [2:0] channel_count;
assign channel_count = iDut.iCORE.iMotion.channel_cnt;
// Checker to make sure we are enabling and reading from the correct IR pair //
always@(posedge iDut.iCORE.iMotion.strt_cnv) begin: IR_en_checker
  case(channel_count[2:1])
    00: begin
	  if ((chnnl == 3'b001 || chnnl == 3'b000) && (IR_in_en == 1'b1))
	    ;
    	  else begin
	  	$display("ERROR! IR_en_checker failed for IR_in_en @ channel_count = %d\n", channel_count);
		$stop;
	  end
	end
    01: begin
	  if ((chnnl == 3'b010 || chnnl == 3'b100) && (IR_mid_en == 1'b1))
	    ;
    	  else begin
	  	$display("ERROR! IR_en_checker failed for IR_mid_en @ channel_count = %d\n", channel_count);
		$stop;
	  end
	end
    10: begin
	  if ((chnnl == 3'b011 || chnnl == 3'b111) && (IR_out_en == 1'b1))
	    ;
    	  else begin
	  	$display("ERROR! IR_en_checker failed for IR_out_eni @ channel_count = %d\n", channel_count);
		$stop;
	  end
	end
    11: begin
	  $display("ERROR! IR_en_checker failed as chnnl_cnt exceeded 5 @ channel_count = %d\n", channel_count);
	  $stop;
	end
    endcase
end // end of IR_en_checker
	    

// Init motion tb signals//
task init_motion;

  refptr = 0;
  i = 0;                 // trial number
  disable_motion_check = 0;	//motion checker enabled by default
  
endtask
  
