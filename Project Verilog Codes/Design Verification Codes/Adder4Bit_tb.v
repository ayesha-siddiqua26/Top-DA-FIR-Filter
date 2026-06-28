`timescale 1ns/1ps

module Adder4Bit_tb;
    // Test parameters
    parameter TOTAL_TESTS = 9;
    integer pass_count = 0;
    integer test_count = 0;
    
    // Inputs
    reg [3:0] a;
    reg [3:0] b;
    reg cin;
    
    // Outputs
    wire [3:0] sum;
    wire cout;
    
    // Instantiate UUT
    Adder4Bit uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    initial begin
        // Initialize
        a = 0;
        b = 0;
        cin = 0;
        #100;
        
        // Test cases
        run_test(4'h0, 4'h0, 1'b0, 4'h0, 1'b0);   // 0 + 0 + 0 = 0
        run_test(4'h5, 4'hA, 1'b0, 4'hF, 1'b0);   // 5 + 10 = 15
        run_test(4'h8, 4'h8, 1'b0, 4'h0, 1'b1);   // 8 + 8 = 16 (overflow)
        run_test(4'hF, 4'h1, 1'b0, 4'h0, 1'b1);   // 15 + 1 = 16 (overflow)
        run_test(4'hF, 4'hF, 1'b0, 4'hE, 1'b1);   // 15 + 15 = 30
        run_test(4'hA, 4'h5, 1'b1, 4'h0, 1'b1);   // 10 + 5 + 1 = 16
        run_test(4'h1, 4'h2, 1'b1, 4'h4, 1'b0);   // 1 + 2 + 1 = 4
        run_test(4'h7, 4'h8, 1'b0, 4'hF, 1'b0);   // 7 + 8 = 15
        run_test(4'hC, 4'hD, 1'b1, 4'hA, 1'b1);   // 12 + 13 + 1 = 26
        
        #100;
        // Final summary
        if (pass_count == TOTAL_TESTS) begin
            $display("\nSUCCESS: All %0d tests passed!", TOTAL_TESTS);
        end else begin
            $display("\nFAILURE: Passed %0d/%0d tests", pass_count, TOTAL_TESTS);
        end
        $finish;
    end
    
    task run_test;
        input [3:0] test_a;
        input [3:0] test_b;
        input test_cin;
        input [3:0] expected_sum;
        input expected_cout;
        begin
            test_count = test_count + 1;
            a = test_a;
            b = test_b;
            cin = test_cin;
            #10;
            
            if (sum !== expected_sum || cout !== expected_cout) begin
                $display("[Test %0d] ERROR: %h + %h + %b = {sum: %h, cout: %b} (Expected {sum: %h, cout: %b})",
                        test_count, test_a, test_b, test_cin, 
                        sum, cout, expected_sum, expected_cout);
            end
            else begin
                pass_count = pass_count + 1;
                $display("[Test %0d] PASS: %h + %h + %b = {sum: %h, cout: %b}",
                        test_count, test_a, test_b, test_cin, sum, cout);
            end
        end
    endtask
    
    // Waveform dump
    initial begin
        $dumpfile("adder4bit.vcd");
        $dumpvars(0, Adder4Bit_tb);
    end
endmodule