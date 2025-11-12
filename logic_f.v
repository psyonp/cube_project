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

module logic_f(
    input CLOCK_50,
    input [3:0] SW,
    input [1:0] KEY,
    output reg [2:0] f1 [0:8],  // front
    output reg [2:0] f2 [0:8],  // back
    output reg [2:0] f3 [0:8],  // left
    output reg [2:0] f4 [0:8],  // right
    output reg [2:0] f5 [0:8],  // top
    output reg [2:0] f6 [0:8],  // bottom
    output reg redraw
);

    // Internal state storage
    reg [2:0] front [0:8];
    reg [2:0] back  [0:8];
    reg [2:0] left  [0:8];
    reg [2:0] right [0:8];
    reg [2:0] top   [0:8];
    reg [2:0] bottom[0:8];

    wire resetn = KEY[0];
    wire reverse = SW[0];
    wire [2:0] move_sel = SW[3:1];

    // Enhanced button debouncing
    reg [19:0] debounce_counter;  // ~10ms at 50MHz
    reg key1_stable;
    reg key1_prev;
    wire key1_pressed;
    
    // Only trigger on stable low after debounce
    assign key1_pressed = !key1_stable && key1_prev;
    
    // Debounce logic
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            debounce_counter <= 0;
            key1_stable <= 1'b1;
            key1_prev <= 1'b1;
        end else begin
            key1_prev <= key1_stable;
            
            if (KEY[1] == key1_stable) begin
                debounce_counter <= 0;
            end else begin
                debounce_counter <= debounce_counter + 1;
                if (debounce_counter >= 500000) begin  // ~10ms
                    key1_stable <= KEY[1];
                    debounce_counter <= 0;
                end
            end
        end
    end

    wire [2:0] front_out_front [0:8], front_out_back [0:8], front_out_left [0:8];
    wire [2:0] front_out_right [0:8], front_out_top [0:8], front_out_bottom [0:8];

    wire [2:0] back_out_front [0:8], back_out_back [0:8], back_out_left [0:8];
    wire [2:0] back_out_right [0:8], back_out_top [0:8], back_out_bottom [0:8];

    wire [2:0] left_out_front [0:8], left_out_back [0:8], left_out_left [0:8];
    wire [2:0] left_out_right [0:8], left_out_top [0:8], left_out_bottom [0:8];

    wire [2:0] right_out_front [0:8], right_out_back [0:8], right_out_left [0:8];
    wire [2:0] right_out_right [0:8], right_out_top [0:8], right_out_bottom [0:8];

    wire [2:0] top_out_front [0:8], top_out_back [0:8], top_out_left [0:8];
    wire [2:0] top_out_right [0:8], top_out_top [0:8], top_out_bottom [0:8];

    wire [2:0] bottom_out_front [0:8], bottom_out_back [0:8], bottom_out_left [0:8];
    wire [2:0] bottom_out_right [0:8], bottom_out_top [0:8], bottom_out_bottom [0:8];

    // Instantiate all face modules with SEPARATE outputs
    front front_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(front_out_front), .fback_out(front_out_back), .fleft_out(front_out_left),
        .fright_out(front_out_right), .ftop_out(front_out_top), .fbottom_out(front_out_bottom)
    );

    back back_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(back_out_front), .fback_out(back_out_back), .fleft_out(back_out_left),
        .fright_out(back_out_right), .ftop_out(back_out_top), .fbottom_out(back_out_bottom)
    );

    left left_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(left_out_front), .fback_out(left_out_back), .fleft_out(left_out_left),
        .fright_out(left_out_right), .ftop_out(left_out_top), .fbottom_out(left_out_bottom)
    );

    right right_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(right_out_front), .fback_out(right_out_back), .fleft_out(right_out_left),
        .fright_out(right_out_right), .ftop_out(right_out_top), .fbottom_out(right_out_bottom)
    );

    top top_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(top_out_front), .fback_out(top_out_back), .fleft_out(top_out_left),
        .fright_out(top_out_right), .ftop_out(top_out_top), .fbottom_out(top_out_bottom)
    );

    bottom bottom_move(
        .ffront_in(front), .fback_in(back), .fleft_in(left), .fright_in(right),
        .ftop_in(top), .fbottom_in(bottom), .reverse(reverse),
        .ffront_out(bottom_out_front), .fback_out(bottom_out_back), .fleft_out(bottom_out_left),
        .fright_out(bottom_out_right), .ftop_out(bottom_out_top), .fbottom_out(bottom_out_bottom)
    );

    integer i;

    // Clock-based sequential logic with edge detection
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn) begin
            // Reset to solved cube
            for (i = 0; i < 9; i = i + 1) begin
                front[i]  <= 3'b000; // white
                back[i]   <= 3'b001; // yellow
                left[i]   <= 3'b010; // blue
                right[i]  <= 3'b011; // green
                top[i]    <= 3'b100; // red
                bottom[i] <= 3'b101; // orange/magenta
            end
            redraw <= 1'b1;  // Trigger initial draw
        end else begin
            // Generate single-cycle redraw pulse after state update
            if (redraw) begin
                redraw <= 1'b0;
            end
            
            // Execute rotation on button press
            if (key1_pressed) begin
                case (move_sel)
                    3'b000: begin // front
                        for (i = 0; i < 9; i = i + 1) begin
                            front[i]  <= front_out_front[i];
                            back[i]   <= front_out_back[i];
                            left[i]   <= front_out_left[i];
                            right[i]  <= front_out_right[i];
                            top[i]    <= front_out_top[i];
                            bottom[i] <= front_out_bottom[i];
                        end
                        redraw <= 1'b1;
                    end
            
                    3'b001: begin // back
                        for (i = 0; i < 9; i = i + 1) begin
                            front[i]  <= back_out_front[i];
                            back[i]   <= back_out_back[i];
                            left[i]   <= back_out_left[i];
                            right[i]  <= back_out_right[i];
                            top[i]    <= back_out_top[i];
                            bottom[i] <= back_out_bottom[i];
                        end
                        redraw <= 1'b1;
                    end
            
                    3'b010: begin // left
                        for (i = 0; i < 9; i = i + 1) begin
                            front[i]  <= left_out_front[i];
                            back[i]   <= left_out_back[i];
                            left[i]   <= left_out_left[i];
                            right[i]  <= left_out_right[i];
                            top[i]    <= left_out_top[i];
                            bottom[i] <= left_out_bottom[i];
                        end
                        redraw <= 1'b1;
                    end
            
                    3'b011: begin // right
                        for (i = 0; i < 9; i = i + 1) begin
                            front[i]  <= right_out_front[i];
                            back[i]   <= right_out_back[i];
                            left[i]   <= right_out_left[i];
                            right[i]  <= right_out_right[i];
                            top[i]    <= right_out_top[i];
                            bottom[i] <= right_out_bottom[i];
                        end
                        redraw <= 1'b1;
                    end
            
                    3'b100: begin // top
                        for (i = 0; i < 9; i = i + 1) begin
                            front[i]  <= top_out_front[i];
                            back[i]   <= top_out_back[i];
                            left[i]   <= top_out_left[i];
                            right[i]  <= top_out_right[i];
                            top[i]    <= top_out_top[i];
                            bottom[i] <= top_out_bottom[i];
                        end
                        redraw <= 1'b1;
                    end
            
                    3'b101: begin // bottom
                        for (i = 0; i < 9; i = i + 1) begin
                            front[i]  <= bottom_out_front[i];
                            back[i]   <= bottom_out_back[i];
                            left[i]   <= bottom_out_left[i];
                            right[i]  <= bottom_out_right[i];
                            top[i]    <= bottom_out_top[i];
                            bottom[i] <= bottom_out_bottom[i];
                        end
                        redraw <= 1'b1;
                    end
            
                    default: begin end // do nothing
                endcase
            end
        end
    end

    // Continuous assignment for outputs
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

