`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

    reg [3:0] SW;
    reg [1:0] KEY;
    reg CLOCK_50;
    // wire [9:0] LEDR;

    wire [2:0] f1 [0:8],  // front
    wire [2:0] f2 [0:8],  // back
    wire [2:0] f3 [0:8],  // left
    wire [2:0] f4 [0:8],  // right
    wire [2:0] f5 [0:8],  // top
    wire [2:0] f6 [0:8],  // bottom
    wire redraw

	initial begin
    CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
  initial begin
    // --- First move: front ---
    SW[3:0] = 3'b000;   // set move (front)
    KEY[1] = 1'b0;      // press input
    #10 KEY[1] = 1'b1;  // release input
    #10;                 // wait a bit

    // --- Second move: right ---
    SW[3:0] = 3'b011;   // set move (right)
    KEY[1] = 1'b0;      // press input
    #10 KEY[1] = 1'b1;  // release input
    #10;                 // wait

    // --- Reset ---
    KEY[0] = 1'b0;      // press reset
    #10 KEY[0] = 1'b1;  // release reset
    #10;

    // --- Third move: top ---
    SW[3:0] = 3'b100;   // set move (top)
    KEY[1] = 1'b0;      // press input
    #10 KEY[1] = 1'b1;  // release input
    #10;

    // --- Final reset ---
    KEY[0] = 1'b0;      // press reset
    #10 KEY[0] = 1'b1;  // release reset
    #10;

    $finish;             // end simulation
  end


	logic_f U1 (CLOCK_50, SW, KEY, f1, f2, f3, f4, f5, f6, redraw);

endmodule
