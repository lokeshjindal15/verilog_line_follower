
/* Digital Core: top level logic block for 
*     controlling bot and doing PI control
Author: Bhuvana Kakunoori, Brian Coutinho
e-mail: kakunoori@wisc.edu, bcoutinho@wisc.edu
*/

module dig_core(clk,rst_n,cmd_rdy,cmd,clr_cmd_rdy,lft,rht,buzz,buzz_n,
                in_transit,OK2Move,ID,clr_ID_vld,ID_vld,cnv_cmplt,strt_cnv,
				chnnl,A2D_res,IR_in_en, IR_mid_en, go,IR_out_en,led);
										 			
  input clk,rst_n;			// 50MHz clock and active low asynch reset
  input cmd_rdy;			// indicates command from BLE112 is ready
  input [7:0] cmd;			// command from BLE112
  input OK2Move;			// input from proximity sensor
  input [7:0] ID;			// station ID from BC unit
  input ID_vld;				// indicates ID value from BC unit is valid
  input cnv_cmplt;			// indicates A2D conversion is ready
  input [11:0] A2D_res;		// result of A2D conversion of IR sensor
  
  output clr_cmd_rdy;					// used to knock down cmd_rdy signal after command processed
  output [10:0] lft,rht;				// 11-bit signed left and right motor controls
  output buzz,buzz_n;					// optional piezo buzzer
  output in_transit;					// forms enable to proximity sensor
  output clr_ID_vld;					// used to knock down ID_vld once station ID digested
  output strt_cnv;						// used to initiate a Round Robing conversion on IR sensors
  output [2:0] chnnl;					// channel to perform A2D conversion on
  output IR_in_en,IR_mid_en,IR_out_en;	// PWM based enables to various IR sensors
  output [7:0] led;						// Active high drive to array of 8 LEDs
  output go;							// Go signal to motion controller
  
  ///////////////////////////////////////////////
  // Declare any wires needed to interconnect //
  // blocks of the digital core below here.  //
  ////////////////////////////////////////////

  logic [11:0] lft_reg,rht_reg;	      // 12-bit signed left and right motor controls

  logic piezo_en;                     // enable piezo buzzer
  logic [12:0] pz_cnt;                // counter for the buzzer

  
  ///////////////////////////////////////////////
  // Instantiate Command & Control Block Next //
  /////////////////////////////////////////////

 Cmdcntrl iCmdctrl(
   .clk(clk),
   .rst_n(rst_n),
   .cmd_rdy(cmd_rdy),           /*-- export cmd* signals to cmd interfac -*/
   .cmd(cmd),
   .clr_cmd_rdy(clr_cmd_rdy),
   .ID_vld(ID_vld),             /*-- export ID* signals to barcode reader -*/
   .clr_ID_vld(clr_ID_vld),
   .ID(ID),
   .in_transit(in_transit)
 );
  

  ///////////////////////////////////////////////
  // Instantiate Motion Controller Block Next //
  /////////////////////////////////////////////
 motion iMotion(
   .clk(clk), 
   .rst_n(rst_n), 
   .A2D_res(A2D_res), 
   .go(go), 
   .chnnl(chnnl), 
   .strt_cnv(strt_cnv),       /*-- export to the A2D intf --*/
   .cnv_cmplt(cnv_cmplt), 
   .IR_in_en(IR_in_en), 
   .IR_mid_en(IR_mid_en), 
   .IR_out_en(IR_out_en), 
   .lft_reg(lft_reg), 
   .rht_reg (rht_reg)
 );
				
 /////////////////////////////////////////////
 // Glue logic for export singals and the 
 //   go signal
 /////////////////////////////////////////////
					
 assign  lft = lft_reg[11:1];     // send out upper 11 bits of lft_reg and rht_reg
 assign  rht = rht_reg[11:1];     //   to the PWM generators

 // go : when cmd int wants us and there is no obstacle in the path
 assign  go = in_transit & OK2Move;

 // en: enable peiZo buzzer
 assign piezo_en =  in_transit & ~OK2Move;


 ////////////////////////////////////////////
 //  Piezzo frequency divider block 
 ///////////////////////////////////////////
 
 always_ff @(posedge clk or negedge rst_n) 
  if(!rst_n)
    pz_cnt  <=  13'h0000;
  else if(piezo_en)
    pz_cnt  <= pz_cnt + 1;

 assign buzz   =  pz_cnt[12];
 assign buzz_n = ~pz_cnt[12];

 // led : signal for our debuggin purposes
 assign led = cmd;
 
endmodule
  
