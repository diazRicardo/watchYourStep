`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 04:50:59 PM
// Design Name: 
// Module Name: fa
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


module fa(
    input a_i,
    input b_i,
    input Cin_i,
    output s_o,
    output Cout_o
    );
    
    assign s_o = a_i ^ b_i ^ Cin_i;
    assign Cout_o = (a_i & b_i) | (b_i & Cin_i) | (a_i & Cin_i);
 
endmodule

