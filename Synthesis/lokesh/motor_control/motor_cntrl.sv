/*
Author: Lokesh Jindal
e-mail: lokeshjindal15@cs.wisc.edu
Date:	March, 2015

motor control module for line follower
*/

module motor_cntrl(clk, rst_n, lft, rht, fwd_rht, fwd_lft, rev_rht,rev_lft);

//inputs
input clk, rst_n;
input [10:0] lft, rht;
//outputs
output wire fwd_rht, fwd_lft, rev_rht, rev_lft;

wire [9:0] mag_lft, mag_rht;		//10 bit |magnitude| to be used as duty cycle

wire lft_pwm_sig, rht_pwm_sig;		//pwm signal for right and left motors

wire lft_all_zeros, rht_all_zeros;	//signal to check if all zeros

//calculate the 10-bit magnitude and use this as duty input to pwm_gen
assign mag_lft = !(lft[10]) ? lft[9:0]:
					(~lft[9:0] + 1);

assign mag_rht = !(rht[10]) ? rht[9:0]:
					(~rht[9:0] + 1);

pwm_gen pwm_gen_lft(
.clk(clk),
.duty(mag_lft),
.rst_n(rst_n),
.pwm_sig(lft_pwm_sig)
);

pwm_gen pwm_gen_rht(
.clk(clk),
.duty(mag_rht),
.rst_n(rst_n),
.pwm_sig(rht_pwm_sig)
);

assign lft_all_zeros = (lft == 11'b00000000000);
assign rht_all_zeros = (rht == 11'b00000000000);

/*
A zero value indicates that we are braking. Drive 1 on both "rev" and "fwd" of the motor.
A negative value indicates that we want to drive the motor in reverse direction
- so route the pwm_sig on "rev" and drive zero on the fwd signal
Do the opposite when the 11-bit value is +ve
*/
assign	fwd_lft = 	lft_all_zeros ? 1'b1 :
					!lft[10] ? lft_pwm_sig:
					1'b0;

assign	rev_lft = 	lft_all_zeros ? 1'b1 :
					lft[10] ? lft_pwm_sig:
					1'b0;

assign	fwd_rht = 	rht_all_zeros ? 1'b1 :
					!rht[10] ? rht_pwm_sig:
					1'b0;

assign	rev_rht = 	rht_all_zeros ? 1'b1 :
					rht[10] ? rht_pwm_sig:
					1'b0;

endmodule


