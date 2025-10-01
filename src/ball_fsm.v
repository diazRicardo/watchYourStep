`timescale 1ns / 1ps

module ball_fsm(
    input clkin,
    input game_in_session_i,
    input coin_tag_i,
    input two_sec_i,
    output reset_ball_state_o,
    output flash_freeze_o,
    output point_o);

    wire [2:0] Q;
    wire [2:0] D;
    
    ball_Eq eqs (
        .game_in_session_i(game_in_session_i),
        .coin_tag_i(coin_tag_i),
        .two_sec_i(two_sec_i),
        .Q(Q),   
        .reset_ball_state_o(reset_ball_state_o),
        .point_o(point_o), 
        .flash_freeze_o(flash_freeze_o),
        .D(D));
    
    // Q[0] ff
    FDRE #(.INIT(1'b1)) Q0_FF (
        .C(clkin),
        .R(1'b0),
        .CE(1'b1),
        .D(D[0]),
        .Q(Q[0]));
    // Q[1] ff
    FDRE #(.INIT(1'b0)) Q1_FF (
        .C(clkin),
        .R(1'b0),
        .CE(1'b1),
        .D(D[1]),
        .Q(Q[1]));
    // Q[2] ff
    FDRE #(.INIT(1'b0)) Q2_FF (
        .C(clkin),
        .R(1'b0),
        .CE(1'b1),
        .D(D[2]),
        .Q(Q[2]));

endmodule

module ball_Eq(
    input game_in_session_i,
    input coin_tag_i,
    input two_sec_i,
    input [2:0] Q,   
    output reset_ball_state_o,
    output point_o,
    output flash_freeze_o,
    output [2:0] D);  // outputs the next state of FSM
    
    // logic equations to compute next states
    assign D[0] = Q[0]&~game_in_session_i | Q[1]&~game_in_session_i | Q[2]&~game_in_session_i ;
    
    assign D[1] = Q[0]&game_in_session_i | Q[1] & ~coin_tag_i & game_in_session_i | Q[2] & game_in_session_i & two_sec_i;
    
    assign D[2] = Q[2] & ~two_sec_i | Q[1] & coin_tag_i;
    
    // output logic
    assign reset_ball_state_o = Q[2] & game_in_session_i & two_sec_i;
    
    assign point_o = Q[2] & game_in_session_i & two_sec_i;
    
    assign flash_freeze_o = Q[2] & ~two_sec_i;

endmodule
