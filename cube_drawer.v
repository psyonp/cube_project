module cube_drawer(
    input clk,
    input resetn,
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

    reg [14:0] pixel_counter;
    
    parameter SCREEN_CLEAR_END = 19200;
    parameter CUBE_DRAW_END = SCREEN_CLEAR_END + 3456;
    
    wire clearing_screen = (pixel_counter < SCREEN_CLEAR_END);
    wire [12:0] cube_pixel = pixel_counter - SCREEN_CLEAR_END;
    
    wire [7:0] clear_x = pixel_counter % 160;
    wire [6:0] clear_y = pixel_counter / 160;
    
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
    
    always @(*) begin
        case (face_num)
            3'd0: begin face_base_x = 24;  face_base_y = 0; end
            3'd1: begin face_base_x = 0;   face_base_y = 24; end
            3'd2: begin face_base_x = 24;  face_base_y = 24; end
            3'd3: begin face_base_x = 48;  face_base_y = 24; end
            3'd4: begin face_base_x = 72;  face_base_y = 24; end
            3'd5: begin face_base_x = 24;  face_base_y = 48; end
            default: begin face_base_x = 0; face_base_y = 0; end
        endcase
    end
    
    always @(*) begin
        case (face_num)
            3'd0: color_id = f5[sticker_in_face];  // For face 0
            3'd1: color_id = f3[sticker_in_face];  // For face 1
            3'd2: color_id = f1[sticker_in_face];  // For face 2
            3'd3: color_id = f4[sticker_in_face];  // For face 3
            3'd4: color_id = f2[sticker_in_face];  // For face 4
            3'd5: color_id = f6[sticker_in_face];  // For face 5
            default: color_id = 3'b000;  // Default to black if something goes wrong
        endcase
    end
    
    always @(*) begin
        if (clearing_screen) begin
            x = clear_x;
            y = clear_y;
            colour = 9'b000000000;  // Black background
            plot = 1'b1;
        end else if (pixel_counter < CUBE_DRAW_END) begin
            x = face_base_x + (sticker_col * 8) + local_x;
            y = face_base_y + (sticker_row * 8) + local_y;
            plot = 1'b1;
            
            case (color_id)
                3'b000: colour = 9'b111111111; // white
                3'b001: colour = 9'b111111000; // yellow
                3'b010: colour = 9'b000000111; // blue
                3'b011: colour = 9'b000111000; // green
                3'b100: colour = 9'b111000000; // red
                3'b101: colour = 9'b111000111; // magenta
                default: colour = 9'b000000000; // black
            endcase
        end else begin
            plot = 1'b0;  // Stop plotting
            x = 0;
            y = 0;
            colour = 9'b000000000;
        end
    end
    
    always @(posedge clk or negedge resetn) begin
        if (!resetn)
            pixel_counter <= 0;
        else begin
            if (pixel_counter < CUBE_DRAW_END - 1)
                pixel_counter <= pixel_counter + 1;
            else
                pixel_counter <= 0;
        end
    end
endmodule
