// =============================================================
// tb_temp_to_binary.v
// Simulation testbench for the 4-bit temperature-to-binary
// encoder system.
//
// Test plan:
//   1. All valid clean thermometer codes (0-15)
//   2. Single-bit bubble injected at every interior position
//   3. Multi-code sweep with $monitor output
// =============================================================

`timescale 1ns/1ps

module tb_temp_to_binary;

    // ── DUT ports ──────────────────────────────────────────────
    reg  [14:0] therm_raw;
    wire [3:0]  binary_out;

    // ── Instantiate DUT ────────────────────────────────────────
    temp_to_binary_top dut (
        .therm_raw  (therm_raw),
        .binary_out (binary_out)
    );

    // ── Internal signals for reporting ─────────────────────────
    integer errors;
    integer i;
    reg [14:0] expected_therm;
    reg [3:0]  expected_binary;

    // ── Helper task: apply input, wait, check output ───────────
    task apply_and_check;
        input [14:0] therm_in;
        input [3:0]  expected_bin;
        input [63:0] test_id;       // test number for display
        begin
            therm_raw = therm_in;
            #10;  // combinational settling time

            if (binary_out !== expected_bin) begin
                $display("FAIL [test %0d]  therm=%015b  expected=%0d  got=%0d",
                         test_id, therm_in, expected_bin, binary_out);
                errors = errors + 1;
            end else begin
                $display("PASS [test %0d]  therm=%015b  →  binary=%0d",
                         test_id, therm_in, binary_out);
            end
        end
    endtask

    // ── Main test sequence ─────────────────────────────────────
    initial begin
        errors    = 0;
        therm_raw = 15'b0;

        $display("=================================================");
        $display(" Test 1: Valid clean thermometer codes (0-15)");
        $display("=================================================");

        apply_and_check(15'b000_0000_0000_0000, 4'd0,  0);
        apply_and_check(15'b000_0000_0000_0001, 4'd1,  1);
        apply_and_check(15'b000_0000_0000_0011, 4'd2,  2);
        apply_and_check(15'b000_0000_0000_0111, 4'd3,  3);
        apply_and_check(15'b000_0000_0000_1111, 4'd4,  4);
        apply_and_check(15'b000_0000_0001_1111, 4'd5,  5);
        apply_and_check(15'b000_0000_0011_1111, 4'd6,  6);
        apply_and_check(15'b000_0000_0111_1111, 4'd7,  7);
        apply_and_check(15'b000_0000_1111_1111, 4'd8,  8);
        apply_and_check(15'b000_0001_1111_1111, 4'd9,  9);
        apply_and_check(15'b000_0011_1111_1111, 4'd10, 10);
        apply_and_check(15'b000_0111_1111_1111, 4'd11, 11);
        apply_and_check(15'b000_1111_1111_1111, 4'd12, 12);
        apply_and_check(15'b001_1111_1111_1111, 4'd13, 13);
        apply_and_check(15'b011_1111_1111_1111, 4'd14, 14);
        apply_and_check(15'b111_1111_1111_1111, 4'd15, 15);

        $display("");
        $display("=================================================");
        $display(" Test 2: Single-bit bubble injection");
        $display(" Expected value: 8 (therm = 0000000_11111111)");
        $display(" Bubble injected at each interior bit in turn");
        $display("=================================================");

        // Base pattern representing temperature 8: bits [7:0]=1, [14:8]=0
        // We inject a bubble (force a 1→0) at each interior position
        for (i = 1; i <= 6; i = i + 1) begin
            // Start from clean code for level 8: 0000000_11111111
            therm_raw = 15'b000_0000_1111_1111;
            therm_raw[i] = 1'b0;  // inject bubble at bit i
            #10;
            $display("  Bubble at bit %0d: raw=%015b  clean→binary=%0d  %s",
                     i, therm_raw, binary_out,
                     (binary_out === 4'd8) ? "PASS" : "FAIL");
            if (binary_out !== 4'd8) errors = errors + 1;
        end

        $display("");
        $display("=================================================");
        $display(" Test 3: Bubble at transition boundary");
        $display(" Verifies MSB boundary bit passes through");
        $display("=================================================");

        // Inject bubble at the highest set bit (bit 7, the transition edge)
        // The bubble remover should fix it since bit 8 = 0 and bit 6 = 1,
        // so T_clean[7] = 0 | (0 & 1) = 0 - this is NOT corrected (correctly)
        // because bit[i+1]=0, so the transition IS genuine. Output = 7.
        therm_raw = 15'b000_0000_0111_1111;  // level 7, then zero above
        #10;
        $display("  Clean level-7 input:  %015b  →  %0d  %s",
                 therm_raw, binary_out,
                 (binary_out === 4'd7) ? "PASS" : "FAIL");
        if (binary_out !== 4'd7) errors = errors + 1;

        // Now inject a bubble at bit 7 of a level-8 code
        therm_raw = 15'b000_0000_0111_1111 | 15'b000_0000_1000_0000; // bit 7 = 0 in level-8
        // That just produces the level-7 pattern - let's instead test
        // a bubble inside a mid-range level-12 code
        therm_raw = 15'b000_1111_1111_1111;  // level 12, clean
        therm_raw[5] = 1'b0;                 // inject bubble at bit 5
        #10;
        $display("  Bubble at bit 5 of level-12: %015b  →  %0d  %s",
                 therm_raw, binary_out,
                 (binary_out === 4'd12) ? "PASS" : "FAIL");
        if (binary_out !== 4'd12) errors = errors + 1;

        $display("");
        $display("=================================================");
        $display(" Summary: %0d error(s) found", errors);
        $display("=================================================");

        if (errors === 0)
            $display(" ALL TESTS PASSED");
        else
            $display(" SOME TESTS FAILED - review output above");

        $finish;
    end

    // ── Optional: dump waveforms for GTKWave ──────────────────
    initial begin
        $dumpfile("tb_temp_to_binary.vcd");
        $dumpvars(0, tb_temp_to_binary);
    end

endmodule
