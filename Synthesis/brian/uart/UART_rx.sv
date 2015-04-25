/*-----------------------------------------------------------
  UART Receiver :
          unserialize 8 bits received from a UART serial port
          -- simple receiver --
          
          (BUADC - set as per the diviisions between the
            baud rate and the clk freq, 
           BAUDCby2 - is just of baudcount-1)
            
        input: TX - serial input port
        output: cmd, rdy - output data and ready signal

-------------------------------------------------------------*/

module UART_rx(clk, rst_n, RX, cmd, rdy, clr_rdy);

input clk, rst_n;
input RX;                 // serial bits in
input clr_rdy;

output [7:0] cmd;
output reg   rdy;         // indicate that the byte is ready

localparam BAUDCby2 = 12'h515;
localparam BAUDC    = 12'hA2B;


/*--- UART receiver :   ok, we are not really counting past
    the start bit in our implementation, we first count 0.5 x
    the baud time and then start counting 1.0 x the baud time
    Did this because its easier to implement the sampling control
    this way - because if we count 1.5 x btime we end up crossing
    1.0 as well - got2 inihibit that signal the first time and all!
    
    ____       _____ _____ _______       __________
        \_____/_D0__\_D1__/\_D2__/ .... / Stop  
       t^  ^     |     |      |    ....   |
         0.5       1.0   1.0             
      We reset the baud counter for first time after a half cycle,
      then onwards reset it after full cycles, but we don't sample
      the first one- start bit.
     
The UART is architected in two major parts -  part a -
  3 counters 1- baud-counter gives the base rhythm for sampling RX
               (this goes on signal - sample)
             2- shift register - to shift in the data bits fortunately in LE
             3- bit counter maintains a global count of bits received
  
  and the second part is a state machine the manages the receiving process
   
   control signals - load, receiving.
   also manage our the rdy signale with the clr_rdy input -   ----*/

logic  load, sample, receiving, set_rdy_bit, clr_rdy_bit;
reg dff, RXsyn;        // RXSyn : synchronized input to our clk domain

logic  bits_done, baud_cnt_half;
logic [11:0] baud_cnt;
logic [3:0]  bit_cnt;
logic [8:0]  rx_shift_reg;

typedef enum reg [1:0] {Listen, PreCnt, Sample} state_t;
state_t  state, next_state;


/*-- baud counter --*/
assign  baud_cnt_half = (baud_cnt == BAUDCby2) ? 1'b1 : 1'b0;
assign  sample        = (baud_cnt == BAUDC) ? 1'b1 : 1'b0;

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    baud_cnt  <=  12'h000;    // ** got to reset this cause we don't wanna hit- sample accdently
  else if(load | sample) 
    baud_cnt  <=  12'h000;
  else if(receiving)
    baud_cnt  <=  baud_cnt + 12'h1;
end

/*-- data shift register: here is where we save the samples over time  
    NOTE: need to shift in from the MSB - 
    shifting in from the LSB will read things in reverse!---*/
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    rx_shift_reg  <=  9'b0;
  else if(sample)
    rx_shift_reg  <=  {RXsyn, rx_shift_reg[8:1]};        // right shift the received bits
end

assign  cmd = rx_shift_reg[7:0];  


/*--  bit counter : our book-keeper --*/
assign  bits_done = (bit_cnt == 4'h9) ? 1'b1 : 1'b0;  // till we count 9 bits - we don't count the start

always_ff @(posedge clk) begin
  if(load)
    bit_cnt  <=  4'h0;
  else if(sample)
    bit_cnt  <=  bit_cnt + 4'h1;
end


/*--  And now part b - state-machine and a status bit ---*/

/*--- the state machine: we need an intermediate state 'PreCnt' to 
      get past the first half cycle, during the transition we
      assert load to reset the baud counter. This resets the
      bit counter but that's fine,
         The SM adds a little noise detection on the start bit, 
      so it resets on small 0 blips. Its not fully noise robust --*/

always_comb begin
  load = 0;
  receiving = 0;
  set_rdy_bit = 0;
  clr_rdy_bit = 0;
  next_state = Listen;
  
  case (state)
    Listen: 
      if(!RXsyn) begin             // detect the start bit
        load = 1;
        next_state = PreCnt;
      end
    
    PreCnt:
      if(RXsyn)
        next_state = Listen;      // avoid noisy start bit
      else if(baud_cnt_half) begin
        load = 1;
        clr_rdy_bit = 1;          // clear the ready bit as we know a new valid transmission
        next_state = Sample;
      end
      else begin
        receiving = 1;            // to enable baud counter to run
        next_state = PreCnt;
      end
      
    Sample:
      if(bits_done) begin
        set_rdy_bit = 1;
        next_state = Listen;
      end
      else begin
        receiving = 1;
        next_state = Sample;
      end

      default: next_state = Listen;
  endcase
end

/*-- state ff --*/
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    state <= Listen;
  else
    state <= next_state;
end

/*---part c) interface logic -- 
              to the outside world  --*/
/*-- external status interface --*/
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    rdy <= 1'b0;
  else if(set_rdy_bit)
    rdy <= 1'b1;
  else if(clr_rdy_bit || clr_rdy)       // let the user device clear ready here
    rdy <= 1'b0;
end

/*-- double flop input - --*/
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    dff   <= 1'b1;
    RXsyn <= 1'b1;
  end
  else begin
    dff   <= RX;
    RXsyn <= dff;
  end
end
    
endmodule
