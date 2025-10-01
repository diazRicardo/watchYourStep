`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2025 12:51:33 AM
// Design Name: 
// Module Name: Syncs
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

module Syncs(
    input [15:0] H,
    input [15:0] V,
    output Hsync,
    output Vsync
    );
    
    /*  hsync is active low when in the range of 655 and 755 (inclusive)
        vsync is active low when in the range of 489 and 490
    */
    assign Hsync = ~( (H >= 16'd655) && (H <= 16'd750) );
    assign Vsync = ~( (V == 16'd489) || (V == 16'd490) );
    
endmodule
