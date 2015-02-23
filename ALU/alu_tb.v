//Author:	Lokesh jindal
//e-mail:	lokeshjindal15@cs.wisc.edu
//Date:		Feb 19, 2015

//Q4 HW2 ECE551

//Design of testbench for alu for line-follower robot

module alu_tb();

reg	[15:0] _Accum, _Pcomp;
reg	[13:0] _Pterm;
reg	[11:0] _a2d_res, _Fwd, _Error, _Intgrl, _Icomp, _Iterm;
reg	[2:0] _src1sel, _src0sel;
reg	_multiply, _sub, _mult2, _mult4, _saturate;

wire	[15:0] _dst;

wire fail;

alu alu_dut(
	.Accum(_Accum), .Iterm(_Iterm), .Error(_Error), .Fwd(_Fwd),
	.a2d_res(_a2d_res), .Intgrl(_Intgrl), .Icomp(_Icomp), .Pcomp(_Pcomp), .Pterm(_Pterm),
	.src1sel(_src1sel), .src0sel(_src0sel),
	.multiply(_multiply), .sub(_sub), .mult2(_mult2), .mult4(_mult4), .saturate(_saturate),
	.dst(_dst));


//reg [79:0]mux0_ip, mux1_ip;

//assign _Accum = mux0_ip[15:0];
//assign _Iterm = mux0_ip[27:16];
//assign _Error = mux0_ip[43:32];
//assign _Fwd	  = mux0_ip[75:64];

//assign _a2d_res = mux1_ip[11:0];
//assign _Intgrl 	= mux1_ip[27:16];
//assign _Icomp   = mux1_ip[43:32];
//assign _Pcomp	= mux1_ip[63:48];
//assign _Pterm	= mux1_ip[77:64];

reg [15:0]i;
reg [15:0]ref;

assign fail = !(_dst == ref);

initial
begin

_Accum = 0;
_Iterm = 1;
_Error = 2;
_Fwd = 4;

_a2d_res = 5;
_Intgrl = 6;
_Icomp = 7;
_Pcomp = 8;
_Pterm = 9;

_src0sel = 0;
_src1sel = 0;	
_multiply = 0;
_sub = 0; 
_mult2 = 0; 
_mult4 = 0; 
_saturate = 0;

#10;

//Test that mux0 works
for (i = 0; i < 5; i = i + 1)
begin
	_src1sel = i;
	if (i == 16'h03)
	 begin
	 ref = 0 + 5;
	 end
	else
	 begin
	   ref = i + 5;
	  end

	#10;
end

#10;
_src1sel = 0;
//Test that mux1 works
for (i = 0; i < 5; i = i + 1)
begin
	_src0sel = i;
	ref = i + 5;
	#10;
end

//Since muxes work correctly lets fix the inputs
_src0sel = 3'b011;//select Pcomp
_src1sel = 3'b000;//select Accum
//_Pcomp = 16'h7FFF;
_Pcomp = 16'h02;
_Accum = 16'h03;

ref = 5;

#10
_mult2 = 1;//check mult2 works
ref = 7;

#10
_mult4 = 1;//check mult2 is higher priority than mult4
ref = 7;

#10
_mult2 = 0;//check mult4 works
ref = 11;

#10
_mult4 = 0;
ref = 5;

#10
_sub = 1;//check that sub works
ref = 1;

#10
_sub = 0;
ref = 5;

#10
_saturate = 1;//check that saturate does not screw up normal values
ref = 5;

#10
_sub = 1;
ref = 1;

#10
_sub = 0;
_saturate = 0;
ref = 5;

#10
_Pcomp = 16'h7FF0;//+ve value > 0x7FF without saturate does not saturate
ref = 16'h7FF3;

#10
_sub = 1;
ref = 16'h8013;//-ve value < 0x800 without saturate does not saturate

#10
_sub = 0;
_saturate = 1;
ref = 16'h07FF;//+ve value does saturate

#10
_sub = 1;
ref = 16'hF800;//-ve value does saturate

#10
_sub =0;
_mult2 = 0;
_mult4 = 0;
_multiply = 1;//check that the mux at output does select saturated product
_Pcomp = 16'h3FF0;
ref = 16'h0B;

#10
_Accum = 16'h03FF0;
_Pcomp = 16'h03FF0;//check that product does saturate on +ve side
ref = 16'h3FFF;

#10
_Pcomp = 16'hC010;//check that product does saturate on -ve side
ref = 16'hC000;

end
	
endmodule
