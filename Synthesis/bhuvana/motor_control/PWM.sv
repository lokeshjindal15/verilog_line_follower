//////////////// PWM controller   		  ////////////////
/////////////// Author: Bhuvana Kakunoori ///////////////

module PWM(clk, rst_n, duty, PWM_sig);

input clk, rst_n;			// clk, async low reset
input [9:0] duty;			// Input duty value
output reg PWM_sig;			// Output PWM_sig

reg [9:0] cntr;				// 10 bit counter to count uptil 1024 cycles
reg set, reset;

/////////////// 10 bit Counter Logic ///////////////
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
      cntr <= 10'h000;
    else
      cntr <= cntr + 1;
end

/////////////// Logic to generate PWM signal. //////////////////
always @(cntr) begin
     if(&cntr[9:0]) begin 					// All ones? roll back output to 1
       set = 1;
       reset = 0;
     end
     else if(cntr[9:0] == duty[9:0]) begin	// After duty count cycles, set output to 0
       set = 0;
       reset = 1;
     end
end

////////////// Output PWM signal based on set, reset inputs /////////////

always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
      PWM_sig <= 1;
    else if(set)
      PWM_sig <= 1;
    else if(reset)
      PWM_sig <= 0;
    //Else retain the value
  end

endmodule