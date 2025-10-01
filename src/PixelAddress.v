`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2025 12:50:53 AM
// Design Name: 
// Module Name: PixelAddress
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

module PixelAddress(
    input clkin,
    output [15:0] H,
    output [15:0] V
    );
    
    wire [15:0] h_count;
    wire [15:0] v_count;
    wire v_utc, h_utc, v_dtc, h_dtc;
    
    wire h_reset;
    wire v_reset;
    
    assign h_reset = 16'd799 == h_count;
    assign v_reset = (v_count == 16'd524) && h_reset;  // reset at end of frame
    
    countUD16L h_counter (.clk_i(clkin), .up_i(1'b1), .dw_i(1'b0), .ld_i(h_reset), .Din_i(16'b0), .Q_o(h_count), .utc_o(h_utc), .dtc_o(h_dtc));
    countUD16L v_counter (.clk_i(clkin), .up_i(h_reset), .dw_i(1'b0), .ld_i(v_reset), .Din_i(16'b0), .Q_o(v_count), .utc_o(v_utc), .dtc_o(v_dtc));
        
    assign H = h_count;
    assign V = v_count;


endmodule
