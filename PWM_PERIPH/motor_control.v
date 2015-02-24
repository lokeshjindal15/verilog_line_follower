module motor_control(clk, rst_n, lft, rht, fwd_rht, fwd_lft, rev_rht,rev_lft);

input clk, rst_n;
input [10:0] lft, rht;

output wire fwd_rht, fwd_lft, rev_rht, rev_lft;

wire [9:0] mag_lft, mag_rht;

assign mag_lft = !(lft[10]) ? lft[9:0]:
					(~lft[9:0] + 1);

assign mag_rht = !(rht[10]) ? rht[9:0]:
					(~rht[9:0] + 1);

wire lft_pwm_sig, rht_pwm_sig;

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

assign	fwd_lft = !lft[10] ? lft_pwm_sig:
										1'b0;

assign	rev_lft = lft[10] ? lft_pwm_sig:
									1'b0;

assign	fwd_rht = !rht[10] ? rht_pwm_sig:
										1'b0;

assign	rev_rht = rht[10] ? rht_pwm_sig:
									1'b0;

endmodule

