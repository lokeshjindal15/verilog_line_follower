/*--------------------------------------
  rst_synch : reset synchroniser 
    to de-assert rest at the neg edge of clk
            RST_n  RST_n
       1'b1 -->  q   -->  rst_n
   neg edge ff       ff

 ---------------------------------------*/
 
 module rst_synch(clk, RST_n, rst_n);
 
 input   clk, RST_n;  //RST_n : is the analog input reset
 output  rst_n;
 
 reg  q1, q2;
  
 always @(negedge clk or negedge RST_n)
   if(!RST_n) begin
      q1 <= 1'b0;
      q2 <= 1'b0;
    end
    else begin
      q1 <= 1'b1;
      q2 <= q1;
    end
 
 assign rst_n = q2;
 
 endmodule