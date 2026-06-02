`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 11:02:03 PM
// Design Name: 
// Module Name: pedestrian_crossing_test
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


module traffic_system_test(
    input clk,								//FPGA clock
    input reset,							//circuit reset button
    input enable,							//circuit enable switch
    input ped_btn,						//Pedestrian button
    output [7:0] seg,					//Output for 7-segment display to display the timer
    output [7:0] an,
    output s1, s2, s3, ped_signal,  //outputs for the green lights
    output r1, r2, r3, r_ped_signal //outputs for the red lights
    );
    
	 //red lights assigned to on whenever their respective green lights are off
    assign r1 = ~s1;
    assign r2 = ~s2;
    assign r3 = ~s3;
    assign r_ped_signal = ~ped_signal;
	
	 //Debounce modules to ensure smooth input signals from FPGA buttons
    debounce d1(clk, reset, cln_reset);
    debounce d2(clk, ped_btn, cln_ped);
    
    wire [3:0] remaining_time;
    pedestrian_crossing test(clk, cln_reset, enable, cln_ped, s1, s2, s3, ped_signal, remaining_time);
    
    // D0: remaining time for S1
    // D2: remaining time for S2
    // D4: remaining time for S3
    // D6: remaining time for pedestrian light
    wire [3:0] D0, D2, D4, D6;
    
    assign D0 = s1 ? remaining_time : 4'd0;
    assign D2 = s2 ? remaining_time : 4'd0;
    assign D4 = s3 ? remaining_time : 4'd0;
    assign D6 = ped_signal ? remaining_time : 4'd0;
    
    DISP7SEG display(clk, D0, 4'd0, D2, 4'd0, D4, 4'd0, D6, 4'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
                        seg, an);
endmodule
