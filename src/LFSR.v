`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 01:12:42 PM
// Design Name: 
// Module Name: LFSR
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

module LFSR(
    input clk_i,
    output [7:0] q_o
    );

    wire xor_output;
    wire [7:0]Q;
    
    assign xor_output = q_o[0]^q_o[5]^q_o[6]^q_o[7];
    
    FDRE #(.INIT(1'b1)) q_o0_FF (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(xor_output),
        .Q(q_o[0]));
        
    FDRE #(.INIT(1'b0)) q_o1_FF (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(q_o[0]),
        .Q(q_o[1]));
        
    FDRE #(.INIT(1'b0)) q_o2_FF (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(q_o[1]),
        .Q(q_o[2]));
        
    FDRE #(.INIT(1'b0)) q_o3_FF (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(q_o[2]),
        .Q(q_o[3]));
        
    FDRE #(.INIT(1'b0)) q_o4_FF (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(q_o[3]),
        .Q(q_o[4]));
        
    FDRE #(.INIT(1'b0)) q_o5_FF (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(q_o[4]),
        .Q(q_o[5]));

    FDRE #(.INIT(1'b0)) q_o6_FF (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(q_o[5]),
        .Q(q_o[6]));

    FDRE #(.INIT(1'b0)) q_o7_FF (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(q_o[6]),
        .Q(q_o[7]));
        
endmodule
