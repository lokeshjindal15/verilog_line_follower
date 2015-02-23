module pwm_gen (clk, duty, rst_n, pwm_sig);

input	clk, rst_n;
input	[9:0] duty;
output	reg pwm_sig;


reg	[9:0] count;
reg 	set, reset;
wire	din;

always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		count <= 0;
	else
		count <= count + 1;
end

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

always@(posedge(clk) or negedge(rst_n))
begin
	if (!rst_n)
		pwm_sig <= 1;
	else
		pwm_sig <= din;
end

endmodule
