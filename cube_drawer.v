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
    localparam IDLE = 2'b00;
    localparam CLEARING = 2'b01;
    localparam DRAWING = 2'b10;
    
    reg [1:0] state;
    reg [14:0] pixel_counter;
    
    parameter SCREEN_CLEAR_END = 19200;
    parameter CUBE_DRAW_END = 3456;
    
    wire [7:0] clear_x = pixel_counter % 160;
    wire [6:0] clear_y = pixel_counter / 160;
    
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
                        state <= DRAWING;
                        pixel_counter <= 0;
                    end
                end
                
                DRAWING: begin
                    plot <= 1'b1;
                    x <= face_base_x + (sticker_col * 8) + local_x;
                    y <= face_base_y + (sticker_row * 8) + local_y;
                    
                    case (color_id)
                        3'b000: colour <= 9'b111111111; // white
                        3'b001: colour <= 9'b111111000; // yellow
                        3'b010: colour <= 9'b000000111; // blue
                        3'b011: colour <= 9'b000111000; // green
                        3'b100: colour <= 9'b111000000; // red
                        3'b101: colour <= 9'b111000111; // magenta
                        default: colour <= 9'b000000000;
                    endcase
                    
                    if (pixel_counter < CUBE_DRAW_END - 1) begin
                        pixel_counter <= pixel_counter + 1;
                    end else begin
                        state <= IDLE;
                        plot <= 1'b0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule
