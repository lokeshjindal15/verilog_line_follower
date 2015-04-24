/*-----------------------------------
  ALU TB- Test bench for our multi
         function ALU
------------------------------------*/

module alu_tb();

reg [15:0]  stAccum, stPcomp;                  // full width
reg [13:0]  stPterm;                         // unsigned
reg [11:0]  stFwd, stA2D_res;                  // unsigned
reg [11:0]  stError, stIntgrl, stIcomp, stIterm;   // signed
wire [15:0] dst_mon;

/*- control regs -*/
reg multiply, sub, mult2, mult4, saturate;
reg [2:0] src1sel, src0sel;

enum {A2DresIn0 = 0, IntgrlIn0, IcompIn0, PcompIn0, PTermIn0}  src0select;
enum {AccumIn1 = 0, ItermIn1, ErrorIn1, ErrorScaleIn1, FwdIn1} src1select;

alu  iDut( .Accum(stAccum), .Pcomp(stPcomp), .Pterm(stPterm), 
           .Fwd(stFwd), .A2D_res(stA2D_res), .Error(stError),
           .Intgrl(stIntgrl), .Icomp(stIcomp), .Iterm(stIterm), .dst(dst_mon),
           .multiply(multiply), .sub(sub), .mult2(mult2), .mult4(mult4),
           .saturate(saturate), .src1sel(src1sel), .src0sel(src0sel) );

/*--- checks  ---*/
reg fail_accum1, fail_mult;
reg signed [15:0] sum_accum;
reg signed [29:0] mult_full;
reg signed [17:0] mult_part;
reg signed [15:0] mult_res;

// check accumulator additions - Accum += or -= A2D_res * (1,2,4)
always @(stAccum,stA2D_res) begin 
  fail_accum1 = 0;
  if(src0sel == A2DresIn0 && src1sel == AccumIn1) begin 
    case ({sub, mult2, mult4})
      3'b000: sum_accum = stAccum + stA2D_res;
      3'b010: sum_accum = stAccum + 2 * stA2D_res;
      3'b001: sum_accum = stAccum + 4 * stA2D_res;
      3'b100: sum_accum = stAccum - stA2D_res;
      3'b110: sum_accum = stAccum - 2 * stA2D_res;
      3'b101: sum_accum = stAccum - 4 * stA2D_res;
      default: begin 
        $display("Testbench error: invalid combination of inputs selected");
        $stop();
      end
    endcase 
    
    saturate_ifneeded();
    if(sum_accum != dst_mon) begin
      fail_accum1 = 1;
      $display("Sum mismatch, expected = %h, found = %h, {sub, mult2, mult4}=%b", 
              sum_accum, dst_mon, {sub, mult2, mult4} );
      //$stop();
    end
  end
end

//  check - Pcomp/ Icomp multiply -- will ascertain if mult saturation is correct
reg signed [14:0] multop0, multop1;
always @(stPterm, stError, stIterm, stIntgrl) begin
  fail_mult = 0;

  if(src0sel == PTermIn0 && src1sel == ErrorIn1) begin
    multop0 = { 2'b00, stPterm};
    multop1 = { {4{stError[11]}} ,stError};
  end
  else if(src0sel == IntgrlIn0 && src1sel == ItermIn1) begin
    multop0 = { {4{stIntgrl[11]}} ,stIntgrl};
    multop1 = { 4'b0000, stIterm};
  end
  else begin
    multop0 = 15'hx;
    multop1 = 15'hx;
  end

  // signed multiply
  mult_full = multop0 * multop1;
  mult_part = mult_full[29:12];
  saturate_mult();

  if(multiply && mult_res != dst_mon)  begin
      fail_mult = 1;
      $display("Mult mismatch, expected = %h, found = %h ", 
                 mult_res, dst_mon);
      $stop();
  end
  
end

task saturate_ifneeded();
  if(saturate) begin 
    if(sum_accum > 16'sh07ff)
      sum_accum = 16'sh07ff;
    else if(sum_accum < 16'shf800)
      sum_accum = 16'h0800;
  end
endtask

task saturate_mult();
  if(mult_part > 18'sh03fff)
    mult_res = 16'sh3fff;
  else if(mult_part < 18'sh3C000)
    mult_res = 16'hC000;
  else
    mult_res = mult_part[15:0];
endtask

reg [16:0] svector;
reg [16:0] svector1;

initial begin

  stAccum = 16'h0; stPcomp = 16'h0;
  stPterm = 14'h0;
  stFwd = 12'h0; stA2D_res = 12'h0;
  stError = 12'h0; stIntgrl = 12'h0;
  stIcomp = 12'h0; stIterm = 12'h0;

  multiply = 0; sub = 0; mult2 = 0; mult4 = 0; saturate = 0;

  /*--- Accum - a2d test --*/
  $display("TEST1: Accumulator and A2D values\n");
  src0sel = A2DresIn0; src1sel = AccumIn1;
   
  stAccum = 0;
  for(svector = 17'h0; svector < 17'h1000; svector = svector + 4) begin
    sub = 0; mult4 = 0; saturate = 0; mult2 = 0;
    stA2D_res = svector[11:0];
    #1 sub = 1;
    stA2D_res = svector[11:0] + 1;
    #1 sub = 0; mult2 = 1;
    stA2D_res = ~svector[11:0] + 1;
    #1 sub = 0; mult4 = 1; mult2 = 0;
    stA2D_res = svector[11:0] + 2;
    #1 sub = 1; mult2 = 1; mult4 = 0;
    stA2D_res = svector[11:0] + 3;
    #1 sub = 1; mult4 = 1; saturate = 1; mult2 = 0;
    stA2D_res = ~svector[11:0] + 1;
    #1 stAccum = dst_mon;
  end

  //$stop();
  /*-- Intgrl calcluation test -- TBD --*/

  /*-- Icomp/Pcomp multiply --*/
  $display("TEST3: Singed multiply and saturate for Icomp/Pcomp calculation\n");
  multiply = 1; sub = 0; mult2 = 0; mult4 = 0; saturate = 0;

  src0sel = PTermIn0; src1sel = ErrorIn1;
  for(svector = 17'h0; svector < 17'h1000; svector = svector + 1) // non trying all possibilites - 14 bit
    for(svector1 = 17'h0; svector1 < 17'h1000; svector1 = svector1 + 1) begin // this is signed go through all
      stPterm = svector[13:0];
      stError = svector1[11:0];
      #1;
    end

  src0sel = IntgrlIn0; src1sel = ItermIn1;
  for(svector = 17'h0; svector < 17'h1000; svector = svector + 1)
    for(svector1 = 17'h0; svector1 < 17'h1000; svector1 = svector1 + 1) begin // this is signed go through all
      stIterm = svector[11:0];
      stIntgrl = svector1[11:0];
      #1;
    end

  $display("*** ALL TESTS PASSEDS ***- Phew!");
  $stop();
end


endmodule
