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
            assign carry[i+4] = (block_cout) ? block_cout : carry[i];
            assign Sum[i +: 4] = sum;
        end
    endgenerate
    assign Cout = carry[16];
endmodule