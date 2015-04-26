/*---------------------------------------------
  pwm_gen : - PWM signal generator
  
     inputs : duty[9:0] - duty cycle for pwm sig
	 Note: PWM signal is generated for 100% duty 
	 cycles but does not support 0 duty cycle
	 
	 -using Hoffmans PWM gen logic
----------------------------------------------*/

module  pwm_gen(clk, rst_n, duty, PWM_sig);

input clk, rst_n;
input [9:0] duty;       // duty cycle 0 is not really supported

output reg PWM_sig; 

wire cnt_all_ones, pwm_next;
wire pwmset, pwmreset;       // set or reset the PWM signal
reg [9:0] count;		         // base counter for PWM

/*--  duty cycle logic --*/
assign cnt_all_ones = &count;
assign pwmset   = cnt_all_ones;
assign pwmreset = (count == duty);

// note- priority for pwm set
assign pwm_next =  (pwmset)   ? 1'b1 : 
                   (pwmreset) ? 1'b0 :
                    PWM_sig;

/*-- PWM flop --*/
always @(posedge clk or negedge rst_n)
  if(!rst_n)
    PWM_sig <= 1'b1;   // reset to 1 (sorry no 0 duty cycle)
  else
    PWM_sig <= pwm_next;

/*-- base PWM 10 bit counter --*/
always @(posedge clk or negedge rst_n)
  if(!rst_n)
    count  <=  10'b0;
  else
    count  <=  count + 10'b1;

endmodule