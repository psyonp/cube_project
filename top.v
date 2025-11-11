/*
 * main file that wraps logic
 *  and vga code together
 */


module top(...);
    // wires that connect modules together
    wire [2:0] cube_colors[0:53];
    wire [7:0] x;
    wire [6:0] y;
    wire [2:0] colour;
    wire plot;

    // 1. generates cube colors
    logic logic_unit(
        .clk(CLOCK_50),
        .resetn(resetn),
        .colors(cube_colors)
    );

    // 2. translate cube colors into pixel signals
    cube_drawer drawer(
        .clk(CLOCK_50),
        .resetn(resetn),
        .colors(cube_colors),
        .x(x),
        .y(y),
        .colour(colour),
        .plot(plot)
    );

    // 3. VGA library sends pixel signals to screen
    vga_adapter VGA(
        .resetn(resetn),
        .clock(CLOCK_50),
        .colour(colour),
        .x(x),
        .y(y),
        .plot(plot),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );
endmodule
