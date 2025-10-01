`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 01:37:06 PM
// Design Name: 
// Module Name: countUD4L
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


module countUD4L(
    input clk_i,
    input up_i,
    input dw_i,
    input ld_i,
    input [3:0] din_i,
    output[3:0] q_o,
    output utc_o,
    output dtc_o
    );

    wire [3:0] next_val;
    wire [3:0] inc_val;
    wire [3:0] dec_val;
    wire [3:0] count_val;
    
    // calculates incremented value
    assign inc_val[0] = ~q_o[0];
    assign inc_val[1] = q_o[1] ^ q_o[0];
    assign inc_val[2] = q_o[2] ^ (q_o[1] & q_o[0]);
    assign inc_val[3] = q_o[3] ^ (q_o[2] & q_o[1] & q_o[0]);
    
    // calculates decremented value 
    assign dec_val[0] = ~q_o[0];
    assign dec_val[1] = q_o[1] ^ (~q_o[0]);
    assign dec_val[2] = q_o[2] ^ (~q_o[1] & ~q_o[0]);
    assign dec_val[3] = q_o[3] ^ (~q_o[2] & ~q_o[1] & ~q_o[0]);
    
    // select next values based on signal
    assign count_val = ({4{(up_i & ~dw_i)}} & inc_val) | // if up signal
                   ({4{(~up_i & dw_i)}} & dec_val) |       // else if down signal
                   ({4{(~(up_i ^ dw_i))}} & q_o);       // else no signal 
               
    // 4-bit mux
    // CHOOSES [3:0] din_i if ld_i = HIGH, CHOOSES [3:0] count_val if ld_i = LOW    
    mux mux4 (.A_i(count_val), .B_i(din_i), .Sel_i(ld_i), .Y_o(next_val));

    // FDRE flip-flops instances for each bit
    FDRE #(.INIT(1'b0)) bit0_ff (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(next_val[0]),
        .Q(q_o[0])
    );
    
    FDRE #(.INIT(1'b0)) bit1_ff (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(next_val[1]),
        .Q(q_o[1])
    );
    
    FDRE #(.INIT(1'b0)) bit2_ff (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(next_val[2]),
        .Q(q_o[2])
    );
    
    FDRE #(.INIT(1'b0)) bit3_ff (
        .C(clk_i),
        .R(1'b0),
        .CE(1'b1),
        .D(next_val[3]),
        .Q(q_o[3])
    );
    
    // the carry over bits
    assign utc_o = &q_o;  // q = 1111
    assign dtc_o = ~(|q_o); // q = 0000
    
    

endmodule
