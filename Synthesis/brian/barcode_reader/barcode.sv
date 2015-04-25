/*-----------------------------------------------------------
  Barcode Reader :
          Decode the barcode reciever signal to output the 
		  station id viz 8 bit ID
            
        input: BC - barcode signal from IR sensor (async) ,
		           clr_ID_vld: knock down valid flag
        output: ID[7:0], ID_vld received station id and valid flag

-------------------------------------------------------------*/

module barcode(clk, rst_n, BC, ID, ID_vld, clr_ID_vld);

input clk, rst_n;
input BC;                 // serial bit in
input clr_ID_vld;

output [7:0] ID;
output reg   ID_vld;         // indicate that the byte is ready


/*---
 Barcode reader: since we pick up the timing for sampling bits
    from the data signal itself, the reader operates two phases
       1 - calibrate phase: flop the timing info
       2 - sample phase: where we flop in the values using previous timer
       
  Broadly the receiver is architected using the following datapath components -

       a:- base counter + period reg: this both measures the time period and 
          and counts upto that value while reading the data.
          (this comes on to the timer_done signal)
       b:- bit counter : does book-keeping to let us know when we are done  
       c:- shift register :where we actually store the samples
       d:- edge-detector /intf: interface logic that also helps
              our state machine transitions 
           (use rising_edge and falling edge_signal)
  
  and part II we have the state machine and the external interface
        viz, ID vld and clear vld input
  
  change: made more robust
--*/

logic timer_en, timer_rst, save_time, data_rst, sample, set_vld_bit, clr_vld_bit;
reg BC_ff, BC_filtered;         // BC_filtered : BC value filtered for glitches (TBD)
reg [3:0] dff;                  // flops for glitch rejection
logic set_BC, clr_BC;           // glitch rejection logic

logic  byte_done, timer_done, rising_edge, falling_edge, timeout_sig;
logic  valid_bc;                // is this a valid bar code?
logic [21:0] time_cnt, time_prd;
logic [2:0]  bit_cnt;           // note**- we only have to count till 7 :)
logic [7:0]  bc_shift_reg;

typedef enum reg [1:0] {Idle, Calibrate, SampleWait, CountUp} state_t;
state_t  state, next_state;


/*-- time: counter --*/
assign  timer_done     = (time_cnt == time_prd) ? 1'b1 : 1'b0;
assign  timeout_sig    = (time_cnt == {time_prd[20:0], 1'b0}) ? 1'b1 : 1'b0; 
                      /*-- ^ reasonalbe timeout time : 2x time period  (hence  << 1) */

always_ff @(posedge clk) begin
  if(timer_rst)
    time_cnt  <=  22'h000000;
  else if(timer_en)
    time_cnt  <=  time_cnt + 1;
end

/* -- time period reg : flop timer value here --*/
always_ff @(posedge clk) begin
  if(save_time)
    time_prd  <=  time_cnt;
end

/*-- data shift register: here is where we save the samples over time  
    NOTE: need to shift in from the LSB, as MSB comes first --*/
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    bc_shift_reg  <=  8'h00;
  else if(sample)
    bc_shift_reg  <=  {bc_shift_reg[6:0], BC_filtered} ;        // left shift the received bits
end

assign ID = bc_shift_reg;
assign valid_bc = ~(|bc_shift_reg[6:5]);        // seems off by one bit, but we do check a cycle before
                                                // the last shift, hence 2 MSBs will be in 6:5

/*--  bit counter : our book-keeper --*/
assign  byte_done = (bit_cnt == 4'h7) ? 1'b1 : 1'b0;     // count all but one

always_ff @(posedge clk) begin
  if(data_rst)
    bit_cnt  <=  3'h0;
  else if(sample)
    bit_cnt  <=  bit_cnt + 3'h1;
end


/*--  And now part II - state-machine, edge i/f and status bits ---*/

/*--- the state machine: !!!--*/

always_comb begin
  timer_en  = 0;
  timer_rst = 0;
  save_time = 0;
  data_rst = 0;
  sample = 0;
  set_vld_bit = 0;
  clr_vld_bit = 0;
  next_state = Idle;
  
  case (state)
    Idle: 
      if(falling_edge) begin
        timer_rst = 1;
        data_rst = 1;
        clr_vld_bit = 1;
        next_state = Calibrate;
      end
    
    Calibrate:
      if(rising_edge) begin
        save_time = 1;
        timer_rst = 1;  // to enable timeout counting
        next_state = SampleWait;
      end
      else begin
        timer_en = 1;
        next_state = Calibrate;
      end
    
    SampleWait:
      if(falling_edge) begin
        timer_rst = 1;
        next_state = CountUp;
      end
      else if(timeout_sig)
        next_state = Idle;
      else begin
        timer_en = 1;	// count for timeout
        next_state = SampleWait;
        /*--TBD - extend for time out --*/
      end
      
    CountUp:
      if(timer_done) begin
        sample = 1;
        if(byte_done && valid_bc) begin
          set_vld_bit = 1;
          next_state = Idle;
        end 
        else if(byte_done && ~valid_bc)
          next_state = Idle;
        else begin
          timer_rst = 1;  // to enable timeout counting
          next_state = SampleWait;
        end
      end
      else begin
        timer_en = 1;
        next_state= CountUp;
      end
         
      default: next_state = Idle;
  endcase
end

/*-- state ff --*/
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    state <= Idle;
  else
    state <= next_state;
end

/*---part c) interface logic -- 
              to the outside world  --*/
              
/*-- noise rejection circuit:
       don't change BC till 3 samples agree 
     also we merge edge detection logic into
     this piece of logic               --*/

assign set_BC = (&dff[3:1]);
assign clr_BC = ~(|dff[3:1]);

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    dff         <= 4'b1111;
    BC_ff       <= 1'b1;	    //  for edge detection
    BC_filtered <= 1'b1;
  end
  else begin
    dff         <=  {dff[2:0], BC};
    BC_ff       <=  set_BC  ? 1'b1 :
                     clr_BC ? 1'b0 : BC_ff;
    BC_filtered <=  BC_ff;
  end
end

/*-- edge detection --*/
assign rising_edge  = (~BC_filtered) & BC_ff;
assign falling_edge = BC_filtered & ~BC_ff;
              
             
/*-- external status interface --*/
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    ID_vld <= 1'b0;
  else if(set_vld_bit)
    ID_vld <= 1'b1;
  else if(clr_ID_vld || clr_vld_bit)       // let the user device clear ID valid here
    ID_vld <= 1'b0;
end

   
endmodule
