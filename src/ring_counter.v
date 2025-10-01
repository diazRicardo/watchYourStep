`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 03:13:01 PM
// Design Name: 
// Module Name: ring_counter
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


module ring_counter (
    input Advance,
    input clkin,
    output [3:0] sel
    );
    
    // wires for FDRE inputs and outputs
    wire [3:0] q;
    
    // first FF with inverters to ensure it becomes 1 after reset
    wire first_d;
    assign first_d = q[3] | (~(|q)); // either take previous bit OR if all bits are 0, set to 1
    
    
    // we got FDRE instances for each bit
    // initialize first FF to 1
    FDRE #(.INIT(1'b1)) FDRE_0 (
        .C(clkin),
        .CE(Advance),
        .D(q[3]),
        .Q(q[0]),
        .R(1'b0)   
    );
    
    FDRE #(.INIT(1'b0)) FDRE_1 (
        .C(clkin),
        .CE(Advance),
        .D(q[0]),
        .Q(q[1]),
        .R(1'b0)    
    );
    
    FDRE #(.INIT(1'b0)) FDRE_2 (
        .C(clkin),
        .CE(Advance),
        .D(q[1]),
        .Q(q[2]),
        .R(1'b0)  
    );
    
    FDRE #(.INIT(1'b0)) FDRE_3 (
        .C(clkin),
        .CE(Advance),
        .D(q[2]),
        .Q(q[3]),
        .R(1'b0)    
    );
    
    assign sel = q;
    
endmodule
