`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 04:02:25 PM
// Design Name: 
// Module Name: mux
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

module mux(

    input [3:0] A_i,
    input [3:0] B_i,
    input Sel_i,
    output [3:0] Y_o
    );
    
    // when Sel_i is HIGH, B is passed through
    assign Y_o = (A_i & {4{~Sel_i}}) | (B_i & {4{Sel_i}});
endmodule

