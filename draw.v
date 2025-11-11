module cube_drawer(
    input clk,
    input resetn,
    input [2:0] colors[0:53],
    output reg [7:0] x,
    output reg [6:0] y,
    output reg [2:0] colour,
    output reg plot
);
    localparam STICKER_SIZE = 8;
    localparam FACE_SIZE = 3 * STICKER_SIZE;

    // pixel counter
    reg [12:0] pixel_index; // 0..3455 (54*64-1)

    wire [5:0] sticker_index = pixel_index / (STICKER_SIZE*STICKER_SIZE);
    wire [5:0] pixel_in_sticker = pixel_index % (STICKER_SIZE*STICKER_SIZE);
    wire [2:0] local_x = pixel_in_sticker % STICKER_SIZE;
    wire [2:0] local_y = pixel_in_sticker / STICKER_SIZE;

    // face offsets
    reg [7:0] face_x;
    reg [6:0] face_y;

    always @(*) begin
        case (sticker_index / 9)  // face number 0..5
            0: begin face_x = FACE_SIZE; face_y = 0; end            // U
            1: begin face_x = 0; face_y = FACE_SIZE; end            // L
            2: begin face_x = FACE_SIZE; face_y = FACE_SIZE; end    // F
            3: begin face_x = 2*FACE_SIZE; face_y = FACE_SIZE; end  // R
            4: begin face_x = 3*FACE_SIZE; face_y = FACE_SIZE; end  // B
            5: begin face_x = FACE_SIZE; face_y = 2*FACE_SIZE; end  // D
            default: begin face_x = 0; face_y = 0; end
        endcase
    end

    // local sticker coordinates (0..2)
    wire [1:0] sx = sticker_index % 3;           // column inside face
    wire [1:0] sy = (sticker_index % 9) / 3;     // row inside face

    always @(*) begin
        x = face_x + sx * STICKER_SIZE + local_x;
        y = face_y + sy * STICKER_SIZE + local_y;
        colour = map_color(colors[sticker_index]);
        plot = 1;
    end

    // increment pixel_index
    always @(posedge clk or negedge resetn) begin
        if (!resetn)
            pixel_index <= 0;
        else
            pixel_index <= (pixel_index == 54*STICKER_SIZE*STICKER_SIZE - 1) ? 0 : pixel_index + 1;
    end

    // color mapping function
    function [2:0] map_color;
        input [2:0] id;
        case (id)
            0: map_color = 3'b100; // red
            1: map_color = 3'b010; // green
            2: map_color = 3'b001; // blue
            3: map_color = 3'b110; // yellow
            4: map_color = 3'b011; // cyan
            5: map_color = 3'b111; // white
            default: map_color = 3'b000; // black
        endcase
    endfunction

endmodule
