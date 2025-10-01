`timescale 1ns / 1ps

module player_fsm(
    input clkin,
    input go_i,
    input jump_i,
    input coin_tag_i,
    input on_platform_i,
    input above_hole_i,
    input four_frames_i,
    input two_frames_i,
    output reset_timer_o,
    output start_game_o,
    output point_o,
    output move_player_o,
    output flash_fall_o);

    wire [3:0] Q;
    wire [3:0] D;
    
    fsmEq eqs (
        .go_i(go_i),
        .jump_i(jump_i),
        .coin_tag_i(coin_tag_i),
        .on_platform_i(on_platform_i),
        .above_hole_i(above_hole_i),
        .four_frames_i(four_frames_i),
        .two_frames_i(two_frames_i),
        .Q(Q),   
        .reset_timer_o(reset_timer_o),
        .start_game_o(start_game_o),
        .point_o(point_o), 
        .move_player_o(move_player_o),
        .flash_fall_o(flash_fall_o),
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
    // Q[3] ff
    FDRE #(.INIT(1'b0)) Q3_FF (
        .C(clkin),
        .R(1'b0),
        .CE(1'b1),
        .D(D[3]),
        .Q(Q[3]));


endmodule

module fsmEq(
    input go_i,
    input jump_i,
    input coin_tag_i,
    input on_platform_i,
    input above_hole_i,
    input four_frames_i,
    input two_frames_i,
    input [3:0] Q,   
    output reset_timer_o,
    output start_game_o,
    output point_o,
    output move_player_o,
    output flash_fall_o,
    output [3:0] D);  // outputs the next state of FSM
    
    // logic equations to compute next states
    assign D[0] = Q[0]&~go_i;
    assign D[1] = Q[0]&go_i | Q[1]&~jump_i | Q[2]&on_platform_i;
    assign D[2] = Q[2]&~on_platform_i | Q[1]&jump_i;
    assign D[3] = Q[3]&~go_i | Q[2]&on_platform_i&above_hole_i | Q[1]&on_platform_i&above_hole_i;
    
    // output logic
    assign start_game_o = Q[0]&go_i;
    assign reset_timer_o = Q[0]&go_i;
    assign move_player_o = Q[1]&jump_i;
    assign point_o = Q[2]&on_platform_i&coin_tag_i;
    assign flash_fall_o = Q[2]&on_platform_i&above_hole_i | Q[1]&on_platform_i&above_hole_i;    

endmodule
