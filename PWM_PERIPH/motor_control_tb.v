`timescale 1ns/1ps

module motor_control_tb();

reg clk, rst_n;
reg [10:0] lft, rht;

wire fwd_rht, fwd_lft, rev_rht, rev_lft;

motor_control motor_control_dut(
.clk(clk), 
.rst_n(rst_n),
.lft(lft), 
.rht(rht), 
.fwd_rht(fwd_rht), 
.fwd_lft(fwd_lft), 
.rev_rht(rev_rht),
.rev_lft(rev_lft)
);

initial
begin
clk = 0;
end

always
#5 clk = ~(clk);

initial
begin

rst_n = 0;

#1;

rst_n = 1;

lft = 100;
rht = -102;

end
endmodule
