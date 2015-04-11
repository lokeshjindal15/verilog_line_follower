// Testbench for A2D interface

module A2D_tb();

logic clk, rst_n;
logic strt_cnv, cnv_cmplt, a2d_SS_n, MOSI, MISO;

reg[2:0] chnnl;
reg[11:0] res;
reg[11:0] expected_res;

reg[14:0] count;
reg [11:0] A2D_mem[0:65535];
	
//Initialize the A2D interface
A2D_intf intf_DUT(.clk(clk), .rst_n(rst_n), .strt_cnv(strt_cnv), .cnv_cmplt(cnv_cmplt), 
						.chnnl(chnnl), .res(res), .a2d_SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));


//Initialize the ADC128S module
ADC128S A2D_Model(.clk(clk), .rst_n(rst_n), .SS_n(a2d_SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));

///////// Initialize the input values  /////////////////
initial begin
rst_n = 0;
clk = 0;
strt_cnv = 0;
chnnl = 1;
expected_res = 0;

$readmemh("analog.dat",A2D_mem);		// read the analog data

end

///////// Self-triggering clock signal of 2 ns //////////
always 
#10 clk = ~clk;

// get the expected result from the model
always @(posedge(A2D_Model.ld_shft_reg))
expected_res <= A2D_Model.shft_data[11:0];

////////// Change the channel and start conversion
initial begin
		repeat (5)@(posedge clk);
		// Bring the DUTs out of reset
		@(negedge clk) rst_n = 1;
		repeat (5)@(posedge clk);

    // can't do more than 360 values since memory has Xs beyond that. analog.dat has only 2880/8 = 360 sets of values - each set has 8 sensor readings
		for(count = 0; count < 360; count = count + 1) begin
        
        // pick random channel and test
				chnnl = $random % 6 ;
        
				// Assert strt_cnv
				@(posedge clk) strt_cnv = 1;
				@(posedge clk) strt_cnv = 0;
				
        // Wait for cnv to complete
				@(posedge cnv_cmplt);
				
        // Check if the value is correct. 
        if(res == expected_res)
          $display("OK: Count:%d chnnl:%d  Expected: %h , Got Value: %h", count, chnnl, expected_res, res);
        else begin
          $display("ERROR:!! Count:%d chnnl:%d  Expected: %h , Got Value: %h", count, chnnl, expected_res, res);
          $stop();
        end
        
					
		end
	
  $display("Yo yo!!, ALL TESTS PASSED :) \n");
  $stop();
end

endmodule