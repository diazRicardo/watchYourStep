`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2025 05:34:08 PM
// Design Name: 
// Module Name: old_top_working_hole
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


module old_top_working_hole();
/*
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
    
    // one ff to recognize that btn was pressed and released
//    FDRE #(.INIT(1'b0)) ff_btnU_start   ( .C(clk_i), .CE(btnU_edge), .D(btnU_edge), .Q(btnU_start), .R(platform));
//    FDRE #(.INIT(1'b0)) ff_btnU_end ( .C(clk_i), .CE(btnU_rev_edge), .D(btnU_rev_edge), .Q(btnU_end), .R(platform));

    // ************ Player state machine **********************************
    wire go, jump, coin_tag, on_platform, above_hole, four_frames, two_frames;
    wire reset_timer, start_game, point, move_player, flash_fall;
    
    // FF to denote that a game is in session, given by a pulse of start_game, reset when flash_fall
    wire game_in_session;
    FDRE #(.INIT(1'b0)) game_in_session_ff (
        .C(clk),
        .R(flash_fall),
        .CE(start_game),
        .D(1'b1),
        .Q(game_in_session));
    
    wire [15:0] player_head;
    wire [15:0] player_ass;
    wire [15:0] player_height_count;
    
    assign player_head = player_ass - 16'd16;
    assign player_ass = 16'd320 - player_height_count;
    
    assign on_platform = (player_height_count == 16'd0);  
    assign jump = btnU_rev_edge;
    
    player_fsm player ( .clkin(clk), .go_i(go), .jump_i(jump), .coin_tag_i(coin_tag), .on_platform_i(on_platform),    // inputs
                        .above_hole_i(above_hole), .four_frames_i(four_frames), .two_frames_i(two_frames),
                        .reset_timer_o(reset_timer), .start_game_o(start_game), .point_o(point),                // outputs
                        .move_player_o(move_player), .flash_fall_o(flash_fall));

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
    
    // Two frame counter using toggle flip-flop
//    wire frame_toggle;
//    FDRE #(.INIT(1'b0)) frame_2_ff ( .C(clk), .R(1'b0), .CE(one_frame), .D(~frame_toggle), .Q(frame_toggle));
    
//    // two frame pulse: high when toggle goes from 0 to 1
//    wire two_frame;
//    edge_detector two_frame_det (.btn_i(frame_toggle), .clk_i(clk), .edge_o(two_frame));
    
    // *********** Power Bar Counter ***********************************
    wire [15:0] power_bar_count;

    wire inc_power_bar, dec_power_bar;
    assign inc_power_bar = (power_bar_count != 16'd64) & btnU & one_frame & on_platform;
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
        
    // Calculate next height using basic logic operations
    wire [15:0] height_plus_2 = player_height_count + 16'd2;
    wire [15:0] height_minus_2 = player_height_count - 16'd2;
    
    // Select next value using AND/OR logic instead of ternary
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
    
    
    // ************ Ball Position Logic *********************************************************
    wire [15:0] ball_counter;
    
    wire inc_ball;
    assign inc_ball = game_in_session & one_frame & (ball_counter < 16'd632) ;     // keep moving until COUNTER REACHES 632
    
    wire reset_ball;
    assign reset_ball = (ball_counter >= 16'd632);
    
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
    FDRE #(.INIT(1'b0)) ball_height_ff[7:0] (
        .C(clk),
        .CE(reset_ball),
        .D(random_ball_height),
        .Q(ball_height),
        .R(1'b0)
    );
    
    assign ball_height = (ball_height & 8'h3F) + 8'd192;  // (0-63) + 192 = [192, 255]


    // ************ Hole Platform - moving logic ****************************
    wire [15:0] hole_left_edge;
    wire [15:0] hole_right_edge;
    wire [15:0] hole_counter;
    wire [15:0] hole_width;
    
    assign hole_left_edge = (hole_counter == 10'd0);
    assign hole_right_edge = (hole_counter == 10'd640);

    wire inc_hole;
    assign inc_hole = game_in_session & one_frame & (hole_counter < (16'd640 + 16'd50 - 16'd8)) ;

    wire reset_hole;
    assign reset_hole = (hole_counter >= (16'd640 + 16'd50 - 16'd8)); // this 50 will later be changed to the width of the hole
    
    wire [15:0] hole_plus = hole_counter + 16'd1;
    
    wire [15:0] hole_position_next;
    assign hole_position_next = ({16{inc_hole}} & (hole_plus)) | 
                               ({16{~inc_hole}} & hole_counter);

    // STORES THE CURRENT BALL POSITION
    FDRE #(.INIT(1'b0)) hole_position_ff[15:0] (
        .C(clk),
        .R(reset_hole),
        .CE(inc_hole),
        .D(hole_position_next),
        .Q(hole_counter)
    );
    
    
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
    assign player_obj = active && (H > 16'd68) && (H <= 16'd84) && (V < player_ass) && (V >= player_head);
    
    // power bar dectection(
    wire [15:0] pw_upper_bound = 16'd96 - power_bar_count;
    wire power_bar_obj;
    assign power_bar_obj = active && (H > 16'd32) && (H <= 16'd48) && (V > pw_upper_bound) && (V <= 16'd96);
    
    // Ball dectection
    wire ball;
    assign ball = //active && !border && 
                  !border && 
                 (V >= ball_height) && (V < (ball_height + 16'd8)) &&   
                 (H >= (16'd632 - ball_counter)) && (H < (16'd632 - ball_counter + 16'd8)) && 
                 game_in_session;
                 // the d's were art 620, but this was just a test from earlier they should've been 632 the "hole" time
    // old logic          
    wire hole;
    assign hole = active && !border && 
                 (V >= 16'd320) &&   
                 (H >= (16'd632 - hole_counter)) && (H < (16'd632 - hole_counter + 16'd50)) && 
                 game_in_session;
//    wire hole;
//    assign hole = active && !border && 
//                         (V >= 16'd320) && (V < 16'd340) &&  // Platform height
//                         (H >= hole_counter) && (H < hole_counter + 10'd50) && 
//                         game_in_session;
    
             
    // RGB outputs 
    assign vgaRed   = ({4{border}}) |                   // red border
                      ({4{player_obj}} & 4'hF) |        // player 
                      ({4{ball}} & 4'hF);               // ball
                      
    assign vgaGreen = ({4{platform}} & 4'hC) |          // platform
                      ({4{ground}} & 4'h4) |            // ground
                      {4{power_bar_obj}}  |             // power bar
                      ({4{ball}} & 4'hF);               // ball
                      
    assign vgaBlue  = ({4{platform}} & 4'hC) |          // platform  
                      ({4{ground}} & 4'h4) |            // ground
                      ({4{player_obj}} & 4'hF);         // player 
    
    
    // *************** Hex display ***************************************
    wire [3:0] ring_output;   // wire to route ring counter output to the selector
    wire [3:0] to_hex;        // wire to route selector output to hex7seg
      
    // ring counter instance
    ring_counter rc (.Advance(digsel), .clkin(clk), .sel(ring_output));       
            
    // selector instance
    selector sel (.N_i(ball_position_next), .sel_i(ring_output), .H_o(to_hex));
    
    // turn on the right anodes
    assign an = ~ring_output;         
    
    // hex7seg instance   
    hex7seg sev_seg (.n(to_hex), .seg(seg));
  
    assign dp = 1'b1;
    
    assign led[0] = game_in_session;  // Should be 1 after pressing btnC
    assign led[1] = start_game;       // Should pulse when btnC pressed
    assign led[2] = flash_fall;       // Check if this is working
    assign led[3] = go;               // Should pulse when btnC pressed
    assign led[15:4] = 10'b0;
    */
endmodule
