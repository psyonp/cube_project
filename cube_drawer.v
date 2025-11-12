module cube_drawer(
    input clk,
    input resetn,
    input redraw,  // Signal from logic module when cube state changes
    input [2:0] f1 [0:8],
    input [2:0] f2 [0:8],
    input [2:0] f3 [0:8],
    input [2:0] f4 [0:8],
    input [2:0] f5 [0:8],
    input [2:0] f6 [0:8],
    output reg [7:0] x,
    output reg [6:0] y,
    output reg [8:0] colour,
    output reg plot
);

    // State machine states
    localparam IDLE = 3'b000;
    localparam CLEARING = 3'b001;
    localparam DRAWING_TITLE = 3'b010;
    localparam DRAWING_CREDIT = 3'b011;
    localparam DRAWING = 3'b100;
    
    reg [2:0] state;
    reg [14:0] pixel_counter;
    
    parameter SCREEN_CLEAR_END = 19200;
    parameter TITLE_DRAW_END = 768;  // 12 chars * 8 width * 8 height
    parameter CREDIT_DRAW_END = 704;  // 11 chars * 8 width * 8 height
    parameter CUBE_DRAW_END = 3456;
    
    wire [7:0] clear_x = pixel_counter % 160;
    wire [6:0] clear_y = pixel_counter / 160;
    
    // Title drawing logic
    wire [9:0] title_pixel = pixel_counter;
    wire [3:0] char_num = title_pixel / 64;  // Which character (0-11)
    wire [5:0] pixel_in_char = title_pixel % 64;  // Which pixel in 8x8 char
    wire [2:0] char_x = pixel_in_char[2:0];
    wire [2:0] char_y = pixel_in_char[5:3];
    
    // Title: "Rubik's Cube"
    // Center at top: 12 chars * 8 pixels = 96 pixels wide
    // Start at (160-96)/2 = 32
    parameter TITLE_X_START = 32;
    parameter TITLE_Y_START = 4;
    
    wire [7:0] title_x = TITLE_X_START + (char_num * 8) + char_x;
    wire [6:0] title_y = TITLE_Y_START + char_y;
    
    // Credit: "By: PP, JW" (11 chars)
    parameter CREDIT_X_START = 4;
    parameter CREDIT_Y_START = 108;  // Near bottom (120 - 12 = 108)
    
    wire [7:0] credit_x = CREDIT_X_START + (char_num * 8) + char_x;
    wire [6:0] credit_y = CREDIT_Y_START + char_y;
    
    // Character bitmap function
    reg title_pixel_on;
    reg credit_pixel_on;
    
    // Title character bitmaps
    always @(*) begin
        title_pixel_on = 1'b0;
        if (char_x < 7 && char_y < 7) begin  // 7x7 font
            case (char_num)
                4'd0: begin // R
                    case (char_y)
                        3'd0: title_pixel_on = (char_x < 6);
                        3'd1: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd2: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd3: title_pixel_on = (char_x < 6);
                        3'd4: title_pixel_on = (char_x == 0 || char_x == 3);
                        3'd5: title_pixel_on = (char_x == 0 || char_x == 4);
                        3'd6: title_pixel_on = (char_x == 0 || char_x == 5 || char_x == 6);
                    endcase
                end
                4'd1: begin // u
                    case (char_y)
                        3'd0, 3'd1: title_pixel_on = 1'b0;
                        3'd2: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd3: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd4: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd5: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd6: title_pixel_on = (char_x > 0);
                    endcase
                end
                4'd2: begin // b
                    case (char_y)
                        3'd0: title_pixel_on = (char_x == 0);
                        3'd1: title_pixel_on = (char_x == 0);
                        3'd2: title_pixel_on = (char_x < 6);
                        3'd3: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd4: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd5: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd6: title_pixel_on = (char_x > 0 && char_x < 6);
                    endcase
                end
                4'd3: begin // i
                    case (char_y)
                        3'd0: title_pixel_on = (char_x == 3);
                        3'd1: title_pixel_on = 1'b0;
                        3'd2: title_pixel_on = (char_x == 2 || char_x == 3);
                        3'd3: title_pixel_on = (char_x == 3);
                        3'd4: title_pixel_on = (char_x == 3);
                        3'd5: title_pixel_on = (char_x == 3);
                        3'd6: title_pixel_on = (char_x > 1 && char_x < 6);
                    endcase
                end
                4'd4: begin // k
                    case (char_y)
                        3'd0: title_pixel_on = (char_x == 0);
                        3'd1: title_pixel_on = (char_x == 0);
                        3'd2: title_pixel_on = (char_x == 0 || char_x == 5 || char_x == 6);
                        3'd3: title_pixel_on = (char_x == 0 || char_x == 4);
                        3'd4: title_pixel_on = (char_x == 0 || char_x == 3);
                        3'd5: title_pixel_on = (char_x == 0 || char_x == 4);
                        3'd6: title_pixel_on = (char_x == 0 || char_x == 5 || char_x == 6);
                    endcase
                end
                4'd5: begin // '
                    case (char_y)
                        3'd0: title_pixel_on = (char_x == 2 || char_x == 3);
                        3'd1: title_pixel_on = (char_x == 2 || char_x == 3);
                        3'd2: title_pixel_on = (char_x == 3);
                        default: title_pixel_on = 1'b0;
                    endcase
                end
                4'd6: begin // s
                    case (char_y)
                        3'd0, 3'd1: title_pixel_on = 1'b0;
                        3'd2: title_pixel_on = (char_x > 0 && char_x < 6);
                        3'd3: title_pixel_on = (char_x == 1);
                        3'd4: title_pixel_on = (char_x > 1 && char_x < 6);
                        3'd5: title_pixel_on = (char_x == 5);
                        3'd6: title_pixel_on = (char_x > 1 && char_x < 6);
                    endcase
                end
                4'd7: begin // Space
                    title_pixel_on = 1'b0;
                end
                4'd8: begin // C
                    case (char_y)
                        3'd0: title_pixel_on = (char_x > 0 && char_x < 6);
                        3'd1: title_pixel_on = (char_x == 1 || char_x == 6);
                        3'd2: title_pixel_on = (char_x == 1);
                        3'd3: title_pixel_on = (char_x == 1);
                        3'd4: title_pixel_on = (char_x == 1);
                        3'd5: title_pixel_on = (char_x == 1 || char_x == 6);
                        3'd6: title_pixel_on = (char_x > 0 && char_x < 6);
                    endcase
                end
                4'd9: begin // u
                    case (char_y)
                        3'd0, 3'd1: title_pixel_on = 1'b0;
                        3'd2: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd3: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd4: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd5: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd6: title_pixel_on = (char_x > 0);
                    endcase
                end
                4'd10: begin // b (second 'b' in Cube)
                    case (char_y)
                        3'd0: title_pixel_on = (char_x == 0);
                        3'd1: title_pixel_on = (char_x == 0);
                        3'd2: title_pixel_on = (char_x < 6);
                        3'd3: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd4: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd5: title_pixel_on = (char_x == 0 || char_x == 6);
                        3'd6: title_pixel_on = (char_x > 0 && char_x < 6);
                    endcase
                end
                4'd11: begin // e (final letter)
                    case (char_y)
                        3'd0, 3'd1: title_pixel_on = 1'b0;
                        3'd2: title_pixel_on = (char_x > 0 && char_x < 6);
                        3'd3: title_pixel_on = (char_x == 1 || char_x == 6);
                        3'd4: title_pixel_on = (char_x == 1 || (char_x > 1 && char_x < 6));
                        3'd5: title_pixel_on = (char_x == 1);
                        3'd6: title_pixel_on = (char_x > 0 && char_x < 6);
                    endcase
                end
                default: title_pixel_on = 1'b0;
            endcase
        end
    end
    
    // Credit character bitmaps - "By: PP, JW"
    always @(*) begin
        credit_pixel_on = 1'b0;
        if (char_x < 7 && char_y < 7) begin
            case (char_num)
                4'd0: begin // B
                    case (char_y)
                        3'd0: credit_pixel_on = (char_x < 6);
                        3'd1: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd2: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd3: credit_pixel_on = (char_x < 6);
                        3'd4: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd5: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd6: credit_pixel_on = (char_x < 6);
                    endcase
                end
                4'd1: begin // y
                    case (char_y)
                        3'd0, 3'd1: credit_pixel_on = 1'b0;
                        3'd2: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd3: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd4: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd5: credit_pixel_on = (char_x > 0);
                        3'd6: credit_pixel_on = (char_x == 6);
                    endcase
                end
                4'd2: begin // :
                    case (char_y)
                        3'd0, 3'd1, 3'd6: credit_pixel_on = 1'b0;
                        3'd2: credit_pixel_on = (char_x == 3);
                        3'd3: credit_pixel_on = 1'b0;
                        3'd4: credit_pixel_on = (char_x == 3);
                        3'd5: credit_pixel_on = 1'b0;
                    endcase
                end
                4'd3: begin // Space
                    credit_pixel_on = 1'b0;
                end
                4'd4: begin // P
                    case (char_y)
                        3'd0: credit_pixel_on = (char_x < 6);
                        3'd1: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd2: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd3: credit_pixel_on = (char_x < 6);
                        3'd4: credit_pixel_on = (char_x == 0);
                        3'd5: credit_pixel_on = (char_x == 0);
                        3'd6: credit_pixel_on = (char_x == 0);
                    endcase
                end
                4'd5: begin // P
                    case (char_y)
                        3'd0: credit_pixel_on = (char_x < 6);
                        3'd1: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd2: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd3: credit_pixel_on = (char_x < 6);
                        3'd4: credit_pixel_on = (char_x == 0);
                        3'd5: credit_pixel_on = (char_x == 0);
                        3'd6: credit_pixel_on = (char_x == 0);
                    endcase
                end
                4'd6: begin // ,
                    case (char_y)
                        3'd0, 3'd1, 3'd2, 3'd3, 3'd4: credit_pixel_on = 1'b0;
                        3'd5: credit_pixel_on = (char_x == 3);
                        3'd6: credit_pixel_on = (char_x == 2);
                    endcase
                end
                4'd7: begin // Space
                    credit_pixel_on = 1'b0;
                end
                4'd8: begin // J
                    case (char_y)
                        3'd0: credit_pixel_on = (char_x > 0);
                        3'd1: credit_pixel_on = (char_x == 3);
                        3'd2: credit_pixel_on = (char_x == 3);
                        3'd3: credit_pixel_on = (char_x == 3);
                        3'd4: credit_pixel_on = (char_x == 3);
                        3'd5: credit_pixel_on = (char_x == 0 || char_x == 3);
                        3'd6: credit_pixel_on = (char_x > 0 && char_x < 4);
                    endcase
                end
                4'd9: begin // W
                    case (char_y)
                        3'd0: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd1: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd2: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd3: credit_pixel_on = (char_x == 0 || char_x == 6);
                        3'd4: credit_pixel_on = (char_x == 0 || char_x == 3 || char_x == 6);
                        3'd5: credit_pixel_on = (char_x == 0 || char_x == 3 || char_x == 6);
                        3'd6: credit_pixel_on = (char_x == 1 || char_x == 5);
                    endcase
                end
                4'd10: begin // Space
                    credit_pixel_on = 1'b0;
                end
                default: credit_pixel_on = 1'b0;
            endcase
        end
    end
    
    wire [12:0] cube_pixel = pixel_counter;
    wire [5:0] sticker_num;
    wire [5:0] pixel_in_sticker;
    wire [2:0] local_x, local_y;
    
    assign sticker_num = cube_pixel[12:6];
    assign pixel_in_sticker = cube_pixel[5:0];
    assign local_x = pixel_in_sticker[2:0];
    assign local_y = pixel_in_sticker[5:3];
    
    wire [2:0] face_num;
    wire [3:0] sticker_in_face;
    
    assign face_num = (sticker_num < 9) ? 3'd0 :
                      (sticker_num < 18) ? 3'd1 :
                      (sticker_num < 27) ? 3'd2 :
                      (sticker_num < 36) ? 3'd3 :
                      (sticker_num < 45) ? 3'd4 : 3'd5;
    
    assign sticker_in_face = sticker_num - (face_num * 9);
    
    wire [1:0] sticker_col = (sticker_in_face == 0 || sticker_in_face == 3 || sticker_in_face == 6) ? 2'd0 :
                              (sticker_in_face == 1 || sticker_in_face == 4 || sticker_in_face == 7) ? 2'd1 : 2'd2;
    
    wire [1:0] sticker_row = (sticker_in_face < 3) ? 2'd0 :
                              (sticker_in_face < 6) ? 2'd1 : 2'd2;
    
    reg [7:0] face_base_x;
    reg [6:0] face_base_y;
    reg [2:0] color_id;
    
    // Center the cube on 160x120 screen
    // Cube is 96x72 pixels (4 faces wide x 3 faces tall, each 24 pixels)
    // Center horizontally: (160 - 96) / 2 = 32
    // Center vertically: (120 - 72) / 2 = 24
    parameter H_OFFSET = 32;
    parameter V_OFFSET = 24;
    
    always @(*) begin
        case (face_num)
            3'd0: begin face_base_x = H_OFFSET + 24;  face_base_y = V_OFFSET + 0; end   // Top (U)
            3'd1: begin face_base_x = H_OFFSET + 0;   face_base_y = V_OFFSET + 24; end  // Left (L)
            3'd2: begin face_base_x = H_OFFSET + 24;  face_base_y = V_OFFSET + 24; end  // Front (F)
            3'd3: begin face_base_x = H_OFFSET + 48;  face_base_y = V_OFFSET + 24; end  // Right (R)
            3'd4: begin face_base_x = H_OFFSET + 72;  face_base_y = V_OFFSET + 24; end  // Back (B)
            3'd5: begin face_base_x = H_OFFSET + 24;  face_base_y = V_OFFSET + 48; end  // Bottom (D)
            default: begin face_base_x = 0; face_base_y = 0; end
        endcase
    end
    
    // Letter pattern logic for center stickers (sticker_in_face == 4)
    wire is_center_sticker = (sticker_in_face == 4);
    wire [2:0] letter_x = local_x - 3'd2;  // Offset to center the 3-wide letter
    wire [2:0] letter_y = local_y - 3'd2;  // Offset to center the 5-tall letter
    
    // Define letter patterns (3x5 pixel bitmaps)
    reg letter_pixel;
    always @(*) begin
        letter_pixel = 1'b0;
        if (is_center_sticker && letter_x < 3 && letter_y < 5) begin
            case (face_num)
                3'd0: begin // U (Top)
                    case (letter_y)
                        3'd0: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd1: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd2: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd3: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd4: letter_pixel = 1'b1;
                        default: letter_pixel = 1'b0;
                    endcase
                end
                3'd1: begin // L (Left)
                    case (letter_y)
                        3'd0: letter_pixel = (letter_x == 0);
                        3'd1: letter_pixel = (letter_x == 0);
                        3'd2: letter_pixel = (letter_x == 0);
                        3'd3: letter_pixel = (letter_x == 0);
                        3'd4: letter_pixel = 1'b1;
                        default: letter_pixel = 1'b0;
                    endcase
                end
                3'd2: begin // F (Front)
                    case (letter_y)
                        3'd0: letter_pixel = 1'b1;
                        3'd1: letter_pixel = (letter_x == 0);
                        3'd2: letter_pixel = 1'b1;
                        3'd3: letter_pixel = (letter_x == 0);
                        3'd4: letter_pixel = (letter_x == 0);
                        default: letter_pixel = 1'b0;
                    endcase
                end
                3'd3: begin // R (Right)
                    case (letter_y)
                        3'd0: letter_pixel = (letter_x != 2);
                        3'd1: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd2: letter_pixel = (letter_x != 2);
                        3'd3: letter_pixel = (letter_x == 0 || letter_x == 1);
                        3'd4: letter_pixel = (letter_x == 0 || letter_x == 2);
                        default: letter_pixel = 1'b0;
                    endcase
                end
                3'd4: begin // B (Back)
                    case (letter_y)
                        3'd0: letter_pixel = (letter_x != 2);
                        3'd1: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd2: letter_pixel = (letter_x != 2);
                        3'd3: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd4: letter_pixel = (letter_x != 2);
                        default: letter_pixel = 1'b0;
                    endcase
                end
                3'd5: begin // D (Bottom)
                    case (letter_y)
                        3'd0: letter_pixel = (letter_x != 2);
                        3'd1: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd2: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd3: letter_pixel = (letter_x == 0 || letter_x == 2);
                        3'd4: letter_pixel = (letter_x != 2);
                        default: letter_pixel = 1'b0;
                    endcase
                end
                default: letter_pixel = 1'b0;
            endcase
        end
    end
    
    always @(*) begin
        case (face_num)
            3'd0: color_id = f5[sticker_in_face];
            3'd1: color_id = f3[sticker_in_face];
            3'd2: color_id = f1[sticker_in_face];
            3'd3: color_id = f4[sticker_in_face];
            3'd4: color_id = f2[sticker_in_face];
            3'd5: color_id = f6[sticker_in_face];
            default: color_id = 3'b000;
        endcase
    end
    
    // State machine
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= CLEARING;
            pixel_counter <= 0;
            plot <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    plot <= 1'b0;
                    if (redraw) begin
                        state <= CLEARING;
                        pixel_counter <= 0;
                    end
                end
                
                CLEARING: begin
                    plot <= 1'b1;
                    x <= clear_x;
                    y <= clear_y;
                    colour <= 9'b000000000;
                    
                    if (pixel_counter < SCREEN_CLEAR_END - 1) begin
                        pixel_counter <= pixel_counter + 1;
                    end else begin
                        state <= DRAWING_TITLE;
                        pixel_counter <= 0;
                    end
                end
                
                DRAWING_TITLE: begin
                    plot <= 1'b1;
                    x <= title_x;
                    y <= title_y;
                    colour <= title_pixel_on ? 9'b111111111 : 9'b000000000;
                    
                    if (pixel_counter < TITLE_DRAW_END - 1) begin
                        pixel_counter <= pixel_counter + 1;
                    end else begin
                        state <= DRAWING_CREDIT;
                        pixel_counter <= 0;
                    end
                end
                
                DRAWING_CREDIT: begin
                    plot <= 1'b1;
                    x <= credit_x;
                    y <= credit_y;
                    colour <= credit_pixel_on ? 9'b111111111 : 9'b000000000;
                    
                    if (pixel_counter < CREDIT_DRAW_END - 1) begin
                        pixel_counter <= pixel_counter + 1;
                    end else begin
                        state <= DRAWING;
                        pixel_counter <= 0;
                    end
                end
                
                DRAWING: begin
                    plot <= 1'b1;
                    x <= face_base_x + (sticker_col * 8) + local_x;
                    y <= face_base_y + (sticker_row * 8) + local_y;
                    
                    // Check if pixel is on border (first or last pixel of 8x8 cell)
                    if (local_x == 0 || local_x == 7 || local_y == 0 || local_y == 7) begin
                        colour <= 9'b000000000; // Black border
                    end else if (letter_pixel) begin
                        colour <= 9'b000000000; // Black letter on center sticker
                    end else begin
                        case (color_id)
                            3'b000: colour <= 9'b111111111; // white
                            3'b001: colour <= 9'b111111000; // yellow
                            3'b010: colour <= 9'b000000111; // blue
                            3'b011: colour <= 9'b000111000; // green
                            3'b100: colour <= 9'b111000000; // red
                            3'b101: colour <= 9'b111000111; // magenta
                            default: colour <= 9'b000000000;
                        endcase
                    end
                    
                    if (pixel_counter >= CUBE_DRAW_END - 1) begin
                        pixel_counter <= 0;
                        state <= IDLE;
                    end else begin
                        pixel_counter <= pixel_counter + 1;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule
