module tb_Top_DA_FIR();
    reg clk;
    reg reset;
    reg signed [7:0] data_in;
    wire signed [15:0] data_out;

    Top_DA_FIR dut (.*); // Instantiate DUT

    // Generate 10ns clock (100 MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        data_in = 0;

        // Release reset after 20ns (2 clock cycles)
        #20 reset = 0;

        // Apply impulse input (100) at next clock edge
        @(posedge clk);
        data_in <= 8'd100;
        @(posedge clk);
        data_in <= 8'd0;

        // Wait for pipeline latency (3 clock cycles)
        repeat (3) @(posedge clk);

        // Verify outputs at correct clock edges
        // First output (62)
        if (data_out !== 62) $error("First output mismatch: Expected 62, got %0d", data_out);
        @(posedge clk); // Next cycle

        // Second output (-88)
        if (data_out !== -88) $error("Second output mismatch: Expected -88, got %0d", data_out);
        @(posedge clk);

        // Third output (187)
        if (data_out !== 187) $error("Third output mismatch: Expected 187, got %0d", data_out);
        @(posedge clk);

        // Fourth output (81)
        if (data_out !== 81) $error("Fourth output mismatch: Expected 81, got %0d", data_out);
        @(posedge clk);

        // Verify output returns to zero
        if (data_out !== 0) $error("Output not zeroed: Expected 0, got %0d", data_out);

        $display("All tests passed!");
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_Top_DA_FIR);
    end
endmodule