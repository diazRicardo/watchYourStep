`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 03:10:48 PM
// Design Name: 
// Module Name: selector
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


module selector(
    input [15:0] N_i,
    input [3:0] sel_i,
    output [3:0] H_o
    );
    
    // results of the first two mux' sent to these wires
    wire [3:0] top_mux_A;
    wire [3:0] top_mux_B;
    
    // result of boolean expression sent here, which is used as the selector for the top level mux
    wire x;
    
    mux4bit_sel mux1 (.A(N_i[15:12]), .B(N_i[11:8]), .sel(sel_i[2]), .Y(top_mux_A));
    mux4bit_sel mux2 (.A(N_i[7:4]), .B(N_i[3:0]), .sel(sel_i[0]), .Y(top_mux_B));
    
    assign x = ~sel_i[3]&~sel_i[2]&~sel_i[1]&sel_i[0] | ~sel_i[3]&~sel_i[2]&sel_i[1]&~sel_i[0];
    
    mux4bit_sel top_mux2 (.A(top_mux_A), .B(top_mux_B), .sel(x), .Y(H_o));
    
endmodule