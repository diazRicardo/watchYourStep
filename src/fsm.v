`timescale 1ns / 1ps


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 08:10:57 PM
// Design Name: 
// Module Name: fsm
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
module fsm(
    input clkin,
    input go_i,
    input stop_L_i,
    input stop_R_i,
    input four_secs_i,
    input two_secs_i,
    input match_i,
    input game_i,
    output load_target_o,
    output reset_timer_o,
    output load_numbers_o,
    output inc_L_o,
    output inc_R_o,
    output dec_L_o,
    output dec_R_o,
    output flash_both_o,
    output flash_alt_o,
    output dp_high_o,
    output right_on_o,
    output right_off_o);
   
    // testing purposes only
    wire clk, digsel;   
    assign clk = clkin; 

    wire [6:0] Q;
    wire [6:0] D;
    
    fsmEq eqs (
        .go_i(go_i),
        .stop_L_i(stop_L_i),
        .stop_R_i(stop_R_i),
        .four_secs_i(four_secs_i),
        .two_secs_i(two_secs_i),
        .match_i(match_i),
        .game_i(game_i),
        .Q(Q),   
        .load_target_o(load_target_o),
        .reset_timer_o(reset_timer_o),
        .load_numbers_o(load_numbers_o),
        .inc_L_o(inc_L_o),
        .dec_L_o(dec_L_o),
        .inc_R_o(inc_R_o),
        .dec_R_o(dec_R_o),
        .flash_both_o(flash_both_o),
        .flash_alt_o(flash_alt_o),
        .dp_high_o(dp_high_o),
        .right_on_o(right_on_o),
        .right_off_o(right_off_o),
        .D(D));
    
    // Q[0] ff
    FDRE #(.INIT(1'b0)) Q0_FF (
        .C(clk),
        .R(1'b0),
        .CE(1'b1),
        .D(D[0]),
        .Q(Q[0]));
    // Q[1] ff
    FDRE #(.INIT(1'b0)) Q1_FF (
        .C(clk),
        .R(1'b0),
        .CE(1'b1),
        .D(D[1]),
        .Q(Q[1]));
    // Q[2] ff
    FDRE #(.INIT(1'b0)) Q2_FF (
        .C(clk),
        .R(1'b0),
        .CE(1'b1),
        .D(D[2]),
        .Q(Q[2]));
    // Q[3] ff
    FDRE #(.INIT(1'b0)) Q3_FF (
        .C(clk),
        .R(1'b0),
        .CE(1'b1),
        .D(D[3]),
        .Q(Q[3]));
    // Q[4] ff
    FDRE #(.INIT(1'b0)) Q4_FF (
        .C(clk),
        .R(1'b0),
        .CE(1'b1),
        .D(D[4]),
        .Q(Q[4]));
    // Q[5] ff
    FDRE #(.INIT(1'b0)) Q5_FF (
        .C(clk),
        .R(1'b0),
        .CE(1'b1),
        .D(D[5]),
        .Q(Q[5]));
    // Q[6] ff
    FDRE #(.INIT(1'b1)) Q6_FF (
        .C(clk),
        .R(1'b0),
        .CE(1'b1),
        .D(D[6]),
        .Q(Q[6]));

endmodule

module fsmEq(
    input go_i,
    input stop_L_i,
    input stop_R_i,
    input four_secs_i,
    input two_secs_i,
    input match_i,
    input game_i,
    input [6:0] Q,   // takes in current state of FSM
    output load_target_o,
    output reset_timer_o,
    output load_numbers_o,
    output inc_L_o,
    output inc_R_o,
    output dec_L_o,
    output dec_R_o,
    output flash_both_o,
    output flash_alt_o,
    output dp_high_o,
    output right_on_o,
    output right_off_o,
    output [6:0] D);  // outputs the next state of FSM
    
    // logic equations to compute next states
//    assign D[0] = Q[0]&~go_i&~stop_R_i&~stop_L_i |
////                Q[0]&~two_secs_i&stop_L_i&~stop_R_i | Q[0]&~two_secs_i&~stop_L_i&stop_R_i
//                | Q[0]&two_secs_i | Q[4]&go_i | Q[6]&go_i;
    assign D[0] = Q[0] & (~two_secs_i | (~stop_L_i & ~stop_R_i)) | // stay in Play if not 2 sec OR no buttons
                  Q[4] & go_i & ~game_i|                                  // enter Play from Round
                  Q[6] & go_i;                                  // enter Play from IDLE but never end
    assign D[1] = Q[0]&stop_L_i&stop_R_i&match_i&two_secs_i | Q[1]&~four_secs_i;
    
    assign D[2] = Q[0]&stop_L_i&~stop_R_i&match_i&two_secs_i | Q[0]&~stop_L_i&stop_R_i&match_i&two_secs_i |
                  Q[2]&~four_secs_i;
                  
    assign D[3] = Q[0]&stop_L_i&stop_R_i&~match_i&two_secs_i | 
                  Q[0]&stop_L_i&~stop_R_i&~match_i&two_secs_i |
                  Q[0]&~stop_L_i&stop_R_i&~match_i&two_secs_i |
                  Q[3]&~four_secs_i;
                  
    assign D[4] = Q[1]&four_secs_i | Q[2]&stop_L_i&four_secs_i | Q[2]&stop_R_i&four_secs_i |
                  Q[3]&four_secs_i | Q[4]&~go_i&~game_i;
                  
    assign D[5] = Q[4]&game_i | Q[5]&~go_i;
    
    assign D[6] = Q[6]&~go_i;
    
    // logic equations for outputs
    assign load_target_o = Q[4]&go_i | Q[6]&go_i;
    
    assign reset_timer_o = Q[0] & stop_R_i & stop_L_i & match_i & two_secs_i | 
                           Q[0] & ~stop_R_i & stop_L_i & match_i & two_secs_i | 
                           Q[0] & stop_R_i & ~stop_L_i & match_i & two_secs_i | 
                           Q[0] & stop_R_i & stop_L_i & ~match_i & two_secs_i |
                           Q[0] & stop_R_i & ~stop_L_i & ~match_i & two_secs_i |
                           Q[0] & ~stop_R_i & stop_L_i & ~match_i & two_secs_i |
                           Q[4] & go_i;
                           
    assign load_numbers_o = Q[0]&two_secs_i&~stop_L_i&~stop_R_i;
 
    assign flash_both_o = Q[3]&~four_secs_i;
    
    assign flash_alt_o = Q[1]&~four_secs_i | Q[2]&~four_secs_i;

    assign inc_L_o = Q[2]&stop_L_i&four_secs_i;
    
    assign inc_R_o = Q[2]&stop_R_i&four_secs_i;
    
    assign dec_L_o = Q[3]&four_secs_i&stop_L_i;
    
    assign dec_R_o = Q[3]&four_secs_i&stop_R_i;
    
    assign dp_high_o = game_i;
    
    assign right_on_o = Q[0]&two_secs_i;

    assign right_off_o = Q[4] & ~game_i&go_i;
endmodule
