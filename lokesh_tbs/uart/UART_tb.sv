/*
Author: Lokesh Jindal
e-mail: lokeshjindal15@cs.wisc.edu
Date:	March, 2015

Testbench for UART module for line follower
*/
module uart_tb();

reg	clk, rst_n, trmt;
reg	[7:0] tx_data;
wire	TX, tx_done;

wire rdy;
wire [7:0]cmd ;
reg clr_rdy;//additional recver outputs/inputs

uart_trans INJECTOR(
.clk(clk), 
.rst_n(rst_n), 
.trmt(trmt), 
.tx_data(tx_data), 
.TX(TX), 
.tx_done(tx_done)
);

UART_rx DUT(
.clk(clk), 
.rst_n(rst_n), 
.clr_rdy(clr_rdy), 
.RX(TX), 
.rdy(rdy),
.cmd(cmd));

initial
begin
clk = 0;
clr_rdy = 0;
end

always
#10 clk = ~clk;

initial
begin
	rst_n = 0;
	trmt = 0;
	@(negedge(clk));
	rst_n = 1;
	
//testing for all possible values and not using clr_rdy interface
for ( tx_data = 0; tx_data < 8'b11111111; tx_data = tx_data + 1)
begin	

	trmt = 1;
	repeat(10)@(negedge clk);
	trmt = 0;
	repeat(26040) @(negedge(clk));//2604 BAUD_CYCLES * 10 bits

	
	if (rdy)
		begin
		$display("FOR1 Iteration:%d PARTIAL SUCCESS! Some value has been recved:%b\n",tx_data, cmd);
		if(cmd == tx_data)
			begin
			$display("FOR1 Iteration:%d COMPLETE SUCCESS! Transmitted value has been correctly recved\n", tx_data);
			end
		else
			begin
			$display("FOR1 Iteration:%d FAIL! Wrong value has been recved\n", tx_data);
			$stop;
			end
		end
	else
		begin
		$display("FOR1 Iteration:%d FAIL! No value has been recved as rdy not asserted:%b\n",tx_data, cmd);
		$stop;
		end
		
end//end of for loop 1
	$display("Yo! ALL TESTS of PART 1 of 2 PASSED!\n");
	
//testing with clr_rdy protocol after every "cmd" has been formed	
for ( tx_data = 0; tx_data < 8'b11111111; tx_data = tx_data + 1)
begin	
	clr_rdy = 0 ;
	@(negedge clk);
	trmt = 1;
	repeat(10)@(negedge clk);
	trmt = 0;
	repeat(26040) @(negedge(clk));//2604 BAUD_CYCLES * 10 bits

	
	if (rdy)
		begin
		$display("FOR2 Iteration:%d PARTIAL SUCCESS! Some value has been recved:%b\n",tx_data, cmd);
		if(cmd == tx_data)
			begin
			$display("FOR2 Iteration:%d COMPLETE SUCCESS! Transmitted value has been correctly recved\n", tx_data);
			end
		else
			begin
			$display("FOR2 Iteration:%d FAIL! Wrong value has been recved\n", tx_data);
			$stop;
			end
		end
	else
		begin
		$display("FOR2 Iteration:%d FAIL! No value has been recved as rdy not asserted:%b\n",tx_data, cmd);
		$stop;
		end
		
	repeat (10) @(negedge(clk));

	clr_rdy = 1; 
	repeat (5) @(negedge(clk));
	if (rdy)
		begin
		$display("FOR2 Iteration:%d ERROR! rdy signal not de-asserted even after clr_rdy signalled\n", tx_data);
		$stop;
		end
	else
		begin
		$display("FOR2 Iteration:%d TEST PASSED!\n", tx_data);
		end

end//end of for loop 2
	$display("Yo! ALL TESTS FOR BOTH PARTS PASSED!\n");
	
	$stop;
	
end

endmodule

