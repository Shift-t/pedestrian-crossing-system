`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2025 04:31:11 AM
// Design Name: 
// Module Name: tlc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pedestrian_crossing(
    input clock,								//FPGA clock input
    input reset,								//circuit reset button
    input enable,								//Circuit enable
    input ped_btn,							// Pedestrian request button
    output reg s1, s2, s3, ped_signal, // outputs for green lights
    output [3:0] remaining_time			// Remaining time for the current state
    ); 
    
    // local parameters for the different states
    localparam S1 = 2'b00;
    localparam S2 = 2'b01;
    localparam S3 = 2'b10;
    localparam PED = 2'b11;
    
    reg [1:0] state, next_state;	// variables to store the current and next state
    reg [1:0] state_store;			// stores the next regular state to return to after the pedestrian state
    reg pedReq;						// stores the pedestrian button request
	 
    wire timer_load;			//Loading signal for the timer
    reg [3:0] timer_data;	// Timer input for number of seconds it should count down
    wire timer_done;			// Timer completion flag
	 wire clk_1Hz;				// wire carrying the 1Hz clock signal
    
    //module to get a 1Hz clock
    clk1hz my_clock(clock, reset, clk_1Hz);
	 // Timer module instantiation
    timer my_timer(clk_1Hz, reset, enable, timer_load, timer_data, remaining_time, timer_done);
        
    //Tracks Pedestrian Button and updates the pedestrian request variable
    always @(posedge clock, posedge reset) begin
        if (reset)
            pedReq <= 1'b0;
        else if (ped_btn && enable)
            pedReq <= 1;
        else if (state == PED && enable)
            pedReq <= 0;
    end
	 
	 //Continuous assignment of timer_load to load the timer whenever
	 //it finishes counting or reset is pressed
	 assign timer_load = (timer_done || reset);
    
	 //This block loads the timer with the correct data
	 //according to the state it is transitioning to
    always @(*) 
        begin 
            if (reset) begin
                timer_data <= 4'd9;
            end
            else begin
                   
					  case (next_state)
							S1: timer_data <= 4'd9;
							S2: timer_data <= 4'd5;
							S3: timer_data <= 4'd5;
							PED: timer_data <= 4'd6;
							default: timer_data = 4'd9;
					  endcase
            end 
        end
	  
	  //This block handles switching between states when
	  //the timer finishes counting
	  always @(posedge clk_1Hz, posedge reset)
		begin
			if (reset) begin
				state <= S1;
				end
			else if (enable) begin
				if (timer_done)
					state <= next_state;
					
					//stores the next normal state to continue
					//after the Pedestrian crosses
					if (next_state == PED && timer_done) begin
						case (state)
							S1: state_store <= S2;
							S2: state_store <= S3;
							S3: state_store <= S1;
						endcase
					end
				end
		end
		
		
    //This block handles turning the traffic lights green and determining
	 //which state comes next
    always @(*) begin
        s1 = 0; 
        s2 = 0; 
        s3 = 0; 
        ped_signal = 0;
		  next_state = state;
        
        // determins outputs and the next state based on the current state and the pedestrian request
        case (state)
            S1: 
                begin
                    s1 = 1;  
                    if(pedReq) next_state = PED; 
                    else next_state = S2; 
                end
    
            S2:
					 begin
                    s2 = 1;  
                    if(pedReq) next_state = PED; 
                    else next_state = S3;
                end
    
            S3:
					 begin
                    s3 = 1;  
                    if(pedReq) next_state = PED; 
                    else next_state = S1;
                end
    
            PED:
                begin
                    ped_signal = 1;
                    next_state = state_store;
                end
        endcase
    end             
endmodule
