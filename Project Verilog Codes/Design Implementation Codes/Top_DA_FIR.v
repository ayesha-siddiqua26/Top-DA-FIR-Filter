module Top_DA_FIR (
    input clk, reset,
    input signed [7:0] data_in,
    output signed [15:0] data_out
);
    // Coefficient ROM
    (* rom_style = "distributed" *) reg signed [7:0] coeff [0:3];
    initial begin
        coeff[0] = 8'sh0A;  // +10
        coeff[1] = 8'shF2;  // -14
        coeff[2] = 8'sh1E;  // +30
        coeff[3] = 8'sh0D;  // +13
    end

    // Delay line
    reg signed [7:0] delay_reg [0:3];
    always @(posedge clk or posedge reset) begin
    if (reset) begin
        delay_reg[0] <= 0;
        delay_reg[1] <= 0;
        delay_reg[2] <= 0;
        delay_reg[3] <= 0;
    end else begin
        delay_reg[0] <= data_in;
        delay_reg[1] <= delay_reg[0];
        delay_reg[2] <= delay_reg[1];
        delay_reg[3] <= delay_reg[2];
    end
end

    // AKM multipliers
    wire signed [15:0] prod [0:3];
    AKM m0 (.A(delay_reg[0]), .B(coeff[0]), .Result(prod[0]));
    AKM m1 (.A(delay_reg[1]), .B(coeff[1]), .Result(prod[1]));
    AKM m2 (.A(delay_reg[2]), .B(coeff[2]), .Result(prod[2]));
    AKM m3 (.A(delay_reg[3]), .B(coeff[3]), .Result(prod[3]));

    // Truncation + sign extension
    wire signed [15:0] prod_trunc [0:3];
    assign prod_trunc[0] = {{4{prod[0][15]}}, prod[0][15:4]};  // 12→16 bits
    assign prod_trunc[1] = {{4{prod[1][15]}}, prod[1][15:4]};
    assign prod_trunc[2] = {{4{prod[2][15]}}, prod[2][15:4]};
    assign prod_trunc[3] = {{4{prod[3][15]}}, prod[3][15:4]};

    // Adder declarations (combinational)
    wire signed [15:0] sum_stage1_comb, sum_stage2_comb, sum_final_comb;
    wire cout1, cout2, cout3;

    // Stage 1: Parallel adders
    VLCSA add1 (.A(prod_trunc[0]), .B(prod_trunc[1]), .Cin(0), 
               .Sum(sum_stage1_comb), .Cout(cout1));
    VLCSA add2 (.A(prod_trunc[2]), .B(prod_trunc[3]), .Cin(0), 
               .Sum(sum_stage2_comb), .Cout(cout2));

    // Stage 2: Final sum
    VLCSA add3 (.A(sum_stage1), .B(sum_stage2), .Cin(0), 
               .Sum(sum_final_comb), .Cout(cout3));

    // Registered outputs
    reg signed [15:0] sum_stage1, sum_stage2, sum_final;
    always @(posedge clk) begin
        sum_stage1 <= sum_stage1_comb;
        sum_stage2 <= sum_stage2_comb;
        sum_final  <= sum_final_comb;
    end

    assign data_out = sum_final;
endmodule
module Adder4Bit (
    input [3:0] a, b,
    input cin,
    output [3:0] sum,
    output cout
);
    wire [4:0] carry;
    assign carry[0] = cin;
    
    // Bit-wise carry propagation
    assign sum[0] = a[0] ^ b[0] ^ carry[0];
    assign carry[1] = (a[0] & b[0]) | (a[0] & carry[0]) | (b[0] & carry[0]);
    
    assign sum[1] = a[1] ^ b[1] ^ carry[1];
    assign carry[2] = (a[1] & b[1]) | (a[1] & carry[1]) | (b[1] & carry[1]);
    
    assign sum[2] = a[2] ^ b[2] ^ carry[2];
    assign carry[3] = (a[2] & b[2]) | (a[2] & carry[2]) | (b[2] & carry[2]);
    
    assign sum[3] = a[3] ^ b[3] ^ carry[3];
    assign carry[4] = (a[3] & b[3]) | (a[3] & carry[3]) | (b[3] & carry[3]);
    
    assign cout = carry[4];
endmodule
module VLCSA (
    input [15:0] A, B,
    input Cin,
    output [15:0] Sum,
    output Cout
);
    wire [16:0] carry;
    assign carry[0] = Cin;
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 4) begin: adder_block
            wire [3:0] a = A[i +: 4];
            wire [3:0] b = B[i +: 4];
            wire [3:0] sum;
            wire block_cout;
            
            Adder4Bit adder (
                .a(a),
                .b(b),
                .cin(carry[i]),
                .sum(sum),
                .cout(block_cout)
            );
            
            // Fixed carry-skip condition
            assign carry[i+4] = block_cout;
            assign Sum[i +: 4] = sum;
        end
    endgenerate
    assign Cout = carry[16];
endmodule

module Booth4x4 (
    input signed [3:0] A, B,
    output signed [7:0] P
);
    // Booth-2 encoded multiplier (synthesis-optimized)
    assign P = A * B;  // Let synthesis tool infer Booth encoding
endmodule

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

    // 6-bit sums for reduced P2 multiplier
    wire signed [5:0] sum_A = AH + $signed({1'b0, AL});
    wire signed [5:0] sum_B = BH + $signed({1'b0, BL});
    wire signed [11:0] P2_full = sum_A * sum_B;
    wire signed [7:0] P2 = P2_full[11:4];  // Truncate lower 4 bits

    // Final combination
    assign Result = (P1 << 8) + ((P2 - P1 - $signed({1'b0, P0})) << 4) + $signed({1'b0, P0});
endmodule