
module tb_AKM();
    reg signed [7:0] A, B;
    wire signed [15:0] Result;
    
    // Instantiate the Unit Under Test (UUT)
    AKM uut (.A(A), .B(B), .Result(Result));
    
    initial begin
        // Initialize Inputs
        A = 0;
        B = 0;
        
        // Test case 1: Basic positive numbers
        A = 8'h12;  // 18 in decimal
        B = 8'h34;  // 52 in decimal
        #10;
        $display("Test 1: %d * %d = %d", A, B, Result);
        
        // Test case 2: Negative numbers
        A = 8'hF0;  // -16 in decimal
        B = 8'hFF;  // -1 in decimal
        #10;
        $display("Test 2: %d * %d = %d", A, B, Result);
        
        // Test case 3: Mixed signs
        A = 8'h7F;  // 127 in decimal (max positive)
        B = 8'h80;  // -128 in decimal (max negative)
        #10;
        $display("Test 3: %d * %d = %d", A, B, Result);
        
        // Test case 4: Edge cases
        A = 8'h7F;  // 127
        B = 8'h7F;  // 127
        #10;
        $display("Test 4: %d * %d = %d", A, B, Result);
        
        A = 8'h80;  // -128
        B = 8'h80;  // -128
        #10;
        $display("Test 5: %d * %d = %d", A, B, Result);
        
        // Add more test cases here if needed
        
        $finish;
    end
endmodule