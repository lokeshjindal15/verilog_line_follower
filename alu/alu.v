/*-----------------------------------
  ALU - for fast math operations 
        of the PI controller
------------------------------------*/

module  alu( Accum, Pcomp, Pterm, Fwd, A2D_res, Error, Intgrl, Icomp, Iterm, dst, src1sel, src0sel, multiply, sub, mult2, mult4, saturate);

input [15:0]  Accum, Pcomp;                  // full width
input [13:0]  Pterm;                         // unsigned
input [11:0]  Fwd, A2D_res;                  // unsigned
input [11:0]  Error, Intgrl, Icomp, Iterm;   // signed
output [15:0] dst;

/*- control inputs -*/
input multiply, sub, mult2, mult4, saturate;
input [2:0] src1sel, src0sel;

/*-- Local params --*/
localparam AccumIn1 = 3'h0;
localparam ItermIn1 = 3'h1;
localparam ErrorIn1 = 3'h2;
localparam ErrorScaleIn1 = 3'h3;
localparam FwdIn1   = 3'h4;

localparam A2DresIn0 = 3'h0;
localparam IntgrlIn0 = 3'h1;
localparam IcompIn0  = 3'h2;
localparam PcompIn0  = 3'h3;
localparam PTermIn0  = 3'h4;


wire [15:0] src1, pre_src0, scaled_src0, src0;
wire signed [14:0] mult_src0, mult_src1;
wire signed [29:0] raw_mult;   // need outs to be signed first
wire [15:0] raw_sum;
//wire [14:0] scaled_mult;
wire [15:0] sat_mult, sat_sum, final_sum;


/*-- Begin implemenation --*/

/*-----   input muxes  ----*/
assign  src1   =   (src1sel == AccumIn1)  ?  Accum                     :
                   (src1sel == ItermIn1)  ?  {4'b0000, Iterm}          :
                   (src1sel == ErrorIn1)  ?  {{4{Error[11]}}, Error}   :
                   (src1sel == ErrorScaleIn1) ? {{8{Error[11]}}, Error[11:4]} :
                   (src1sel == FwdIn1)    ?  {4'b0000, Fwd}            :
                    16'h0000;
assign  pre_src0 = (src0sel == A2DresIn0) ?  {4'b0000, A2D_res}        :
                   (src0sel == IntgrlIn0) ?  {{4{Intgrl[11]}}, Intgrl} :
                   (src0sel == IcompIn0)  ?  {{4{Icomp[11]}}, Icomp}   :
                   (src0sel == PcompIn0)  ?  Pcomp                     :
                   (src0sel == PTermIn0)  ?  {2'b00, Pterm}            :
                   16'h0000;
                  
//--- perform mult scaling -- 
assign  scaled_src0 =  mult4  ?  {pre_src0[13:0], 2'b00}  :
                       mult2  ?  {pre_src0[14:0], 1'b0}   :
                       pre_src0;

// --- manage subtraction with 1's complement
assign  src0 =  sub  ?  ~scaled_src0 : scaled_src0;


/*--- 16 bit Adder  ---*/
assign raw_sum = src0 + src1 + sub;   // ignore carry for now ??

// 12-bit signed saturation logic -- keeps the top 4 bits 0
assign sat_sum =  raw_sum[15]  ?  ( (&raw_sum[14:11]) ? raw_sum[15:0] : 16'hf800 ) 
                               :  (~(|raw_sum[14:11]) ? raw_sum[15:0] : 16'h07ff );

							   
/*--- 15x15 bit multiplier  --*/
assign  mult_src0 = scaled_src0[14:0];
assign  mult_src1 = src1[14:0];
				   
assign raw_mult =  mult_src0 * mult_src1;
//assign scaled_mult = raw_mult[26:12];

// 15-bit saturate for product
assign sat_mult =  raw_mult[29] ?  ( (&raw_mult[28:26]) ?  {raw_mult[27:12]} : 16'hC000 )
                                :  (~(|raw_mult[28:26]) ?  {raw_mult[27:12]} : 16'h3fff );

/*--- Final mux ---*/
assign final_sum =  saturate ? sat_sum  : raw_sum;
assign dst       =  multiply ? sat_mult : final_sum;


endmodule
