module ps2_control (
    input wire CLOCK_50,        // clock
    input wire reset,           // reset input (active high)
    input wire [7:0] scancode,
    input wire ps2_rec,
    output reg [2:0] move_sel_out,
    output reg execute_move
);

// states for E0h prefix and F0h break codes
reg [7:0] last_scancode;
reg E0_prefix; // 1 if the last scancode was 8'hE0
reg F0_prefix; // 1 if the last scancode was 8'hF0

// scan codes for keys
localparam SC_F = 8'h2B; // F key
localparam SC_B = 8'h32; // B key
localparam SC_L = 8'h4B; // L key
localparam SC_R = 8'h2D; // R key
localparam SC_U = 8'h3C; // U key
localparam SC_D = 8'h23; // D key

// move selection values
localparam SEL_F = 3'b000;
localparam SEL_B = 3'b001;
localparam SEL_L = 3'b010;
localparam SEL_R = 3'b011;
localparam SEL_T = 3'b100;
localparam SEL_D = 3'b101;
localparam SEL_NONE = 3'b110;

// sequential logic for state tracking
always @(posedge CLOCK_50) begin
    if (reset) begin
        last_scancode <= 8'h00;
        E0_prefix <= 1'b0;
        F0_prefix <= 1'b0;
        execute_move <= 1'b0;
    end else begin
        // reset single cycle execute_move pulse
        execute_move <= 1'b0;

        if (ps2_rec) begin
            // first check for break code (F0h)
            if (scancode == 8'hF0) begin
                // key release prefix detected
                F0_prefix <= 1'b1;
                E0_prefix <= 1'b0; // end any E0 sequence
            end 
            // second check for extended code (E0h)
            else if (scancode == 8'hE0) begin
                // extended key prefix detected
                E0_prefix <= 1'b1;
                F0_prefix <= 1'b0; // end any F0 sequence
            end 
            // finally process the move
            else begin
                // ignore if prev code was key-release code (F0) 
                if (F0_prefix) begin
                    F0_prefix <= 1'b0; // clear F0 flag
                end 
                // ignore if prev code was E0 (second byte of an extended key)
                else if (E0_prefix) begin
                    E0_prefix <= 1'b0; // clear E0 flag
                end 
                // regular make code (key press)
                else begin
                    F0_prefix <= 1'b0; // clear flags
                    E0_prefix <= 1'b0;
                    
                    case (scancode)
                        SC_F: begin move_sel_out <= SEL_F; execute_move <= 1'b1; end
                        SC_B: begin move_sel_out <= SEL_B; execute_move <= 1'b1; end
                        SC_L: begin move_sel_out <= SEL_L; execute_move <= 1'b1; end
                        SC_R: begin move_sel_out <= SEL_R; execute_move <= 1'b1; end
                        SC_U: begin move_sel_out <= SEL_T; execute_move <= 1'b1; end 
                        SC_D: begin move_sel_out <= SEL_D; execute_move <= 1'b1; end
                        default: begin move_sel_out <= SEL_NONE; end
                    endcase
                end
            end
            
            last_scancode <= scancode; // store current scancode
        end
        // if no data received, move_sel_out retains its last value until the next key press
    end
end

endmodule
