// Testbench for A2D interface

module A2D_tb();

logic clk, rst_n;
logic strt_cnv, cnv_cmplt, a2d_SS_n, MOSI, MISO;

reg[2:0] chnnl;
reg[11:0] res;

reg[14:0] count;
reg [11:0] A2D_mem[0:65535];
	
//Initialize the A2D interface
A2D_intf intf_DUT(.clk(clk), .rst_n(rst_n), .strt_cnv(strt_cnv), .cnv_cmplt(cnv_cmplt), 
						.chnnl(chnnl), .res(res), .a2d_SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));


//Initialize the ADC128S module
ADC128S A2D_DUT(.clk(clk), .rst_n(rst_n), .SS_n(a2d_SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));

///////// Initialize the input values  /////////////////
initial begin
rst_n = 0;
clk = 0;
strt_cnv = 0;
chnnl = 0;

$readmemh("analog.dat",A2D_mem);		// read the analog data

end

///////// Self-triggering clock signal of 2 ns //////////
always @(clk) #10 clk <= ~clk;

////////// Change the channel and start conversion
initial begin
		repeat (5)@(posedge clk);
		// Bring the DUTs out of reset
		@(negedge clk) rst_n = 1;
		repeat (5)@(posedge clk);

		for(count = 0; count < 8000; count = count + 1) begin
				// Assert strt_cnv
				@(posedge clk) strt_cnv = 1;
				@(posedge clk) strt_cnv = 0;
				// Wait for cnv to complete
				while(!cnv_cmplt) ;
				// Check if the value is correct. Not sure how to do this yet
				$display("Count:%d chnnl:%d Value: %h", count, chnnl, res);
				$stop;
				// Increment channel and test again
				//chnnl = chnnl + 1;			
		end
		
end

endmodule