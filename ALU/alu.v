//Author:	Lokesh jindal
//e-mail:	lokeshjindal15@cs.wisc.edu
//Date:		Feb 19, 2015

//Q4 HW2 ECE551

//Design of alu for line-follower robot

module alu(
	Accum, Iterm, Error, Fwd,
	a2d_res, Intgrl, Icomp, Pcomp, Pterm,
	src1sel, src0sel,
	multiply, sub, mult2, mult4, saturate,
	dst);

input	[15:0] Accum, Pcomp;
input	[13:0] Pterm;
input	[11:0] a2d_res, Fwd, Error, Intgrl, Icomp, Iterm;
input	[2:0] src1sel, src0sel;
input	multiply, sub, mult2, mult4, saturate;

output	[15:0] dst;


localparam	ACCUM	= 3'b000;
localparam	ITERM	= 3'b001;
localparam	ERROR1	= 3'b010;
localparam	ERROR2	= 3'b011;
localparam	FWD	= 3'b100;

localparam	A2D_RES	= 3'b000;
localparam	INTGRL	= 3'b001;
localparam	ICOMP	= 3'b010;
localparam	PCOMP	= 3'b011;
localparam	PTERM	= 3'b100;

wire	[15:0]src1;
wire	[15:0]pre_src0;

wire	[15:0]scaled_src0;

wire	[15:0]src0;

wire	[15:0]sum_src;

wire	[15:0]saturate_sum;

wire	signed [14:0]mul_src0;
wire	signed [14:0]mul_src1;
wire	signed [29:0]multiply_src;
wire	[15:0]saturate_multiply;

assign	src1 			=			(src1sel == ACCUM)		?	Accum:
									(src1sel == ITERM)		?	{4'b0000,Iterm}:
									(src1sel == ERROR1)		?	{{4{Error[11]}},Error}:
									(src1sel == ERROR2)		?	{{8{Error[11]}},Error[11:4]}:
									(src1sel == FWD)		?	{4'b0000,Fwd}:
									16'h0000;

assign	pre_src0 		=			(src0sel == A2D_RES)	?	{4'b0000,a2d_res}:
									(src0sel == INTGRL)		?	{{4{Intgrl[11]}},Intgrl}:
									(src0sel == ICOMP)		?	{{4{Icomp[11]}},Icomp}:
									(src0sel == PCOMP)		?	Pcomp:
									(src0sel == PTERM)		?	{2'b00,Pterm}:
									16'h0000;

assign	scaled_src0 	=			(mult2)	? (pre_src0 << 1):
									(mult4) ? (pre_src0 << 2):
									pre_src0;//making mult2 higher priority

assign	src0 			=			(sub) ? ~scaled_src0:
									scaled_src0;

assign	sum_src 		= 			src0 + src1 + sub;

assign saturate_sum 	=			(sum_src[15]) ? ((&sum_src[14:11]) ? sum_src : 16'hF800):
									((|sum_src[14:11]) ? 16'h07FF : sum_src);

assign	mul_src0 		= 			src0[14:0];	
assign	mul_src1 		= 			src1[14:0];

assign multiply_src 	= 			mul_src0 * mul_src1;

assign saturate_multiply =			(multiply_src[29]) ? ((&multiply_src[28:26]) ? multiply_src[27:12] : 16'hC000):
									((|multiply_src[28:26]) ? 16'h3FFF : multiply_src[27:12]);
						
assign dst 				=			(multiply)				?	saturate_multiply:
									(saturate)				?	saturate_sum:
									sum_src;
									
endmodule
