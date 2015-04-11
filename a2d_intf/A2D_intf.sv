/*
Author: Lokesh Jindal, Brian Coutinho
e-mail: lokeshjindal15@cs.wisc.edu, bcoutinho@wisc.edu
Date:	APril 10, 2015

motor control module for line follower
*/

module A2D_intf (clk, rst_n, strt_cnv, cnv_cmplt, chnnl, res, a2d_SS_n, SCLK, MOSI, MISO);

input clk, rst_n;
input strt_cnv;
input [2:0] chnnl; 

output [11:0] res; // A2D converted value communicated by the A2D slave

/*-- SPI interface to/from a2d--*/
output SCLK;
input MISO;
output reg MOSI;
output reg a2d_SS_n;

output reg cnv_cmplt;

reg [4:0] sclk_counter;                   // counter for SCLK generation
logic load, en_sclk_cnt, shift;           // control signals
logic set_cnv_cmplt;

logic [5:0] bit_counter;
logic [15:0] shift_reg;

logic bit_cnt_33;

/*-- 5-bit counter to generate SCLK --*/
always_ff @(posedge(clk) or negedge(rst_n))
if (!rst_n)
  sclk_counter <= 5'b10000; 
else if (load)
  sclk_counter <= 5'b10000;
else if (en_sclk_cnt)
  sclk_counter <= sclk_counter + 1;

// assign sclk
assign SCLK =  sclk_counter[4];
 
// generate shift signal when sclk_counter reaches 30
// want to shift out MOSI one cycle before SCLK negedge which happens at sclk_counter 31
// so we asssert shift one cycle before that
assign shift = (sclk_counter == 5'b11110) ? 1 : 0;
       

/*-- 6-bit counter to track number of bits that have been shifte in/out --*/
always_ff @(posedge(clk))
if (load)
  bit_counter <= 6'b000000;
else if (shift)
  bit_counter <= bit_counter + 1;

// generate the bit_cnt_33 signal
assign bit_cnt_33 = (bit_counter == 6'd33) ? 1 : 0;   //-- we end up with one extra shift in our design -
                                                      //   so count a extra shift to receive MISO correctly


/*-- shift register at the A2D interface --*/
always_ff @(posedge(clk))
if (load)
  shift_reg <= {2'b00, chnnl[2:0], 11'h000};
else if (shift)
  shift_reg <= {shift_reg[14:0], MISO};

// a2d value relayed on res signal
assign  res = shift_reg[11:0];

// flop for holding the MOSI o/p
always_ff@(posedge(clk) or negedge(rst_n))
if (!rst_n)
  MOSI <= 1'b0;
else if (shift)
  MOSI <= shift_reg[15];

  
/*----- FSM for SPI interface -------*/
typedef enum reg {IDLE, SAMPLING} state_t;
state_t state, nxt_state;

always_comb 
begin
load = 1'b0;
en_sclk_cnt = 1'b0;
nxt_state = IDLE;
a2d_SS_n = 1;
set_cnv_cmplt = 0;

  case(state)
  IDLE: // wait in this until you receive strt_cnv signal
      if (strt_cnv) begin
        load = 1;
        a2d_SS_n = 0;
        nxt_state = SAMPLING;
      end
  
  SAMPLING: 
      if (bit_cnt_33) begin
        set_cnv_cmplt = 1;
        nxt_state = IDLE;
      end
      else begin
        a2d_SS_n = 0;
        en_sclk_cnt = 1;
        nxt_state = SAMPLING;
      end
      
  default:
      nxt_state = IDLE;      
  endcase
end

// state flop
always_ff @(posedge(clk) or negedge(rst_n))
  if(!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;

// conversion cmplt interface
always_ff @(posedge(clk) or negedge(rst_n))
  if(!rst_n)
    cnv_cmplt <=  1'b0;
  else if(set_cnv_cmplt)
    cnv_cmplt <=  1'b1;
  else if(strt_cnv)
    cnv_cmplt <=  1'b0;
      
      
endmodule

  
