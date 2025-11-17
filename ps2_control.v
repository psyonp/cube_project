module ps2_control (
    input wire CLOCK_50,        // New: Clock input
    input wire reset,           // New: Synchronous reset input (active high)
    input wire [7:0] scancode,
    input wire ps2_rec,
    output reg [2:0] move_sel_out,
    output reg execute_move
);

// State for handling E0h prefix and F0h break code
reg [7:0] last_scancode;
reg E0_prefix; // 1 if the last scancode was 8'hE0
reg F0_prefix; // 1 if the last scancode was 8'hF0

// --- Scancodes for the keys ---
// Standard Make Codes (based on common keyboard layouts):
localparam SC_F = 8'h2B; // F key
localparam SC_B = 8'h32; // B key
localparam SC_L = 8'h4B; // L key
localparam SC_R = 8'h2D; // R key
localparam SC_U = 8'h3C; // U key (Top)
localparam SC_D = 8'h23; // D key (Bottom)
// Note: We use SC_U for 'Top' (was SC_T/8'h2C in your old code)

// --- Move Selection Values ---
localparam SEL_F = 3'b000;
localparam SEL_B = 3'b001;
localparam SEL_L = 3'b010;
localparam SEL_R = 3'b011;
localparam SEL_T = 3'b100; // Top
localparam SEL_D = 3'b101; // Bottom
localparam SEL_NONE = 3'b110;

// --- Sequential Logic for State Tracking ---
always @(posedge CLOCK_50) begin
    if (reset) begin
        last_scancode <= 8'h00;
        E0_prefix <= 1'b0;
        F0_prefix <= 1'b0;
        execute_move <= 1'b0;
    end else begin
        // Reset the single-cycle execute_move pulse
        execute_move <= 1'b0;

        if (ps2_rec) begin
            // 1. Check for Break code (F0h)
            if (scancode == 8'hF0) begin
                // Key-release prefix detected
                F0_prefix <= 1'b1;
                E0_prefix <= 1'b0; // End any E0 sequence
            end 
            // 2. Check for Extended code (E0h)
            else if (scancode == 8'hE0) begin
                // Extended key prefix detected (e.g., arrow keys)
                E0_prefix <= 1'b1;
                F0_prefix <= 1'b0; // End any F0 sequence
            end 
            // 3. Process the Move
            else begin
                // If the previous code was F0, this is the key-release code. IGNORE.
                if (F0_prefix) begin
                    F0_prefix <= 1'b0; // Clear the F0 flag for the next event
                    // No move execution
                end 
                // If the previous code was E0, this is the second byte of an extended key. IGNORE FOR NOW.
                // Assuming your F, B, L, R, U, D keys are *not* extended keys.
                else if (E0_prefix) begin
                    E0_prefix <= 1'b0; // Clear the E0 flag
                    // We aren't mapping any E0 codes, so no move execution
                end 
                // Regular Make Code (Key Press)
                else begin
                    F0_prefix <= 1'b0; // Clear flags
                    E0_prefix <= 1'b0;
                    
                    case (scancode)
                        SC_F: begin move_sel_out <= SEL_F; execute_move <= 1'b1; end
                        SC_B: begin move_sel_out <= SEL_B; execute_move <= 1'b1; end
                        SC_L: begin move_sel_out <= SEL_L; execute_move <= 1'b1; end
                        SC_R: begin move_sel_out <= SEL_R; execute_move <= 1'b1; end
                        // Note: SC_T (8'h2C) is the scancode for 'U' key!
                        SC_U: begin move_sel_out <= SEL_T; execute_move <= 1'b1; end 
                        SC_D: begin move_sel_out <= SEL_D; execute_move <= 1'b1; end
                        default: begin move_sel_out <= SEL_NONE; end
                    endcase
                end
            end
            
            last_scancode <= scancode; // Store current scancode
        end
        // If no data received, move_sel_out retains its last value until the next key press
    end
end

endmodule
