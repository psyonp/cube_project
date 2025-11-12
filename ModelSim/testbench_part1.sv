`timescale 1ns / 1ps

module testbench();
    
    reg [3:0] SW;
    reg [1:0] KEY;
    
    wire [2:0] f1 [0:8];
    wire [2:0] f2 [0:8];
    wire [2:0] f3 [0:8];
    wire [2:0] f4 [0:8];
    wire [2:0] f5 [0:8];
    wire [2:0] f6 [0:8];
    
    // Instantiate DUT
    logic_f U1 (
        .SW(SW),
        .KEY(KEY),
        .f1(f1),
        .f2(f2),
        .f3(f3),
        .f4(f4),
        .f5(f5),
        .f6(f6)
    );
    
    // Test sequence
    initial begin
        // Initialize - both keys HIGH (not pressed)
        SW = 4'b0000;
        KEY = 2'b11;
        #100;
        
        // RESET - Press KEY[0]
        KEY[0] = 1'b0;
        #100;
        KEY[0] = 1'b1;
        #500;
        
        // FRONT move (SW[3:1]=000, SW[0]=0 for normal)
        SW = 4'b0000;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // RIGHT move (SW[3:1]=011)
        SW = 4'b0110;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // TOP move (SW[3:1]=100)
        SW = 4'b1000;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // BACK move (SW[3:1]=001)
        SW = 4'b0010;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // LEFT move (SW[3:1]=010)
        SW = 4'b0100;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // BOTTOM move (SW[3:1]=101)
        SW = 4'b1010;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // REVERSE FRONT (SW[0]=1)
        SW = 4'b0001;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // REVERSE RIGHT
        SW = 4'b0111;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // REVERSE TOP
        SW = 4'b1001;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // REVERSE LEFT
        SW = 4'b0101;
        #100;
        KEY[1] = 1'b0;
        #100;
        KEY[1] = 1'b1;
        #500;
        
        // Final RESET
        #100;
        KEY[0] = 1'b0;
        #100;
        KEY[0] = 1'b1;
        #500;
        
        $finish;
    end

endmodule
