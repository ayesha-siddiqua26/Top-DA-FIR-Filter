module Booth4x4_tb;
    reg signed [3:0] A, B;
    wire signed [7:0] P;
    
    Booth4x4 uut (.A(A), .B(B), .P(P));
    
    initial begin
        $monitor("A=%4d, B=%4d → P=%4d", A, B, P);
        
        // Test various combinations
        A =  3;  B = 2;  #10;  // 3*2=6
        A = -3;  B = 2;  #10;  // -3*2=-6
        A = 4;   B = -5; #10;  // 4*(-5)=-20
        A = -8;  B = -8; #10;  // (-8)*(-8)=64
        A = 7;   B = 7;  #10;  // 7*7=49
        A = -8;  B = 7;  #10;  // (-8)*7=-56
        A = 0;   B = 5;  #10;  // 0*5=0
        A = 5;   B = 0;  #10;  // 5*0=0
        A = 1;   B = -1; #10;  // 1*(-1)=-1
        A = -4;  B = -3; #10;  // (-4)*(-3)=12
        
        $finish;
    end
endmodule