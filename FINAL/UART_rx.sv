/////////////  UART RECEIVER            //////////////////
////////////  Author: Bhuvana Kakunoori /////////////////

module UART_rx(clk, rst_n, clr_rdy, RX, rdy, cmd);

	input clk, rst_n, clr_rdy;								// Input clk, active low reset, clear the rdy output
    input RX;												// Input RX bit
    output reg rdy;											// Output rdy to signal byte is received
    output reg [7:0] cmd;									// Output with the received byte

    logic sm_clr_rdy;

    typedef enum reg[1:0] {IDLE, START, SHIFT} state_t;		// States for the State Machine
    state_t state, next_state;

	logic load, receiving, shift, load_baud, set_rdy;		// Control signals generated by the State Machine
    logic [1:0] baud_sel, bit_sel, shift_sel;				// Select signals for the muxes

    logic [11:0] baud_cnt;
	logic [3:0] bit_cnt;
	logic [9:0] rx_shift_reg, temp;

    logic RXFF1, RXFF2;										// Double mux the input RX to avoid metastability issues

	assign baud_sel = {load_baud,receiving};
	assign bit_sel = {load, shift};
	assign shift_sel = {load, shift};  

  	////////// Copy the 8 bits of the transmitted 10 bits to the cmd. Removing the start and stop bit //////////
    assign cmd = rx_shift_reg[8:1];

    ////////// Baud rate counter 2604 - 12 bit. Driven by baud_sel  //////////
	always @(posedge clk) begin
	    case(baud_sel)
	      2'b00: baud_cnt <= baud_cnt;
	      2'b01: baud_cnt <= baud_cnt + 1;
	      default: baud_cnt <= 12'h000;
	    endcase
	end
	
	////////// Bit counter counts 10 for the 10 bits transmitted. Driven by bit_sel //////////
	always @(posedge clk) begin
	    case(bit_sel)
	      2'b00: bit_cnt <= bit_cnt;
	      2'b01: bit_cnt <= bit_cnt + 1;
	      default: bit_cnt <= 4'h0;
	    endcase
	end

	////////// Shifter logic, driven by shift_sel. Right shifts the rx_shift_reg with the RX at MSB //////////
	always @(posedge clk, negedge rst_n) begin
	    if(!rst_n)
	      rx_shift_reg <= 10'h000;

	    else begin
	    case(shift_sel)
	      2'b00: rx_shift_reg <= rx_shift_reg;

	      2'b01: rx_shift_reg <= {RXFF2,rx_shift_reg[9:1]};

	      default: rx_shift_reg <= rx_shift_reg; //Retain the value until next byte transmitted. Dont reset

	    endcase
	    end
	end

    ////////// State Machine synchronous logic //////////
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= next_state;
	end

	////////// Double Flop Input RX to avoid metastability issues because of asynchronous RX input //////////
    always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			RXFF1 <= 1'b1;
			RXFF2 <= 1'b1;
		end else begin
			RXFF1 <= RX;
			RXFF2 <= RXFF1;
		end	
    end

	///////////// Infer state flops ////////////
    always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      rdy <= 1'b0;
		else if(clr_rdy | sm_clr_rdy)
			rdy <= 1'b0;
		else if(set_rdy)
			rdy <= 1'b1;
	end

    //Combinational logic for the State Machine. Drives the load, load_baud, receiving, shift signals
	// We have 3 states. Starts in IDLE. When start bit is received, move to START state and wait for 0.5 bit times
	// before counting. Shift the RX and move to SHIFT state. Here sample the RX every 2604 cycles till all the 
	// other 9 bits are received and then assert rdy.

	always_comb begin
		//Intialize output values to prevent latches
		next_state = IDLE;
		load = 1'b1;
		receiving = 1'b0;
		load_baud = 1'b1;
		shift = 1'b0;
		set_rdy = 1'b0;
		sm_clr_rdy = 1'b0;
		case(state)
		IDLE: if(RXFF2)
				next_state = IDLE;
			else begin
				// RX is at the start bit. 
				load = 1'b0;
				load_baud = 1'b0;
				receiving = 1'b1;
				sm_clr_rdy = 1'b1;
				next_state = START;
			end
		START: begin load = 1'b0;
				load_baud = 1'b0;
				//Wait for 0.5 bit times before shifting the start bit
				if(baud_cnt < 1303) begin
					receiving = 1'b1;
					next_state = START;
				end else begin 	
					receiving = 1'b0;
					load_baud = 1'b1;
					shift = 1'b1;
					next_state = SHIFT;
				end //else
				end //begin
		SHIFT: begin load = 1'b0;
				load_baud = 1'b0;
				//Start counting to shift remaining 9 bits.
				if(bit_cnt < 10) begin
					// Sample at the middle of the RX signal. So count for 1 full bit time.
					if(baud_cnt < 2604) begin
						receiving = 1'b1;
						shift = 1'b0;
						next_state = SHIFT;
					end else begin
						receiving = 1'b0;
						load_baud = 1'b1;
						shift = 1'b1;
						next_state = SHIFT;
					end
				end else begin
					//set_rdy will be asserted 1302 cycles before tx_done will be.
					set_rdy = 1'b1;
					next_state = IDLE;
				end //else
				end //begin
				
		endcase
	end

endmodule