/*
Switch 0 should be reversing the operation
KEY[0] is reset to start.
SW [3:1] should be choosing the state, which KEY[1] should execute.

000 should be move front
001 should be move back
010 should be move left
011 should be move right
100 should be move top
101 should be move bottom
110 should do nothing
111 should do nothing

*/
module logic(
    input [3:0] SW,
    input [1:0] KEY,
    output reg [2:0] f1 [0:8],  // front
    output reg [2:0] f2 [0:8],  // back
    output reg [2:0] f3 [0:8],  // left
    output reg [2:0] f4 [0:8],  // right
    output reg [2:0] f5 [0:8],  // top
    output reg [2:0] f6 [0:8]   // bottom
);

    // Internal state storage
    reg [2:0] front [0:8];
    reg [2:0] back  [0:8];
    reg [2:0] left  [0:8];
    reg [2:0] right [0:8];
    reg [2:0] top   [0:8];
    reg [2:0] bottom[0:8];

    wire reverse = SW[0];
    wire [2:0] move_sel = SW[3:1];

    wire [2:0] nf_front [0:8];
    wire [2:0] nf_back  [0:8];
    wire [2:0] nf_left  [0:8];
    wire [2:0] nf_right [0:8];
    wire [2:0] nf_top   [0:8];
    wire [2:0] nf_bottom[0:8];

    // Instantiate all face modules
    front front_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(nf_front), .fback_out(nf_back), .fleft_out(nf_left),
        .fright_out(nf_right), .ftop_out(nf_top), .fbottom_out(nf_bottom)
    );

    back back_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(nf_front), .fback_out(nf_back), .fleft_out(nf_left),
        .fright_out(nf_right), .ftop_out(nf_top), .fbottom_out(nf_bottom)
    );

    left left_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(nf_front), .fback_out(nf_back), .fleft_out(nf_left),
        .fright_out(nf_right), .ftop_out(nf_top), .fbottom_out(nf_bottom)
    );

    right right_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(nf_front), .fback_out(nf_back), .fleft_out(nf_left),
        .fright_out(nf_right), .ftop_out(nf_top), .fbottom_out(nf_bottom)
    );

    top top_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(nf_front), .fback_out(nf_back), .fleft_out(nf_left),
        .fright_out(nf_right), .ftop_out(nf_top), .fbottom_out(nf_bottom)
    );

    bottom bottom_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(nf_front), .fback_out(nf_back), .fleft_out(nf_left),
        .fright_out(nf_right), .ftop_out(nf_top), .fbottom_out(nf_bottom)
    );

    integer i;

    // Initial solved cube
    always @(negedge KEY[0]) begin
        for (i = 0; i < 9; i = i + 1) begin
            front[i]  <= 3'b000; // white
            back[i]   <= 3'b001; // yellow
            left[i]   <= 3'b010; // blue
            right[i]  <= 3'b011; // green
            top[i]    <= 3'b100; // red
            bottom[i] <= 3'b101; // orange
        end
    end

    // On KEY[1] press: execute selected rotation
    always @(negedge KEY[1]) begin
        case (move_sel)
            3'b000: begin // front
                for (i = 0; i < 9; i = i + 1) begin
                    front[i]  <= nf_front[i];
                    back[i]   <= nf_back[i];
                    left[i]   <= nf_left[i];
                    right[i]  <= nf_right[i];
                    top[i]    <= nf_top[i];
                    bottom[i] <= nf_bottom[i];
                end
            end

            3'b001: begin // back
                for (i = 0; i < 9; i = i + 1) begin
                    front[i]  <= nf_front[i];
                    back[i]   <= nf_back[i];
                    left[i]   <= nf_left[i];
                    right[i]  <= nf_right[i];
                    top[i]    <= nf_top[i];
                    bottom[i] <= nf_bottom[i];
                end
            end

            3'b010: begin // left
                for (i = 0; i < 9; i = i + 1) begin
                    front[i]  <= nf_front[i];
                    back[i]   <= nf_back[i];
                    left[i]   <= nf_left[i];
                    right[i]  <= nf_right[i];
                    top[i]    <= nf_top[i];
                    bottom[i] <= nf_bottom[i];
                end
            end

            3'b011: begin // right
                for (i = 0; i < 9; i = i + 1) begin
                    front[i]  <= nf_front[i];
                    back[i]   <= nf_back[i];
                    left[i]   <= nf_left[i];
                    right[i]  <= nf_right[i];
                    top[i]    <= nf_top[i];
                    bottom[i] <= nf_bottom[i];
                end
            end

            3'b100: begin // top
                for (i = 0; i < 9; i = i + 1) begin
                    front[i]  <= nf_front[i];
                    back[i]   <= nf_back[i];
                    left[i]   <= nf_left[i];
                    right[i]  <= nf_right[i];
                    top[i]    <= nf_top[i];
                    bottom[i] <= nf_bottom[i];
                end
            end

            3'b101: begin // bottom
                for (i = 0; i < 9; i = i + 1) begin
                    front[i]  <= nf_front[i];
                    back[i]   <= nf_back[i];
                    left[i]   <= nf_left[i];
                    right[i]  <= nf_right[i];
                    top[i]    <= nf_top[i];
                    bottom[i] <= nf_bottom[i];
                end
            end

            default: begin end // do nothing
        endcase
    end

    always @(*) begin
        for (i = 0; i < 9; i = i + 1) begin
            f1[i] = front[i];
            f2[i] = back[i];
            f3[i] = left[i];
            f4[i] = right[i];
            f5[i] = top[i];
            f6[i] = bottom[i];
        end
    end

endmodule


module front(
    input [2:0] ffront_in [0:8],
    input [2:0] fback_in [0:8], 
    input [2:0] fleft_in [0:8], 
    input [2:0] fright_in [0:8], 
    input [2:0] ftop_in [0:8],
    input [2:0] fbottom_in [0:8],
    input reverse,
    output reg [2:0] ffront_out [0:8],
    output reg [2:0] fback_out [0:8],
    output reg [2:0] fleft_out [0:8],
    output reg [2:0] fright_out [0:8],
    output reg [2:0] ftop_out [0:8],
    output reg [2:0] fbottom_out [0:8]
);

integer i;

always @(*) begin
    for (i = 0; i < 9; i = i + 1) begin
        fback_out[i] = fback_in[i];
        fleft_out[i] = fleft_in[i];
        fright_out[i] = fright_in[i];
        ftop_out[i] = ftop_in[i];
        fbottom_out[i] = fbottom_in[i];
    end

    if (!reverse) begin
        ffront_out[0] = ffront_in[6];
        ffront_out[1] = ffront_in[3];
        ffront_out[2] = ffront_in[0];
        ffront_out[3] = ffront_in[7];
        ffront_out[4] = ffront_in[4];
        ffront_out[5] = ffront_in[1];
        ffront_out[6] = ffront_in[8];
        ffront_out[7] = ffront_in[5];
        ffront_out[8] = ffront_in[2];

        {ftop_out[6], ftop_out[7], ftop_out[8]} = {fleft_in[8], fleft_in[5], fleft_in[2]};
        {fright_out[0], fright_out[3], fright_out[6]} = {ftop_in[6], ftop_in[7], ftop_in[8]};
        {fbottom_out[2], fbottom_out[1], fbottom_out[0]} = {fright_in[6], fright_in[3], fright_in[0]};
        {fleft_out[8], fleft_out[5], fleft_out[2]} = {fbottom_in[2], fbottom_in[1], fbottom_in[0]};
    end 
    else begin
        ffront_out[0] = ffront_in[2];
        ffront_out[1] = ffront_in[5];
        ffront_out[2] = ffront_in[8];
        ffront_out[3] = ffront_in[1];
        ffront_out[4] = ffront_in[4];
        ffront_out[5] = ffront_in[7];
        ffront_out[6] = ffront_in[0];
        ffront_out[7] = ffront_in[3];
        ffront_out[8] = ffront_in[6];

        {ftop_out[6], ftop_out[7], ftop_out[8]} = {fright_in[0], fright_in[3], fright_in[6]};
        {fright_out[0], fright_out[3], fright_out[6]} = {fbottom_in[2], fbottom_in[1], fbottom_in[0]};
        {fbottom_out[2], fbottom_out[1], fbottom_out[0]} = {fleft_in[8], fleft_in[5], fleft_in[2]};
        {fleft_out[8], fleft_out[5], fleft_out[2]} = {ftop_in[6], ftop_in[7], ftop_in[8]};
    end
end

endmodule


module back(
    input [2:0] ffront_in [0:8],
    input [2:0] fback_in [0:8], 
    input [2:0] fleft_in [0:8], 
    input [2:0] fright_in [0:8], 
    input [2:0] ftop_in [0:8],
    input [2:0] fbottom_in [0:8],
    input reverse,
    output reg [2:0] ffront_out [0:8],
    output reg [2:0] fback_out [0:8],
    output reg [2:0] fleft_out [0:8],
    output reg [2:0] fright_out [0:8],
    output reg [2:0] ftop_out [0:8],
    output reg [2:0] fbottom_out [0:8]
);

integer i;

always @(*) begin
    for (i = 0; i < 9; i = i + 1) begin
        ffront_out[i] = ffront_in[i];
        fleft_out[i]  = fleft_in[i];
        fright_out[i] = fright_in[i];
        ftop_out[i]   = ftop_in[i];
        fbottom_out[i]= fbottom_in[i];
    end

    if (!reverse) begin
        fback_out[0] = fback_in[6];
        fback_out[1] = fback_in[3];
        fback_out[2] = fback_in[0];
        fback_out[3] = fback_in[7];
        fback_out[4] = fback_in[4];
        fback_out[5] = fback_in[1];
        fback_out[6] = fback_in[8];
        fback_out[7] = fback_in[5];
        fback_out[8] = fback_in[2];

        {ftop_out[0], ftop_out[1], ftop_out[2]} = {fright_in[2], fright_in[5], fright_in[8]};
        {fright_out[2], fright_out[5], fright_out[8]} = {fbottom_in[8], fbottom_in[7], fbottom_in[6]};
        {fbottom_out[8], fbottom_out[7], fbottom_out[6]} = {fleft_in[6], fleft_in[3], fleft_in[0]};
        {fleft_out[6], fleft_out[3], fleft_out[0]} = {ftop_in[0], ftop_in[1], ftop_in[2]};
    end 
    else begin
        fback_out[0] = fback_in[2];
        fback_out[1] = fback_in[5];
        fback_out[2] = fback_in[8];
        fback_out[3] = fback_in[1];
        fback_out[4] = fback_in[4];
        fback_out[5] = fback_in[7];
        fback_out[6] = fback_in[0];
        fback_out[7] = fback_in[3];
        fback_out[8] = fback_in[6];

        {ftop_out[0], ftop_out[1], ftop_out[2]} = {fleft_in[6], fleft_in[3], fleft_in[0]};
        {fleft_out[6], fleft_out[3], fleft_out[0]} = {fbottom_in[8], fbottom_in[7], fbottom_in[6]};
        {fbottom_out[8], fbottom_out[7], fbottom_out[6]} = {fright_in[2], fright_in[5], fright_in[8]};
        {fright_out[2], fright_out[5], fright_out[8]} = {ftop_in[0], ftop_in[1], ftop_in[2]};
    end
end

endmodule


module left(
    input [2:0] ffront_in [0:8],
    input [2:0] fback_in [0:8], 
    input [2:0] fleft_in [0:8], 
    input [2:0] fright_in [0:8], 
    input [2:0] ftop_in [0:8],
    input [2:0] fbottom_in [0:8],
    input reverse,
    output reg [2:0] ffront_out [0:8],
    output reg [2:0] fback_out [0:8],
    output reg [2:0] fleft_out [0:8],
    output reg [2:0] fright_out [0:8],
    output reg [2:0] ftop_out [0:8],
    output reg [2:0] fbottom_out [0:8]
);

integer i;

always @(*) begin
    for (i = 0; i < 9; i = i + 1) begin
        ffront_out[i] = ffront_in[i];
        fback_out[i]  = fback_in[i];
        fright_out[i] = fright_in[i];
        ftop_out[i]   = ftop_in[i];
        fbottom_out[i]= fbottom_in[i];
    end

    if (!reverse) begin
        fleft_out[0] = fleft_in[6];
        fleft_out[1] = fleft_in[3];
        fleft_out[2] = fleft_in[0];
        fleft_out[3] = fleft_in[7];
        fleft_out[4] = fleft_in[4];
        fleft_out[5] = fleft_in[1];
        fleft_out[6] = fleft_in[8];
        fleft_out[7] = fleft_in[5];
        fleft_out[8] = fleft_in[2];

        {ftop_out[0], ftop_out[3], ftop_out[6]} = {ffront_in[0], ffront_in[3], ffront_in[6]};
        {fbottom_out[0], fbottom_out[3], fbottom_out[6]} = {fback_in[8], fback_in[5], fback_in[2]};
        {ffront_out[0], ffront_out[3], ffront_out[6]} = {fbottom_in[0], fbottom_in[3], fbottom_in[6]};
        {fback_out[8], fback_out[5], fback_out[2]} = {ftop_in[0], ftop_in[3], ftop_in[6]};
    end 
    else begin
        fleft_out[0] = fleft_in[2];
        fleft_out[1] = fleft_in[5];
        fleft_out[2] = fleft_in[8];
        fleft_out[3] = fleft_in[1];
        fleft_out[4] = fleft_in[4];
        fleft_out[5] = fleft_in[7];
        fleft_out[6] = fleft_in[0];
        fleft_out[7] = fleft_in[3];
        fleft_out[8] = fleft_in[6];

        {ftop_out[0], ftop_out[3], ftop_out[6]}       = {fback_in[8], fback_in[5], fback_in[2]};
        {fback_out[8], fback_out[5], fback_out[2]}   = {fbottom_in[0], fbottom_in[3], fbottom_in[6]};
        {fbottom_out[0], fbottom_out[3], fbottom_out[6]} = {ffront_in[0], ffront_in[3], ffront_in[6]};
        {ffront_out[0], ffront_out[3], ffront_out[6]} = {ftop_in[0], ftop_in[3], ftop_in[6]};
    end
end

endmodule


module right(
    input [2:0] ffront_in [0:8],
    input [2:0] fback_in [0:8], 
    input [2:0] fleft_in [0:8], 
    input [2:0] fright_in [0:8], 
    input [2:0] ftop_in [0:8],
    input [2:0] fbottom_in [0:8],
    input reverse,
    output reg [2:0] ffront_out [0:8],
    output reg [2:0] fback_out [0:8],
    output reg [2:0] fleft_out [0:8],
    output reg [2:0] fright_out [0:8],
    output reg [2:0] ftop_out [0:8],
    output reg [2:0] fbottom_out [0:8]
);

integer i;

always @(*) begin
    for (i = 0; i < 9; i = i + 1) begin
        ffront_out[i] = ffront_in[i];
        fback_out[i]  = fback_in[i];
        fleft_out[i]  = fleft_in[i];
        ftop_out[i]   = ftop_in[i];
        fbottom_out[i]= fbottom_in[i];
    end

    if (!reverse) begin
        fright_out[0] = fright_in[6];
        fright_out[1] = fright_in[3];
        fright_out[2] = fright_in[0];
        fright_out[3] = fright_in[7];
        fright_out[4] = fright_in[4];
        fright_out[5] = fright_in[1];
        fright_out[6] = fright_in[8];
        fright_out[7] = fright_in[5];
        fright_out[8] = fright_in[2];

        {ftop_out[2], ftop_out[5], ftop_out[8]} = {ffront_in[2], ffront_in[5], ffront_in[8]};
        {fbottom_out[2], fbottom_out[5], fbottom_out[8]} = {fback_in[6], fback_in[3], fback_in[0]};
        {ffront_out[2], ffront_out[5], ffront_out[8]} = {fbottom_in[2], fbottom_in[5], fbottom_in[8]};
        {fback_out[6], fback_out[3], fback_out[0]}   = {ftop_in[2], ftop_in[5], ftop_in[8]};
    end 
    else begin
        fright_out[0] = fright_in[2];
        fright_out[1] = fright_in[5];
        fright_out[2] = fright_in[8];
        fright_out[3] = fright_in[1];
        fright_out[4] = fright_in[4];
        fright_out[5] = fright_in[7];
        fright_out[6] = fright_in[0];
        fright_out[7] = fright_in[3];
        fright_out[8] = fright_in[6];

        {ftop_out[2], ftop_out[5], ftop_out[8]} = {fback_in[6], fback_in[3], fback_in[0]};
        {fback_out[6], fback_out[3], fback_out[0]} = {fbottom_in[2], fbottom_in[5], fbottom_in[8]};
        {fbottom_out[2], fbottom_out[5], fbottom_out[8]} = {ffront_in[2], ffront_in[5], ffront_in[8]};
        {ffront_out[2], ffront_out[5], ffront_out[8]} = {ftop_in[2], ftop_in[5], ftop_in[8]};
    end
end

endmodule

module top(
    input [2:0] ffront_in [0:8],
    input [2:0] fback_in [0:8], 
    input [2:0] fleft_in [0:8], 
    input [2:0] fright_in [0:8], 
    input [2:0] ftop_in [0:8],
    input [2:0] fbottom_in [0:8],
    input reverse,
    output reg [2:0] ffront_out [0:8],
    output reg [2:0] fback_out [0:8],
    output reg [2:0] fleft_out [0:8],
    output reg [2:0] fright_out [0:8],
    output reg [2:0] ftop_out [0:8],
    output reg [2:0] fbottom_out [0:8]
);

integer i;

always @(*) begin
    for (i = 0; i < 9; i = i + 1) begin
        ffront_out[i]  = ffront_in[i];
        fback_out[i]   = fback_in[i];
        fleft_out[i]   = fleft_in[i];
        fright_out[i]  = fright_in[i];
        fbottom_out[i] = fbottom_in[i];
    end

    if (!reverse) begin
        ftop_out[0] = ftop_in[6];
        ftop_out[1] = ftop_in[3];
        ftop_out[2] = ftop_in[0];
        ftop_out[3] = ftop_in[7];
        ftop_out[4] = ftop_in[4];
        ftop_out[5] = ftop_in[1];
        ftop_out[6] = ftop_in[8];
        ftop_out[7] = ftop_in[5];
        ftop_out[8] = ftop_in[2];

        {fright_out[0], fright_out[1], fright_out[2]} = {ffront_in[0], ffront_in[1], ffront_in[2]};
        {fback_out[0], fback_out[1], fback_out[2]}   = {fright_in[0], fright_in[1], fright_in[2]};
        {fleft_out[0], fleft_out[1], fleft_out[2]}   = {fback_in[0], fback_in[1], fback_in[2]};
        {ffront_out[0], ffront_out[1], ffront_out[2]}= {fleft_in[0], fleft_in[1], fleft_in[2]};
    end 
    else begin
        ftop_out[0] = ftop_in[2];
        ftop_out[1] = ftop_in[5];
        ftop_out[2] = ftop_in[8];
        ftop_out[3] = ftop_in[1];
        ftop_out[4] = ftop_in[4];
        ftop_out[5] = ftop_in[7];
        ftop_out[6] = ftop_in[0];
        ftop_out[7] = ftop_in[3];
        ftop_out[8] = ftop_in[6];

        {fright_out[0], fright_out[1], fright_out[2]} = {fback_in[0], fback_in[1], fback_in[2]};
        {fback_out[0], fback_out[1], fback_out[2]}   = {fleft_in[0], fleft_in[1], fleft_in[2]};
        {fleft_out[0], fleft_out[1], fleft_out[2]}   = {ffront_in[0], ffront_in[1], ffront_in[2]};
        {ffront_out[0], ffront_out[1], ffront_out[2]}= {fright_in[0], fright_in[1], fright_in[2]};
    end
end

endmodule

module bottom(
    input  [2:0] ffront_in [0:8],
    input  [2:0] fback_in  [0:8], 
    input  [2:0] fleft_in  [0:8], 
    input  [2:0] fright_in [0:8], 
    input  [2:0] ftop_in   [0:8],
    input  [2:0] fbottom_in[0:8],
    input  reverse,
    output reg [2:0] ffront_out [0:8],
    output reg [2:0] fback_out  [0:8],
    output reg [2:0] fleft_out  [0:8],
    output reg [2:0] fright_out [0:8],
    output reg [2:0] ftop_out   [0:8],
    output reg [2:0] fbottom_out[0:8]
);

integer i;

always @(*) begin
    for (i = 0; i < 9; i = i + 1) begin
        ftop_out[i]    = ftop_in[i];
        fback_out[i]   = fback_in[i];
    end

    if (!reverse) begin
        fbottom_out[0] = fbottom_in[6];
        fbottom_out[1] = fbottom_in[3];
        fbottom_out[2] = fbottom_in[0];
        fbottom_out[3] = fbottom_in[7];
        fbottom_out[4] = fbottom_in[4];
        fbottom_out[5] = fbottom_in[1];
        fbottom_out[6] = fbottom_in[8];
        fbottom_out[7] = fbottom_in[5];
        fbottom_out[8] = fbottom_in[2];
    end else begin
        fbottom_out[0] = fbottom_in[2];
        fbottom_out[1] = fbottom_in[5];
        fbottom_out[2] = fbottom_in[8];
        fbottom_out[3] = fbottom_in[1];
        fbottom_out[4] = fbottom_in[4];
        fbottom_out[5] = fbottom_in[7];
        fbottom_out[6] = fbottom_in[0];
        fbottom_out[7] = fbottom_in[3];
        fbottom_out[8] = fbottom_in[6];
    end

    if (!reverse) begin
        for (i = 0; i < 3; i = i + 1) begin
            ffront_out[6 + i]  = fleft_in[6 + i];
            fright_out[6 + i]  = ffront_in[6 + i];
            fback_out[6 + i]   = fright_in[6 + i];
            fleft_out[6 + i]   = fback_in[6 + i];
        end
    end else begin
        for (i = 0; i < 3; i = i + 1) begin
            ffront_out[6 + i]  = fright_in[6 + i];
            fright_out[6 + i]  = fback_in[6 + i];
            fback_out[6 + i]   = fleft_in[6 + i];
            fleft_out[6 + i]   = ffront_in[6 + i];
        end
    end

    for (i = 0; i < 6; i = i + 1) begin
        ffront_out[i] = ffront_in[i];
        fleft_out[i]  = fleft_in[i];
        fright_out[i] = fright_in[i];
    end
end

endmodule
