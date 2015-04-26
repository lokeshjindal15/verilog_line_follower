////////////// Motor Controller 		///////////
////////////// Author: Bhuvana Kakunoori ///////////

module motor_cntrl(clk, rst_n, rht, lft, fwd_rht, fwd_lft, rev_rht, rev_lft);

  input clk, rst_n;							// clk, async low reset
  input signed [10:0] rht, lft;				// Signed input values to drive the direction and strength of motor
  
  output reg fwd_rht, fwd_lft, rev_rht, rev_lft;

  logic[9:0] mag_lft, mag_rht;				// Absolute Magnitude of input data
  logic sig_lft, sig_rht;					// PWM signals from the PWM modules

  //Instantiate the Left and the Right PWM here
  PWM PWM_lft(clk, rst_n, mag_lft, sig_lft);

  PWM PWM_rht(clk, rst_n, mag_rht, sig_rht);

  //Combinational logic to get absolute value of the input
  always_comb begin

    mag_rht = rht[10] ? -rht : rht;
    mag_lft = lft[10] ? -lft : lft;

  end

////////// Combinational logic to drive left motor ////////////////

	always_comb begin
  	  fwd_lft = 1;
	  rev_lft = 1;
  	  //All Zeros ? Push both outputs high
  	  if(!(|lft)) begin
		fwd_lft = 1;
        rev_lft = 1;
  	  end else if(lft[10]) begin	//MSB = 1 ? Go reverse
		fwd_lft = 0;
        rev_lft = sig_lft; 
  	  end else begin 				//MSB = 0 ? Go forward
		fwd_lft = sig_lft;
        rev_lft = 0;
  	  end

  	end

/////////// Combinational logic to drive right motor ////////////////

	always_comb begin
	  fwd_rht = 1;
      rev_rht = 1;
      //All Zeros ? Push both outputs high
	  if(!(|rht)) begin
    	fwd_rht = 1;
   		rev_rht = 1;
      end else if(lft[10])  begin	//MSB = 1 ? Go reverse
   		fwd_rht = 0;
   		rev_rht = sig_rht; 
	  end else begin				//MSB = 0 ? Go forward
	  	fwd_rht = sig_rht;
        rev_rht = 0;
      end
    end
 

endmodule
