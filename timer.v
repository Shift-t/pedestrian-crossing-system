`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2025 05:02:57 AM
// Design Name: 
// Module Name: timer
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


module timer (
    input clock,
    input reset,
    input enable,
    input load,
    input [3:0] data,
    output reg [3:0] count,
    output done
    );

    // At each rising edge of clock or asynchronous reset signal:
    always @(posedge clock or posedge reset) begin
        if (reset)          // If reset is active, immediately load 'data' into 'count'
            count <= data;
        else if (load)      // If load signal is active, synchronously load 'data' into 'count'
            count <= data;
        else if (enable && count > 0) // If counting is enabled and 'count' is larger than zero, decrement 'count'
            count <= count - 1;
    end

    assign done = (count == 4'b0001); //'done' is set high if 'count' reaches 1
endmodule
