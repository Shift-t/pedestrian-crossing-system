`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2025 05:07:46 AM
// Design Name: 
// Module Name: clk1hz
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


module clk1hz (input clock, reset, output reg clock_1hz);
  reg [26:0] counter;
  
  //A checking number is decided depending on the frequency of the FPGAs internal clock, for a 100MHz clock, the counter reaches 100M cycles per second
  always @(posedge clock) begin //Triggers block at every rising edge of the clock
    if (reset) begin 
      counter <= 0;     //Reset counter to zero
      clock_1hz <= 0;   //Reset output clock to low
    end else if (counter == 27'd99_999_999) begin
      counter <= 0;     //Reset counter after reaching one-second interval
      clock_1hz <= 1;   //Set output high for one clock cycle (pulse every second)
    end else begin 
      counter <= counter + 1;   //Increments counter
      clock_1hz <= 0;           //Keep output low otherwise
    end
  end
endmodule
