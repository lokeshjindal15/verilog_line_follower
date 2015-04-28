//Author:	Lokesh jindal
//e-mail:	lokeshjindal15@cs.wisc.edu
//Date:		March 20, 2015

//Ex14/HW4 Q3 ECE551

//Design of testbench for alu for line-follower robot using Eric's test 1000 vectors

module alu_tb();

/*
reg	[15:0] _Accum, _Pcomp;
reg	[13:0] _Pterm;
reg	[11:0] _a2d_res, _Fwd, _Error, _Intgrl, _Icomp, _Iterm;
reg	[2:0] _src1sel, _src0sel;
reg	_multiply, _sub, _mult2, _mult4, _saturate;
*/

reg [128:0] stim_memory[999:0];
reg [15:0] resp_memory[999:0];

reg [128:0] stim;
wire	[15:0] _dst;

reg [32:0] i;


wire ANDSubNMultiply = stim[3] & stim[4];
reg fail;
alu alu_dut(
	.Accum(stim[128:113]), .Iterm(stim[22:11]), .Error(stim[58:47]), .Fwd(stim[82:71]),
	.A2D_res(stim[70:59]), .Intgrl(stim[46:35]), .Icomp(stim[34:23]), .Pcomp(stim[112:97]), .Pterm(stim[96:83]),
	.src1sel(stim[10:8]), .src0sel(stim[7:5]),
	.multiply(stim[4]), .sub(stim[3]), .mult2(stim[2]), .mult4(stim[1]), .saturate(stim[0]),
	.dst(_dst));

initial
begin
stim = 0;

$readmemh("ALU_stim.hex", stim_memory);
$readmemh("ALU_resp.hex", resp_memory);

for (i =0; i < 1000; i= i+1)
begin
	stim[128:0] = stim_memory[i][128:0];
	#2;
	if ((_dst[15:0] != resp_memory[i][15:0]) && (ANDSubNMultiply != 1'b1))
	begin
		fail = 1;
		$display("ERROR! dst output does not match for i:%d stim:%h expected:%h got:%h\n", i, stim, resp_memory[i][15:0], _dst[15:0]);
		$stop;
	end
	else 
	fail = 0;
end

$display("Yo! All %d tests passed!\n", i);
$stop;
end


endmodule
