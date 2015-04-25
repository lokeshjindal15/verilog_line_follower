/*
Author: Lokesh Jindal
e-mail: lokeshjindal15@cs.wisc.edu
Date:	March, 2015

PWM generator module for line follower
*/

module pwm_gen (clk, duty, rst_n, pwm_sig);
//inputs
input	clk, rst_n;
//outputs
input	[9:0] duty;
output	reg pwm_sig;


reg	[9:0] count;		//counter to count upto "duty" number of cyles
reg 	set, reset;
wire	din;

always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		count <= 0;
	else
		count <= count + 1;
end

/*
generate the desired duty cycle
count until we reach "duty" number of cycles and then reset
set when the counte overflows - i.e. reaches 1024 cycles
*/
always@(duty or count)
begin
	set = 0;
	reset = 0;
	if (count == 10'b1111111111)
		set = 1;
	else if (duty == count)
		reset = 1;
end

assign din = set ? 1:
	     reset ? 0:
		pwm_sig;

//flop the final output
always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		pwm_sig <= 1;
	else
		pwm_sig <= din;
end

endmodule
