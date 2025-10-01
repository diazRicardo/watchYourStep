`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 01:36:20 PM
// Design Name: 
// Module Name: countUD16L
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
module countUD16L(
    input clk_i,
    input up_i,
    input dw_i,
    input ld_i,
    input [15:0] Din_i,
    output[15:0] Q_o,
    output utc_o,
    output dtc_o
    );
    
    //  wires for connecting counters
    wire utc0, utc1, utc2, utc3;  
    wire dtc0, dtc1, dtc2, dtc3;
    
    // button signals for last three counters
    wire up1, up2, up3;   
    wire dw1, dw2, dw3;
    
    // first four bits Q[3:0]
    countUD4L counter0 (.clk_i(clk_i), .up_i(up_i), .dw_i(dw_i), .ld_i(ld_i), .din_i(Din_i[3:0]), .q_o(Q_o[3:0]), .utc_o(utc0), .dtc_o(dtc0));
    
    assign up1 = up_i & utc0;
    assign dw1 = dw_i & dtc0;
    
    // Q[7:4]
    countUD4L counter1 (.clk_i(clk_i), .up_i(up1), .dw_i(dw1), .ld_i(ld_i), .din_i(Din_i[7:4]), .q_o(Q_o[7:4]), .utc_o(utc1), .dtc_o(dtc1));
    
    assign up2 = up1 & utc1;
    assign dw2 = dw1 & dtc1;
    
    // Q[11:8]
    countUD4L counter2 (.clk_i(clk_i), .up_i(up2), .dw_i(dw2), .ld_i(ld_i), .din_i(Din_i[11:8]), .q_o(Q_o[11:8]), .utc_o(utc2), .dtc_o(dtc2));
    
    assign up3 = up2 & utc2;
    assign dw3 = dw2 & dtc2;
    
    // Q[15:12]
    countUD4L counter3 (.clk_i(clk_i), .up_i(up3), .dw_i(dw3), .ld_i(ld_i), .din_i(Din_i[15:12]), .q_o(Q_o[15:12]), .utc_o(utc3), .dtc_o(dtc3));
    
    assign utc_o = utc0 & utc1 & utc2 & utc3;
    assign dtc_o = dtc0 & dtc1 & dtc2 & dtc3;
   
endmodule
