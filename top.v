module cube(
    input CLOCK_50,
    input [3:0] SW,
    input [1:0] KEY,
    output [9:0] VGA_R,
    output [9:0] VGA_G,
    output [9:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output VGA_CLK
);

    // Reset signal
    wire resetn = KEY[0];

    // Wires for the 6 cube faces
    wire [2:0] f1 [0:8];   // front
    wire [2:0] f2 [0:8];   // back
    wire [2:0] f3 [0:8];   // left
    wire [2:0] f4 [0:8];   // right
    wire [2:0] f5 [0:8];   // top
    wire [2:0] f6 [0:8];   // bottom

    // Wires connecting drawer to VGA
    wire [7:0] x;
    wire [6:0] y;
    wire [2:0] colour;
    wire plot;

    // 1. Logic module - generates cube state based on user moves
    logic_f logic_unit(
        .SW(SW),
        .KEY(KEY),
        .f1(f1),
        .f2(f2),
        .f3(f3),
        .f4(f4),
        .f5(f5),
        .f6(f6)
    );

    // 2. Cube drawer - translates cube state into pixel signals
    cube_drawer drawer(
        .clk(CLOCK_50),
        .resetn(resetn),
        .f1(f1),
        .f2(f2),
        .f3(f3),
        .f4(f4),
        .f5(f5),
        .f6(f6),
        .x(x),
        .y(y),
        .colour(colour),
        .plot(plot)
    );

    // 3. VGA adapter - sends pixel data to VGA display
    vga_adapter VGA(
        .resetn(resetn),
        .clock(CLOCK_50),
        .color(colour),
        .x(x),
        .y(y),
        .write(plot),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );
    defparam VGA.RESOLUTION = "160x120";
    
endmodule
