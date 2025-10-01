`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 02:26:18 PM
// Design Name: 
// Module Name: edge_detector
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

module edge_detector(
    input btn_i,
    input clk_i,
    output edge_o
    );
    
    wire prev_val, new_val;
    
    FDRE #(.INIT(1'b0)) ff_1 (
        .C(clk_i),
        .CE(1'b1),
        .D(btn_i),
        .Q(new_val),
        .R(1'b0)
    );
    
    FDRE #(.INIT(1'b0)) ff_2 (
        .C(clk_i),
        .CE(1'b1),
        .D(new_val),
        .Q(prev_val),
        .R(1'b0)
    );
    
    assign edge_o = ~prev_val & new_val;
    
endmodule
