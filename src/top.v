`timescale 1ns / 1ps

module top(
    input clkin,
    input [15:0] sw,
    input btnU,
    input btnC,
    input btnR,
    input btnL,
    output [3:0] an,
    output [6:0] seg,
    output dp,
    output [3:0] vgaBlue,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,        
    output Vsync, 
    output Hsync,
    output [15:0] led
    );

    wire clk, digsel;
    labVGA_clks not_so_slow (.clkin(clkin), .greset(btnR), .clk(clk), .digsel(digsel));
    
    // ************ Edge detectors and registers for btnU Inputs *********************
    wire btnU_start, btnU_end;
    wire btnU_edge, btnU_rev_edge;
    
    
    edge_detector btnU_det (.btn_i(btnU), .clk_i(clk), .edge_o(btnU_edge));
    rev_edge_det btnU_rev_det (.btn_i(btnU), .clk_i(clk), .edge_o(btnU_rev_edge));

    // ************ Player state machine **********************************
    wire go, jump, coin_tag_pulse, on_platform, above_hole, four_frames, two_frames;
    wire reset_timer, start_game, point, move_player, flash_fall;
    
    // FF to denote that a game is in session, given by a pulse of start_game, reset when flash_fall
    wire game_in_session;
    FDRE #(.INIT(1'b0)) game_in_session_ff (
        .C(clk),
        .R(flash_fall),
        .CE(start_game),
        .D(1'b1),
        .Q(game_in_session));
        
    wire game_is_over;    
    FDRE #(.INIT(1'b0)) game_over_ff (
        .C(clk),
        .R(1'b0),
        .CE(flash_fall),
        .D(1'b1),
        .Q(game_is_over));    
    
    wire [15:0] player_head;
    wire [15:0] player_ass;
    wire [15:0] player_height_count;
    
    // this logic determines if the player is static/jmping or falling, based on the register value of flash_fall_active
    wire flash_fall_active;
    FDRE #(.INIT(1'b0)) ff_ff (
        .C(clk),
        .R(btnR),
        .CE(flash_fall),
        .D(1'b1),
        .Q(flash_fall_active));
        
    assign player_ass =  ({16{flash_fall_active}} & (16'd320 + fall_count)) |
                         ({16{~flash_fall_active}} & (16'd320 - player_height_count));
    
    assign player_head = player_ass - 16'd16;
 //   assign player_ass = 16'd320 - player_height_count;
    
    assign on_platform = (player_height_count == 16'd0);  
    assign jump = btnU_rev_edge;
    
    player_fsm player ( .clkin(clk), .go_i(go), .jump_i(jump), .coin_tag_i(coin_tag_pulse), .on_platform_i(on_platform),    // inputs
                        .above_hole_i(above_hole), .four_frames_i(four_frames), .two_frames_i(two_frames),
                        .reset_timer_o(reset_timer), .start_game_o(start_game), .point_o(point),                // outputs
                        .move_player_o(move_player), .flash_fall_o(flash_fall));
                        
    wire reset_ball_state, point_ball_fsm, flash_freeze;       // outputs for ball fsm                 
                        
    ball_fsm ball_machine (
        .clkin(clk),
        .game_in_session_i(game_in_session),
        .coin_tag_i(coin_tag_pulse),
        .two_sec_i(two_sec),
        .reset_ball_state_o(reset_ball_state),
        .point_o(point_ball_fsm), 
        .flash_freeze_o(flash_freeze));
        
    wire give_point;
    edge_detector single_point_det (.btn_i(point_ball_fsm), .clk_i(clk), .edge_o(give_point));

    // ff to denote that the player is in the air, resets to zero when the player touches ground again
    wire air_jordan;
    wire start_jump = move_player;
    wire end_jump = air_jordan & (player_height_count == 16'd0) & (power_bar_count == 16'd0);
    
    FDRE #(.INIT(1'b0)) move_player_ff ( 
        .C(clk), 
        .CE(start_jump | end_jump),  
        .D(start_jump),              // 1 when starting jump, 0 when ending
        .Q(air_jordan), 
        .R('b0)
    );
    
    // ************ Edge detectors for btnC     ***************************
    edge_detector btnC_det (.btn_i(btnC), .clk_i(clk), .edge_o(go));


    // ************ Frame counter - Edge detector **********************    
    wire one_frame;
    edge_detector frame_det (.btn_i(~Vsync), .clk_i(clk), .edge_o(one_frame));
 
 
    // ************ Two seconds counter  - for the ball ************************    
    wire [7:0] frame_count;
    wire [7:0] next_frame_count;
    
    wire inc_frame_count;
    assign inc_frame_count = one_frame && flash_freeze && (frame_count < 8'd120);
    
    assign next_frame_count = frame_count + 8'd1;
    
    FDRE #(.INIT(1'b0)) frame_counter_ff[7:0] ( 
        .C(clk), 
        .CE(inc_frame_count),  
        .D(next_frame_count),
        .Q(frame_count), 
        .R(~flash_freeze | btnR)  
    );
    
    assign two_sec = (frame_count >= 8'd120);
    
    // ************ Timer for the player flashing ************************    
    wire [15:0] frame_2_count;
    wire [15:0] next_frame_2_count;
    
    wire inc_frame_2_count;
    assign inc_frame_2_count = one_frame && game_is_over;
    
    assign next_frame_2_count = frame_2_count + 8'd1;
    
    FDRE #(.INIT(1'b0)) frame_2_counter_ff[15:0] ( 
        .C(clk), 
        .CE(inc_frame_2_count),  
        .D(next_frame_2_count),
        .Q(frame_2_count), 
        .R(frame_2_count == 16'd120)  
    );


    // ************ Point register and tag pulse detector ************************    
    wire [15:0] score;
    wire score_dum_utc, score_dum_dtc;
    countUD16L pointtt_counter (
        .clk_i(clk), 
        .up_i(point_ball_fsm), 
        .dw_i(1'b0), 
        .ld_i(1'b0), 
        .Din_i(16'b0), 
        .Q_o(score),
        .utc_o(score_dum_utc), 
        .dtc_o(score_dum_dtc)
    );
    
    
    // *********** Power Bar Counter ***********************************
    wire [15:0] power_bar_count;

    wire inc_power_bar, dec_power_bar;
    assign inc_power_bar = (power_bar_count != 16'd64) & btnU & one_frame & on_platform & ~game_is_over;
    assign dec_power_bar = (power_bar_count != 16'd0) & one_frame & ((on_platform & ~btnU) | ~on_platform)  ;
   
    wire pw_dum_utc, pw_dum_dtc;
    countUD16L power_bar_counter (
        .clk_i(clk), 
        .up_i(inc_power_bar), 
        .dw_i(dec_power_bar), 
        .ld_i(1'b0), 
        .Din_i(16'b0), 
        .Q_o(power_bar_count),
        .utc_o(pw_dum_utc), 
        .dtc_o(pw_dum_dtc)
    );
    
    
    // ************ Player jump counter ********************************    
    wire inc_player_height, dec_player_height;
    assign inc_player_height = (power_bar_count > 16'd1) & one_frame & air_jordan;     // Need at least 2 power to move 2 pixels
    assign dec_player_height = (player_height_count > 16'd1) & (power_bar_count == 16'd0) & one_frame & air_jordan;
        
    wire [15:0] height_plus_2 = player_height_count + 16'd2;
    wire [15:0] height_minus_2 = player_height_count - 16'd2;
    
    wire [15:0] player_height_next;
    assign player_height_next = ({16{inc_player_height}} & height_plus_2) |
                               ({16{dec_player_height}} & height_minus_2) |
                               ({16{~inc_player_height & ~dec_player_height}} & player_height_count);

    // STORES THE CURRENT PLAYER HEIGHT
    FDRE #(.INIT(1'b0)) player_height_reg[15:0] (
        .C(clk),
        .R(btnR),
        .CE(inc_player_height | dec_player_height),
        .D(player_height_next),
        .Q(player_height_count)
    );
    
    
    // ************* Falling player counter logic*******************************************************
    wire [15:0] fall_count;
    
    wire inc_falling_height;
    assign inc_falling_height = flash_fall_active & one_frame & (player_ass < 16'd472);
    
    wire [15:0] fall_plus_2 = fall_count + 16'd2;
    
    wire [15:0] falling_height_next;
    assign falling_height_next = ({16{inc_falling_height}} & fall_plus_2) |
                               ({16{~inc_falling_height}} & fall_count);

    // STORES THE CURRENT falling HEIGHT
    FDRE #(.INIT(1'b0)) falling_height_reg[15:0] (
        .C(clk),
        .R(btnR),
        .CE(inc_falling_height),
        .D(falling_height_next),
        .Q(fall_count)
    );
    
    
    // ************ Ball Position Logic *********************************************************
    wire [15:0] ball_counter;
    
    wire inc_ball;
    assign inc_ball = game_in_session & one_frame & (ball_counter < 16'd632) & ~flash_freeze;     // keep moving until COUNTER REACHES 632
    
    wire reset_ball;
    assign reset_ball = (ball_counter >= 16'd632) | (point_ball_fsm & game_in_session);
    
    wire [15:0] ball_plus_4 = ball_counter + 16'd4;
    
    wire [15:0] ball_position_next;
    assign ball_position_next = ({16{inc_ball}} & (ball_plus_4)) | 
                               ({16{~inc_ball}} & ball_counter);

    // STORES THE CURRENT BALL POSITION
    FDRE #(.INIT(1'b0)) ball_position_ff[15:0] (
        .C(clk),
        .R(reset_ball),
        .CE(inc_ball),
        .D(ball_position_next),
        .Q(ball_counter)
    );
    
    // random heigh generator
    wire [7:0] random_ball_height;
    LFSR ball_height_gen (.clk_i(clk), .q_o(random_ball_height));
    
    // sample it each time ball's reset signal goes off
    wire [7:0] ball_height;
    wire [7:0] pre_ball_height;
    
    FDRE #(.INIT(1'b0)) ball_height_ff[7:0] (
        .C(clk),
        .CE(reset_ball),
        .D(random_ball_height),
        .Q(pre_ball_height),
        .R(1'b0)
    );
    
    assign ball_height = (pre_ball_height & 8'h3F) + 8'd192;  // (0-63) + 192 = [192, 255]


    // ************ Hole Platform - moving logic ****************************
    wire [15:0] hole_left_edge;
    wire [15:0] hole_right_edge;
    wire reset_holes;
    
    // lfsr to generate random hole width
    wire [7:0] random_hole_width;
    LFSR hole_width_gen (.clk_i(clk), .q_o(random_hole_width));
    
    // sample it each time ball's reset signal goes off
    wire [7:0] hole_width;
    FDRE #(.INIT(1'b0)) hole_width_ff[7:0] (
        .C(clk),
        .CE(reset_holes),
        .D(random_hole_width),
        .Q(hole_width),
        .R(1'b0)
    );
    
    wire [7:0] final_hole_width;
    assign final_hole_width = (hole_width & 8'h1F) + 8'd41; 
    
    wire inc_hole_left_edge, inc_hole_right_edge;
    assign inc_hole_left_edge = game_in_session & one_frame & (hole_left_edge < 16'd632);
    assign inc_hole_right_edge = game_in_session & one_frame & ( (hole_left_edge >= final_hole_width) && (hole_right_edge < 16'd632) );

    assign reset_holes = (hole_left_edge >= 16'd632) && (hole_right_edge >= 16'd632);
    
    wire [15:0] hole_left_plus = hole_left_edge + 16'd1;
    wire [15:0] hole_right_plus = hole_right_edge + 16'd1;
    
    wire [15:0] hole_left_position_next;
    wire [15:0] hole_right_position_next;
    
    assign hole_left_position_next = ({16{inc_hole_left_edge}} & (hole_left_plus)) | 
                               ({16{~inc_hole_left_edge}} & hole_left_edge);
                               
    assign hole_right_position_next = ({16{inc_hole_right_edge}} & (hole_right_plus)) | 
                               ({16{~inc_hole_right_edge}} & hole_right_edge);                           

    // STORES THE CURRENT HOLE POSITION
    FDRE #(.INIT(1'b0)) hole_left_counter_ff[15:0] (
        .C(clk),
        .R(reset_holes),
        .CE(inc_hole_left_edge),
        .D(hole_left_position_next),
        .Q(hole_left_edge)
    );
    
    FDRE #(.INIT(1'b0)) hole_right_counter_ff[15:0] (
        .C(clk),
        .R(reset_holes),
        .CE(inc_hole_right_edge),
        .D(hole_right_position_next),
        .Q(hole_right_edge)
    );
    
    // logic for above hole
    assign above_hole = on_platform && ((16'd632 - hole_left_edge) < 16'd68) && ((16'd632 - hole_right_edge) > 16'd84);
    
    // ************ Pixel and Sync Logic *******************************
    wire [15:0] H;
    wire [15:0] V;
  
    PixelAddress px_address (
        .clkin(clk),
        .H(H),
        .V(V));
        
    wire Hsync_ff, Vsync_ff;
    Syncs syncs (
        .H(H),
        .V(V),
        .Hsync(Hsync_ff),
        .Vsync(Vsync_ff));
        
    FDRE #(.INIT(1'b1)) hsync_fdre (.C(clk), .R(1'b0), .CE(1'b1), .D(Hsync_ff), .Q(Hsync));
    FDRE #(.INIT(1'b1)) vsync_fdre (.C(clk), .R(1'b0), .CE(1'b1), .D(Vsync_ff), .Q(Vsync));
    
    // ***************************** RGB stuff ********************************
    wire active;
    assign active = (H < 16'd640) && (V < 16'd480);
    
    // Border detection 
    wire border;
    assign border = active && (
        (H < 16'd8) ||                    
        (H >= 16'd632) ||                 
        (V < 16'd8) ||                 
        (V >= 16'd472)       
        );

    // Wires for display objects
    wire platform, hole, ground, background, player_obj;
    
    assign platform = active && (V >= 16'd320) && (V < 16'd340) && !border && !hole;
    
    // Ground (below platform) detection, must be dark grey
    assign ground = active && (V >= 16'd340) && !border && !hole; 
    
    // Background is everything else in non-border active area
    assign background = active && (V < 16'd320) && !border;  // Above platform
    
    // Player detection
    assign player_visible = ~game_is_over | (game_is_over & frame_2_count[4]);
    assign player_obj = player_visible && active && (H > 16'd68) && (H <= 16'd84) && (V < player_ass) && (V >= player_head);
    
    // power bar dectection(
    wire [15:0] pw_upper_bound = 16'd96 - power_bar_count;
    wire power_bar_obj;
    assign power_bar_obj = active && (H > 16'd32) && (H <= 16'd48) && (V > pw_upper_bound) && (V <= 16'd96);
    
    // Ball dectection  
    assign ball_visible = ~flash_freeze | (flash_freeze & frame_count[4]);
     
    wire ball;
    assign ball = ball_visible &&                    // only show if not flashing
                  !border && 
                  (V >= ball_height) && (V < (ball_height + 16'd8)) &&   
                  (H >= (16'd632 - ball_counter)) && (H < (16'd632 - ball_counter + 16'd8)) && 
                  game_in_session &&
                  (ball_counter < 16'd632);            // ball is on screen
                 

    // ************ Collision detection ************************
    // Generate edge-detected coin tag signal
    wire coin_tag_raw, coin_tag_edge;
    assign coin_tag_raw = player_obj && ball;
    
    edge_detector coin_tag_det (.btn_i(coin_tag_raw), .clk_i(clk), .edge_o(coin_tag_edge));
    
    // Use edge-detected signal for FSM
    assign coin_tag_pulse = coin_tag_edge;


    assign hole = active && !border && 
                 (V >= 16'd320) &&   
                 (H >= (16'd632 - hole_left_edge)) && (H < (16'd632 - hole_right_edge));
                 
   // ************ Random Player Color Generator (Extra Credit) ****************************

    // Random color generator using another LFSR instance
    wire [7:0] random_player_color;
    LFSR player_color_gen (.clk_i(clk), .q_o(random_player_color));
    
    // Store player color components when a coin is tagged
    wire [3:0] player_red, player_green, player_blue;
    
    // Sample new random colors when coin is tagged (using coin_tag_edge or point_ball_fsm)
    FDRE #(.INIT(4'hF)) player_red_ff[3:0] (
        .C(clk),
        .CE(coin_tag_edge & ~flash_freeze),  // Change color when coin is tagged
        .D(random_player_color[3:0]),  // Use lower 4 bits for red
        .Q(player_red),
        .R(btnR)  // Reset to white on global reset
    );
    
    FDRE #(.INIT(4'h0)) player_green_ff[3:0] (
        .C(clk),
        .CE(coin_tag_edge & ~flash_freeze),  // Change color when coin is tagged
        .D(random_player_color[7:4]),  // Use upper 4 bits for green
        .Q(player_green),
        .R(btnR)  // Reset to white on global reset
    );
    
    FDRE #(.INIT(4'hF)) player_blue_ff[3:0] (
        .C(clk),
        .CE(coin_tag_edge & ~flash_freeze),  // Change color when coin is tagged
        .D({random_player_color[1:0], random_player_color[5:4]}),  // Mix bits for blue
        .Q(player_blue),
        .R(btnR)  // Reset to white on global reset
    );              
                 
                              
    // RGB outputs 
//    assign vgaRed   = ({4{border}}) |                   // red border
//                      ({4{player_obj}} & 4'hF) |        // player 
//                      ({4{ball}} & 4'hF);               // ball
                      
//    assign vgaGreen = ({4{platform}} & 4'hC) |          // platform
//                      ({4{ground}} & 4'h4) |            // ground
//                      {4{power_bar_obj}}  |             // power bar
//                      ({4{ball}} & 4'hF);               // ball
                      
//    assign vgaBlue  = ({4{platform}} & 4'hC) |          // platform  
//                      ({4{ground}} & 4'h4) |            // ground
//                      ({4{player_obj}} & 4'hF);         // player 
    assign vgaRed   = ({4{border}}) |                           // red border
                  ({4{player_obj}} & player_red) |          // CHANGED: random player red
                  ({4{ball}} & 4'hF);                       // ball (yellow)
                  
    assign vgaGreen = ({4{platform}} & 4'hC) |                  // platform
                      ({4{ground}} & 4'h4) |                    // ground
                      {4{power_bar_obj}}  |                     // power bar
                      ({4{ball}} & 4'hF) |                      // ball (yellow)
                      ({4{player_obj}} & player_green);         // CHANGED: random player green
                      
    assign vgaBlue  = ({4{platform}} & 4'hC) |                  // platform  
                      ({4{ground}} & 4'h4) |                    // ground
                      ({4{player_obj}} & player_blue);
    
    // *************** Hex display ***************************************
    wire [3:0] ring_output;   // wire to route ring counter output to the selector
    wire [3:0] to_hex;        // wire to route selector output to hex7seg
      
    // ring counter instance
    ring_counter rc (.Advance(digsel), .clkin(clk), .sel(ring_output));       
            
    // selector instance
    selector sel (.N_i(score), .sel_i(ring_output), .H_o(to_hex));
    
    // turn on the right anodes
    wire [3:0] pre_an;
    
    assign pre_an[1:0] = ring_output[1:0];
    assign pre_an[3:2] = 2'b0;
    assign an = ~pre_an;         
    
    // hex7seg instance   
    hex7seg sev_seg (.n(to_hex), .seg(seg));
  
    assign dp = 1'b1;
    
    
    // register to see if flash_freeze is ever activate
    wire flash_freeze_active;
    FDRE #(.INIT(1'b0)) flff_ff (.C(clk), .R(point_ball_fsm), .CE(flash_freeze), .D(1'b1), .Q(flash_freeze_active));
    
    assign led[0] = game_in_session;  // Should be 1 after pressing btnC
    assign led[1] = coin_tag_pulse;       // Should pulse when btnC pressed
    assign led[2] = flash_freeze;       // Check if this is working
    assign led[3] = two_sec;               // Should pulse when btnC pressed
    assign led[15:4] = 10'b0;
    
endmodule
