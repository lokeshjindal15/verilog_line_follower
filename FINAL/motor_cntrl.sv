/*-------------------------------------------------------

  Motor controller- aka  PWM Peripheral block:
     This blocks converts our speed commands into
     signals that are actually understood by our motor
    
  Inputs : 
    lft[10:0], rht[10:0] - signed speed control for the
                two motors
          if lft = 0  or rht = 0 - brake the motors
          
  Outputs :
    fwd,rev - _lft,_rgt : a pair of signals for both motors
    
---------------------------------------------------------*/
 
module motor_cntrl(clk, rst_n, lft, rht, fwd_lft, rev_lft, fwd_rht, rev_rht);

input clk, rst_n;
input [10:0] lft, rht;
 
output fwd_lft, fwd_rht, rev_lft, rev_rht;
 
wire [9:0] mag_lft, mag_rht;   // absolute values to our pwm gen blocks
wire  pwm_lft, pwm_rht, brake_lft, brake_rht;
 
 /*-- absolute values --*/
assign  mag_lft = (lft[10]) ?   (|lft[9:0] ? (~lft[9:0] + 10'b1) : (10'b11_1111_1111))  :  
				lft[9:0];

assign  mag_rht = (rht[10]) ?   (|rht[9:0] ? (~rht[9:0] + 10'b1) : (10'b11_1111_1111)) 	:  
				rht[9:0];

/* -- get PWM signals  --*/
pwm_gen iPwmlft(.clk(clk), .rst_n(rst_n), .duty(mag_lft), .PWM_sig(pwm_lft));
pwm_gen iPwmrht(.clk(clk), .rst_n(rst_n), .duty(mag_rht), .PWM_sig(pwm_rht));

/*-- Motor -controls 
    -> to get the motors to drive fwd - set the PWM signal
         on the fwd line and 0 on the rev line
    -> to drive reverse - PWM signal is driven on the rev lin
          and 0 on the fwd line
    --- to brake drive both at 1
---*/

assign brake_lft = ~( |lft[10:0]);    // lft == 0
assign brake_rht = ~( |rht[10:0]);    // rht == 0

/*-- mux correct waveform to fwd and rev controls --*/
assign  fwd_lft =  brake_lft  |  ((lft[10]) ? 1'b0    : pwm_lft);
assign  rev_lft =  brake_lft  |  ((lft[10]) ? pwm_lft : 1'b0   );

assign  fwd_rht =  brake_rht  |  ((rht[10]) ? 1'b0    : pwm_rht);
assign  rev_rht =  brake_rht  |  ((rht[10]) ? pwm_rht : 1'b0   );

endmodule
