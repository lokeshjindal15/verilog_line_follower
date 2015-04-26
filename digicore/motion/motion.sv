/*
Author: Lokesh Jindal, Brian Coutinho
e-mail: lokeshjindal15@cs.wisc.edu, bcoutinho@wisc.edu
Date:	April 22, 2015

ECE551

Motion Control : this block handles reading the IR sensors and 
                  basically crunched out the PI math.
           It maintains both the motor magnitude and bias from the PI caclucations
            (ultimately this is in control of the bots motion)
     Duties: 1- when go=1 , read the IR sensors and 
             2- when go=0 ensure that motors go in braking mode
*/

module motion (clk, rst_n, A2D_res, cnv_cmplt, go, chnnl, strt_cnv, 
                IR_in_en, IR_mid_en, IR_out_en, lft_reg, rht_reg );

 input clk, rst_n;
 input [11:0] A2D_res;		// result of A2D conversion of IR sensor
 input cnv_cmplt;			    // indicates A2D conversion is ready
 input go;                // go: the overall control that we can proceed for PI math : from the cmd_intf block

 /*-- controls to A2D intf -*/
 output logic [2:0] chnnl;        // chnnl number to read
 output logic strt_cnv;					      	// used to initiate a Round Robing conversion on IR sensors
 output logic IR_in_en,IR_mid_en,IR_out_en; 	// PWM based enables to various IR sensors
  
 output reg [11:0] lft_reg,rht_reg;	   // 12-bit signed left and right motor controls
 
 
 ////////  PI MATH CONSTANTS  ///////////
 parameter PTERM_CONST = 14'h3680;
 parameter ITERM_CONST = 12'h500;
 
 
 /*-- timers for IR reading -*/
 logic [11:0] ir_timer;
 logic [2:0]  channel_cnt;    // internal channel counter
 logic [1:0]  intgdec;        // integral decimator!
 
 logic reset_timer, en_timer, timer_4095, timer_32;
 logic inc_intgdec, inc_channel_cnt, reset_channel_cnt;
 logic update_IR_en, clear_IR_all;
 
 /* -- ALU registers  --*/
 logic [15:0]  Accum, Pcomp;           // full width
 logic [13:0]  Pterm;                  //  constant PTerm
 logic [11:0]  Fwd;                    // Fwd speed
 logic [11:0]  Error, Intgrl, Icomp, Iterm;   // signed
 
 logic [15:0]  dst;                    // alu output

 /*-- signal encoding --*/
 typedef enum reg [2:0] {A2DRESIN0 = 0, INTGRLIN0, ICOMPIN0, PCOMPIN0, PTERMIN0}  src0select_t;
 typedef enum reg [2:0] {ACCUMIN1 = 0, ITERMIN1, ERRORIN1, ERRORSCALEIN1, FWDIN1} src1select_t;
 
 logic multiply, sub, mult2, mult4, saturate;
 src0select_t src0sel;
 src1select_t src1sel;
 
 /*-- update signals --*/
 logic rstaccum, dst2accum, dst2error, dst2intgrl, dst2icomp, dst2pcomp;
 logic dst2lft, dst2rht;
 
 ///////////////////////////////////////////////
 /*--- Instantiate ALU ---*/
 ///////////////////////////////////////////////
 alu iALU( .Accum(Accum), .Pcomp(Pcomp), .Pterm(Pterm), 
           .Fwd(Fwd), .A2D_res(A2D_res), .Error(Error),
           .Intgrl(Intgrl), .Icomp(Icomp), .Iterm(Iterm), .dst(dst),
           .multiply(multiply), .sub(sub), .mult2(mult2), .mult4(mult4),
           .saturate(saturate), .src1sel(src1sel), .src0sel(src0sel) );
 
 ///////////////////////////////////////////////
 /*--- ALU Logic ---*/
 ///////////////////////////////////////////////
 
  /*-- constant values --*/
 assign Pterm = PTERM_CONST;
 assign Iterm = ITERM_CONST;
 
 /*-- Value regs !! --*/
 always_ff @(posedge clk or negedge rst_n)
  if(!rst_n)
    Accum  <=  16'h0000;
  else if(rstaccum)
    Accum  <=  16'h0000;
  else if(dst2accum)
    Accum  <=  dst;   // 16 bit result
 
 always_ff @(posedge clk )
  if(dst2error)
    Error  <=  dst[11:0];
 
 always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    Intgrl <= 0;
 else  if(dst2intgrl)
    Intgrl <=  dst[11:0]; 

 always_ff @(posedge clk )
  if(dst2icomp)
    Icomp  <=  dst[11:0]; 
    
 always_ff @(posedge clk )
  if(dst2pcomp)
    Pcomp  <=  dst;  // 16 bit result
  
 ///////////////////////////////////////////////
 /*--- Motor Speed Controls---*/
 ///////////////////////////////////////////////

 /*-- Forward speed control -- 
       -- coutesy Hoffmans code in spec --*/
 always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    Fwd <= 12'h000;
  else if (!go)             // if go deasserted Fwd knocked down so
    Fwd <= 12'b000;         // we accelerate from zero on next start.
  else if (dst2intgrl & ~&Fwd[10:8]) // 43.75% full speed
    Fwd <= Fwd + 1'b1;      // only write back 1 of 4 calc cycles 
  
  
  /*-- Left and Right Motor controls --*/
  
 always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    rht_reg <= 12'h000;
  else if (!go)
    rht_reg <= 12'h000;
  else if (dst2rht)
    rht_reg <= dst[11:0];
 
 always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    lft_reg <= 12'h000;
  else if (!go)
    lft_reg <= 12'h000;
  else if (dst2lft)
    lft_reg <= dst[11:0];

 ///////////////////////////////////////////////
 /*--- Miscellaneous timer logic ---*/
 ///////////////////////////////////////////////
 /*-- enables for IR sensors --*/
 always_ff @(posedge clk or negedge rst_n)  begin
 if (!rst_n) begin
  IR_in_en <= 0;
  IR_mid_en <= 0;
  IR_out_en <= 0;
  end
  
  else if (clear_IR_all) begin
    IR_in_en <= 0;
    IR_mid_en <= 0;
    IR_out_en <= 0;
  end
    
  else if (update_IR_en) begin
    /*-- one hot encoding based on channel_cnt -*/
    case(channel_cnt[2:1])
        00: {IR_out_en, IR_mid_en, IR_in_en} <= 3'b001;
        01: {IR_out_en, IR_mid_en, IR_in_en} <= 3'b010;
        //10: {IR_out_en, IR_mid_en, IR_in_en} <= 3'b100;
        default: {IR_out_en, IR_mid_en, IR_in_en} <= 3'b100;
    endcase
    end
  end // end of always_ff 
        
 /*-- timer for IR sesnor reading --*/
 always_ff @(posedge clk)
  if(reset_timer)
    ir_timer  <=  12'h000;
  else if(en_timer)
    ir_timer  <=  ir_timer + 1;
 
 assign timer_32   = (ir_timer == 12'd32)  ? 1'b1 : 1'b0;
 assign timer_4095 = (ir_timer == 12'hfff) ? 1'b1 : 1'b0;
 
 /*-- channel counter --*/
 always_ff @(posedge clk or negedge rst_n)
  if(!rst_n)
    channel_cnt  <=  3'b000;
  else if(reset_channel_cnt)
    channel_cnt  <=  3'b000;
  else if(inc_channel_cnt)
    channel_cnt  <=  channel_cnt + 1;

 /*-- channel counter decoder logic : 
   channel_cnt: is encoded as 
     aab: where b= 0- right / 1 - left
          and aa == 00 - in 
                 == 01 - mid
                 == 10 - out
   now mapping this to our A2D intf unit   */ 
 always_comb begin
  case(channel_cnt)
    3'b000: chnnl = 3'b001;    // in right
    3'b001: chnnl = 3'b000;    // in left
    3'b010: chnnl = 3'b100;    // mid right
    3'b011: chnnl = 3'b010;    // mid left
    3'b100: chnnl = 3'b011;    // out right
    3'b101: chnnl = 3'b111;    // out left
    default:
            chnnl = 3'bxxx;
  endcase
 end
 
 /*-- integral decimator --*/
 always_ff @(posedge clk or negedge rst_n)
   if(!rst_n)
    intgdec  <=  2'b11;
   else if(inc_intgdec)
    intgdec  <=  intgdec + 1;
    
 
///////////////////////////////////////////////
 /*--- The BIGGG FSM ---*/
 ///////////////////////////////////////////////

typedef enum reg [4:0] {IDLE = 0, WAIT_4095, 
                  A2D_RIGHT, IN_RIGHT, MID_RIGHT, OUT_RIGHT,
                  WAIT_32, 
                  A2D_LEFT, IN_LEFT, MID_LEFT, OUT_LEFT,
                  INTGL, ICOMP, PCOMP,
                  ACCUM_RIGHT, RIGHT_REG,
                  ACCUM_LEFT, LEFT_REG,
                  UPDATE_IR_ALL} state_t;
state_t state, nxt_state;

always_ff @(posedge clk or negedge rst_n) begin
if (!rst_n)
  state <= IDLE;
else
  state <= nxt_state;
end
 
always_comb 
begin
// reset all the signal output from FSM
reset_channel_cnt = 0;
inc_channel_cnt = 0;

reset_timer = 0;
en_timer = 0;

inc_intgdec = 0;

src0sel = A2DRESIN0;
src1sel = ACCUMIN1;

multiply = 0; 
sub = 0; 
mult2 = 0; 
mult4 = 0; 
saturate = 0;

rstaccum = 0; 
dst2accum = 0; dst2error = 0; dst2intgrl= 0; dst2icomp = 0; dst2pcomp = 0;
dst2lft = 0; dst2rht = 0;

update_IR_en = 0;
clear_IR_all = 0;

strt_cnv = 0;

nxt_state = IDLE;

  case (state)
  
    IDLE: /* wait for the go signal 1. Accum = 0*/
          if (go) begin
            //reset_channel_cnt = 1;  // because we reset channel count as we leave OUT_LEFT
            reset_timer = 1;
            rstaccum = 1;
            update_IR_en = 1;
            nxt_state = WAIT_4095;
            end
            
    WAIT_4095:/* wait for IR sensors to stabilize and then start conv on right chnnel*/
          if (timer_4095) begin
          strt_cnv = 1;
          nxt_state = A2D_RIGHT;
        end
        else begin
          en_timer = 1;
          nxt_state = WAIT_4095;
        end

    A2D_RIGHT: /* wait for right channel to complt conversion and move to appropriate right chnnl*/
          if (cnv_cmplt) begin
            case(channel_cnt[2:1])
              2'b00: nxt_state = IN_RIGHT;
              2'b01: nxt_state = MID_RIGHT;
              2'b10: nxt_state = OUT_RIGHT;
            endcase
            reset_timer = 1;
          end
          else begin
            nxt_state = A2D_RIGHT;
          end

     IN_RIGHT: /* 2. Accum = Accum _+ IR_in_rht*/
         begin
          dst2accum = 1;
          inc_channel_cnt = 1;
          nxt_state = WAIT_32;
         end
          
      MID_RIGHT: /* 4. Accum = Accum _+ 2* IR_mid_rht*/
         begin
          mult2 = 1;
          dst2accum = 1;
          inc_channel_cnt = 1;
          nxt_state = WAIT_32;
         end

      OUT_RIGHT: /* 6. Accum = Accum _+ 4* IR_out_rht*/
         begin
          mult4 = 1;
          dst2accum = 1;
          inc_channel_cnt = 1;
          nxt_state = WAIT_32;
         end

      WAIT_32: /* coz Eric says Wait for 32 cycles*/
          if (timer_32) begin
            strt_cnv = 1;
            nxt_state = A2D_LEFT;
          end
          else begin
            en_timer = 1;
            nxt_state = WAIT_32;
          end

      A2D_LEFT: /* wait for left chnnl to cmplt conversion and move to approriate left chnnl*/
          if (cnv_cmplt) begin
            case(channel_cnt[2:1])
              2'b00: nxt_state = IN_LEFT;
              2'b01: nxt_state = MID_LEFT;
              2'b10: nxt_state = OUT_LEFT;
            endcase
            // reset_timer = 1; // reset_timer while going to WAIT_4095 from UPDATE_IR_ALL
          end
          else begin
            nxt_state = A2D_LEFT;
          end

      /* From here IN_LEFT and MID_LEFT should go to next channel UPDATE_IR_ALL
      * OUT_LEFT goes to PI calculation path*/    

      IN_LEFT: /*3. Accum = Accum - IR_in_lft*/
         begin
          sub = 1; 
          dst2accum = 1;
          inc_channel_cnt = 1;
          nxt_state = UPDATE_IR_ALL;
         end

      MID_LEFT: /*5. Accum = Accum - 2*IR_mid_lft*/
         begin
          sub = 1; 
          mult2 = 1;
          dst2accum = 1;
          inc_channel_cnt = 1;
          nxt_state = UPDATE_IR_ALL;
         end

      UPDATE_IR_ALL:
         begin
          update_IR_en = 1;
          reset_timer = 1;
          nxt_state = WAIT_4095;
         end

      OUT_LEFT: /*7. Error = saturate(Accum - 4*IR_out_lft)*/
         begin
          sub = 1; 
          mult4 = 1;
          saturate = 1;
          dst2error = 1;
          inc_intgdec = 1;
          clear_IR_all = 1; // turn of all the IR sensors
		  reset_channel_cnt = 1; // reset channel count so that when we do update_IR_en we enable the correct IR sensor
          nxt_state = INTGL;
         end

      INTGL: /* 8. Intgrl = saturate(Error >> 4 + Intgrl)*/
         begin
          src0sel = INTGRLIN0;
          src1sel = ERRORSCALEIN1;
          dst2intgrl = &intgdec[1:0]; // integral result captured only once in 4 PI calc cycles
          saturate = 1;
          nxt_state = ICOMP;
         end

      ICOMP: /* 9. Icomp = Iterm * Ingrl */
         begin
          src0sel = INTGRLIN0;
          src1sel = ITERMIN1;
          multiply = 1;
          dst2icomp = 1;
          nxt_state = PCOMP;
         end

      PCOMP: /* 10. Pcomp = Error * Pterm */
         begin
          src0sel = PTERMIN0;
          src1sel = ERRORIN1;
          multiply = 1;
          dst2pcomp = 1;
          nxt_state = ACCUM_RIGHT;
         end

      ACCUM_RIGHT: /* 11. Accum = Fwd - Pterm */
         begin
          src0sel = PCOMPIN0;
          src1sel = FWDIN1;
          sub = 1;
          dst2accum = 1;
          nxt_state = RIGHT_REG;
         end

      RIGHT_REG: /* 12. rht_reg = saturate (Accum - Icomp)*/
         begin
          src0sel = ICOMPIN0;
          src1sel = ACCUMIN1;
          sub = 1;
          saturate = 1;
          dst2rht = 1;
          nxt_state = ACCUM_LEFT;
         end

      ACCUM_LEFT: /* 13. Accum = Fwd + Pcomp */
         begin
          src0sel = PCOMPIN0;
          src1sel = FWDIN1;
          dst2accum = 1;
          nxt_state = LEFT_REG;
         end

      LEFT_REG: /* 14. lft_reg = saturate(Accum + Icmop) */
         begin
          src0sel = ICOMPIN0;
          src1sel = ACCUMIN1;
          saturate = 1;
          dst2lft = 1;
          nxt_state = IDLE;
         end

      default: /* I hope we never reach this state */
          nxt_state = IDLE;
          
  endcase   
end // end of FSM
     
endmodule

  
