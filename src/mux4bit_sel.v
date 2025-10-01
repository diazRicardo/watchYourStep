`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025 05:23:54 PM
// Design Name: 
// Module Name: mux4bit_sel
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


module mux4bit_sel(
    input [3:0] A,
    input [3:0] B,
    input sel,
    output [3:0] Y
    );
    
    assign Y = (A & {4{~sel}}) | (B & {4{sel}});

endmodule
