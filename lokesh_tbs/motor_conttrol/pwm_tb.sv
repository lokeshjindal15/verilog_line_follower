/*
Author: Lokesh Jindal
e-mail: lokeshjindal15@cs.wisc.edu
Date:	March, 2015

Testbench for PWM module for line follower
*/

`timescale 1ns/1ps

module pwm_tb();

reg _clk, _rst_n;
reg [9:0] _duty;
wire _pwm_sig;

reg _rst_test_cnt;


reg [10:0]_test_count, high_count, total_count;

pwm_gen gen_dut(
.clk(_clk),
.duty(_duty),
.rst_n(_rst_n),
.PWM_sig(_pwm_sig)
);

initial
begin
_clk = 0;
end

always
#5 _clk = ~(_clk);


always@(posedge(_clk) or posedge(_rst_test_cnt))
begin
	if (_rst_test_cnt)
		_test_count <= 0;
	else
		_test_count <= _test_count + 1;
end

always@(negedge(_pwm_sig))
high_count <= _test_count;

always@(posedge(_pwm_sig))
begin
total_count <= _test_count;
$strobe("PWM_SIG: duty=%d high_count=%d total_count=%d\n", _duty, high_count, total_count);
end

always@(total_count)
begin
if ((high_count == (_duty + 1)) && (total_count == 1024))
$display("PASSED duty=%d high_count=%d total_count=%d\n", _duty, high_count, total_count);
else
$display("FAILED duty=%d high_count=%d total_count=%d\n", _duty, high_count, total_count);
end

initial
begin
//_rst_n = 0;
//_rst_test_cnt = 1;
//#1
//_rst_test_cnt = 0;
///_rst_n = 1;
//_duty = 100;
//#10
_rst_n = 0;
_rst_test_cnt = 1;
#10
_rst_n = 1;
_rst_test_cnt = 0;
for (_duty = 2; _duty < 10'b1111111110; _duty = _duty + 1)
//for (_duty = 2; _duty < 10'b0000000110; _duty = _duty + 1)
	begin
	//#1000;
	#10245;//wait for 10240+ns
	_rst_test_cnt = 1;
_rst_n = 0;
	#1;
	_rst_test_cnt = 0;
_rst_n = 1;
	end


$display("YAY!! ALL TESTS PASSED!");
$stop;
end


endmodule


