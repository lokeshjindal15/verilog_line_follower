/*
Author: Lokesh Jindal
e-mail: lokeshjindal15@cs.wisc.edu
Date:	March, 2015

Testbench Barcode reader for line follower robot
*/

module barcode_tb();

reg	clk, rst_n;

reg [21:0] period;  // inputs to the barcode_mimic
reg send;
reg [7:0] station_ID;

wire BC_done; // monitor when barcode_mimic done trasnferring station ID
wire link;  // connect BC output from barcode_mimic to barcode reader

barcode_mimic INJECTOR(
.clk(clk),
.rst_n(rst_n),
.period(period),
.send(send),
.station_ID(station_ID),
.BC_done(BC_done),
.BC(link)
);

wire ID_vld; // wire to monitor the ID_vld signal from barcode reader
reg clr_ID_vld; // input signal to knock down ID_vld
wire [7:0] ID_OUT;


barcode DUT(
.BC(link), 
.ID_vld(ID_vld), 
.ID(ID_OUT), 
.clr_ID_vld(clr_ID_vld), 
.clk(clk), 
.rst_n(rst_n)
);

// class definition for random testing
class stim_t;
	rand bit [7:0] cid;
	rand bit [21:0] cperiod;
	constraint id_valid{
	cid[7:6] == 2'b00;
	}
endclass

//generate clk
always
#10 clk = ~clk;

initial
begin
integer x=0;
stim_t stim;
stim = new();

period = 0;
send = 0;
station_ID = 0;
clr_ID_vld = 0;
rst_n = 0;
clk = 0;

// test that a valid ID gets read correctly
@(negedge(clk));
period = 600;
clr_ID_vld = 0;
station_ID = 16'h1A;
send = 1;
@(negedge(clk));
rst_n = 1;
repeat(10)@(negedge(clk));
send = 0;

@(posedge(BC_done));
$display("BC_done asserted by barcode_mimic! Now let's test out DUT\n");

repeat(10)@(negedge(clk));

if (ID_vld) 
begin
	$display("YAY! ID_vald has been asserted!\n");
end
else
begin
	$display("ERROR! ID_vld has not been asserted!\n");
	$display("TEST 1 FAILED!\n");
	$stop;
end

if (ID_OUT == 16'h1A)
begin
	$display("YO! ID has been received correctly!\n");
end
else
begin
	$display("ERROR! wrong ID:%h has been received!\n", ID_OUT);
	$display("TEST 1 FAILED!\n");
	$stop;
end

@(negedge(clk));
clr_ID_vld = 1;
repeat(10) @(negedge(clk));

if (!ID_vld)
begin
	$display("YO! When clr_ID_vld asserted, ID_vld has been de-asserted correctly!\n");
	$display("TEST 1 PASSED\n");
end
else
begin
	$display("ERROR! When clr_ID_vld asserted, ID_vld has not been de-asserted!\n");
	$display("TEST 1 FAILED!\n");
	$stop;
end

// test that an invalid ID (ID[7:6] != 0 )does not assert ID_vld signal
@(negedge(clk));
period = 1200;
clr_ID_vld = 0;
station_ID = 16'h8B;
@(negedge(clk));
send = 1;
repeat(10)@(negedge(clk));
send = 0;

@(posedge(BC_done));
$display("BC_done asserted by barcode_mimic! Now let's test out DUT\n");

repeat(10)@(negedge(clk));

if (ID_vld) 
begin
	$display("ERROR! ID_vald has been asserted for an invalid ID:%h!\n", station_ID);
	$display("TEST 2 FAILED!\n");
	$stop;
end
else
begin
	$display("YAY! ID_vld has not been asserted for an invalid ID:%h!\n", station_ID);
end

if (ID_OUT == 16'h8B)
begin
	$display("YO! ID has been received but was an invalid ID!\n");
	$display("TEST 2 PASSED!\n");
end
else
begin
	$display("ERROR! wrong ID:%h has been received!\n", ID_OUT);
	$display("TEST 2 FAILED!\n");
	$stop;
end

// now lets get nasty and test for a false start bit. we should time out...
// can be verified in waves if we go from WAIT_BC_NEGEDGE to IDLE
force link = 1'b0;
repeat(500) @(negedge(clk));

if (link == 1'b0)
begin
	; //don't do anything if zero
end
else
begin
	$display("ERROR! link not being forced to ZERO in nasty test!\n");
	$display("TEST3 FAILED!\n");
	$stop;
end

repeat(500) @(negedge(clk));
release link;

repeat(10) @(negedge(clk));
if (link == 1'b1)
begin
	; //don't do anything if ONE
end
else
begin
	$display("ERROR! link not being released to ONE in nasty test!\n");
	$display("TEST 3 FAILED!\n");
	$stop;
end

repeat(22'h3fffff) @(negedge(clk));
repeat(22'h0fff) @(negedge(clk));

if (ID_vld) 
begin
	$display("ERROR! ID_vald has been asserted for the false start bit in nasty test!\n");
	$display("TEST 3 FAILED!\n");
	$stop;
end
else
begin
	$display("YAY! ID_vld has not been asserted for flase start bit nasty test!\n");
	$display("TEST 3 PASSED\n");
end

// test that works with a very long period this is a very long running test...
@(negedge(clk));
period = 22'h2fffff;
clr_ID_vld = 0;
station_ID = 16'h0D;
send = 1;
@(negedge(clk));
rst_n = 1;
repeat(10)@(negedge(clk));
send = 0;

@(posedge(BC_done));
$display("BC_done asserted by barcode_mimic! Now let's test out DUT\n");

repeat(10)@(negedge(clk));

if (ID_vld) 
begin
	$display("YAY! ID_vald has been asserted!\n");
end
else
begin
	$display("ERROR! ID_vld has not been asserted!\n");
	$display("TEST 4 FAILED!\n");
	$stop;
end

if (ID_OUT == 16'h0D)
begin
	$display("YO! ID has been received correctly!\n");
end
else
begin
	$display("ERROR! wrong ID:%h has been received!\n", ID_OUT);
	$display("TEST 4 FAILED!\n");
	$stop;
end

@(negedge(clk));
clr_ID_vld = 1;
repeat(10) @(negedge(clk));

if (!ID_vld)
begin
	$display("YO! When clr_ID_vld asserted, ID_vld has been de-asserted correctly!\n");
	$display("TEST 4 PASSED\n");
end
else
begin
	$display("ERROR! When clr_ID_vld asserted, ID_vld has not been de-asserted!\n");
	$display("TEST 4 FAILED!\n");
	$stop;
end


// RANDOM TESTING
// lets do 20 transactions now
for (x = 0; x < 20; x++)
begin
	stim.randomize();
	@(negedge(clk));
	period = stim.cperiod;
	clr_ID_vld = 0;
	station_ID = stim.cid;
	send = 1;
	$display("RUNNING RANDOM TEST %d with period=22'h%h and id=8'h%h\n", x, period, station_ID);
	repeat(10)@(negedge(clk));
	send = 0;

	@(posedge(BC_done));
	$display("BC_done asserted by barcode_mimic! Now let's test out DUT\n");

	repeat(10)@(negedge(clk));

	if (ID_vld) 
	begin
		$display("YAY! ID_vald has been asserted!\n");
	end
	else
	begin
		$display("ERROR! ID_vld has not been asserted!\n");
		$display("RANDOM TEST %d FAILED!\n", x);
		$stop;
	end

	if (ID_OUT == station_ID)
	begin
		$display("YO! ID has been received correctly!\n");
	end
	else
	begin
		$display("ERROR! wrong ID:%h has been received!\n", ID_OUT);
		$display("RANDOM TEST %d FAILED!\n", x);
		$stop;
	end

	@(negedge(clk));
	clr_ID_vld = 1;
	repeat(10) @(negedge(clk));

	if (!ID_vld)
	begin
		$display("YO! When clr_ID_vld asserted, ID_vld has been de-asserted correctly!\n");
		$display("RANDOM TEST %d PASSED\n", x);
	end
	else
	begin
		$display("ERROR! When clr_ID_vld asserted, ID_vld has not been de-asserted!\n");
		$display("RANDOM TEST %d FAILED!\n", x);
		$stop;
	end
end // end of for loop for random tests

$display("YO! ALL TESTS PASSED!\n");
$stop;
end

endmodule

