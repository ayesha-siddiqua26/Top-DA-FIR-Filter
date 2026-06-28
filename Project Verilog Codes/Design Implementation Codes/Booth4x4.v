module Booth4x4 (
    input signed [3:0] A, B,
    output signed [7:0] P
);
    // Booth-2 encoded multiplier (synthesis-optimized)
    assign P = A * B;  // Let synthesis tool infer Booth encoding
endmodule