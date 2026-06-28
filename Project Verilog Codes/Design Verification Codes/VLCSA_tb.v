module VLCSA_tb;
    reg [15:0] A, B;
    reg Cin;
    wire [15:0] Sum;
    wire Cout;
    integer passed = 0, failed = 0;

    VLCSA uut (A, B, Cin, Sum, Cout);

    initial begin
        $dumpfile("vlcsa.vcd");
        $dumpvars(0, VLCSA_tb);
        
        // Critical test cases
        verify_add(16'h0000, 16'h0000, 0, 16'h0000, 0);
        verify_add(16'hFFFF, 16'h0001, 0, 16'h0000, 1);
        
        
        // Auto-verification
        
        
        $display("\nTest Results:");
        $display("Passed: %0d | Failed: %0d", passed, failed);
        $finish;
    end

    task verify_add;
        input [15:0] a, b;
        input cin;
        input [15:0] exp_sum;
        input exp_cout;
        begin
            A = a; B = b; Cin = cin;
            #20;
            if (Sum !== exp_sum || Cout !== exp_cout) begin
                $display("FAIL: %h+%h+%b=%h_%h (Expected %h_%h)",
                        a, b, cin, Cout, Sum, exp_cout, exp_sum);
                failed = failed+1;
            end else begin
                 passed = passed+1;
            end
        end
    endtask

    
endmodule