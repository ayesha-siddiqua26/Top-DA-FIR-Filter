
module AKM ( 
    input signed [7:0] A, B,
    output signed [15:0] Result
);
    // Split into signed high and unsigned low
    wire signed [3:0] AH = A[7:4];
    wire [3:0] AL = A[3:0];
    wire signed [3:0] BH = B[7:4];
    wire [3:0] BL = B[3:0];

    // Booth-2 multipliers for P1 (signed × signed)
    wire signed [7:0] P1;
    Booth4x4 m1 (.A(AH), .B(BH), .P(P1));

    // P0 (unsigned × unsigned)
    wire [7:0] P0 = AL * BL;

    // 6-bit sums for P2 multiplier (no truncation)
    wire signed [5:0] sum_A = AH + $signed({1'b0, AL});
    wire signed [5:0] sum_B = BH + $signed({1'b0, BL});
    wire signed [11:0] P2 = sum_A * sum_B;  // Full 12-bit product

    // Final combination
    assign Result = (P1 << 8) + ((P2 - P1 - $signed({1'b0, P0})) << 4) + $signed({1'b0, P0});
endmodule