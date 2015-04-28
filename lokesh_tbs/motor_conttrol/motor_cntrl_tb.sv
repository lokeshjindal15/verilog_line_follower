`timescale 1ns/1ps

module motor_control_tb();

reg clk, rst_n;
reg [10:0] lft, rht;

wire fwd_rht, fwd_lft, rev_rht, rev_lft;

motor_cntrl motor_control_dut(
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

@(negedge clk);
rst_n = 0;
@(negedge clk); rst_n= 1;

@(negedge clk);
@(negedge clk);

//Test 1 both +ve
lft = 124;
rht = 124;
repeat(100) @(negedge clk);
if ((fwd_rht != 1'b1) || (fwd_lft != 1'b1))
	begin
	$display("Test1: FAIL fwd channels wrong\n");
	$stop;
	end

if ((rev_rht != 1'b0) || (rev_lft != 1'b0))
	begin
	$display("Test1: FAIL rev channels wrong\n");
	$stop;
	end

$display("Test1: PASSED!\n");
repeat(924) @(negedge clk);

//Test 2 both lft +ve rht -ve
lft = 124;
rht = -124;
repeat(100) @(negedge clk);
if ((fwd_rht != 1'b0) || (fwd_lft != 1'b1))
	begin
	$display("Test2: FAIL fwd channels wrong\n");
	$stop;
	end

if ((rev_rht != 1'b1) || (rev_lft != 1'b0))
	begin
	$display("Test2: FAIL rev channels wrong\n");
	$stop;
	end

$display("Test2: PASSED!\n");
repeat(924) @(negedge clk);

//Test 3 rht +ve lft -ve
lft = -124;
rht = 124;
repeat(100) @(negedge clk);
if ((fwd_rht != 1'b1) || (fwd_lft != 1'b0))
	begin
	$display("Test1: FAIL fwd channels wrong\n");
	$stop;
	end

if ((rev_rht != 1'b0) || (rev_lft != 1'b1))
	begin
	$display("Test3: FAIL rev channels wrong\n");
	$stop;
	end

$display("Test3: PASSED!\n");
repeat(924) @(negedge clk);

//Test 4 both -ve
lft = -124;
rht = -124;
repeat(100) @(negedge clk);
if ((fwd_rht != 1'b0) || (fwd_lft != 1'b0))
	begin
	$display("Test4: FAIL fwd channels wrong\n");
	$stop;
	end

if ((rev_rht != 1'b1) || (rev_lft != 1'b1))
	begin
	$display("Test4: FAIL rev channels wrong\n");
	$stop;
	end

$display("Test4: PASSED!\n");
repeat(924) @(negedge clk);

//Test 5 both 0
lft = 0;
rht = 0;
repeat(100) @(negedge clk);
if ((fwd_rht != 1'b1) || (fwd_lft != 1'b1))
	begin
	$display("Test5: FAIL fwd channels wrong\n");
	$stop;
	end

if ((rev_rht != 1'b1) || (rev_lft != 1'b1))
	begin
	$display("Test5: FAIL rev channels wrong\n");
	$stop;
	end

$display("Test5: PASSED!\n");
repeat(924) @(negedge clk);

$display("YO! ALL 5 TESTS PASSED\n");
$stop;
	
end
endmodule

