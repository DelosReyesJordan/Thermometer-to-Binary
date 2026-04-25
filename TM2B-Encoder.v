// =============================================================
// TM2B_encoder.v
// Thermometer-code to binary encoder (15-bit → 4-bit).
//
// Assumes the input is a valid (bubble-free) thermometer code:
// a contiguous block of 1s from bit 0 upward, then all 0s.
//
// Strategy: priority-encode by detecting the position of the
// highest set bit.  For a monotone thermometer code this is
// equivalent to summing the bits, but the case-based approach
// below synthesises to a compact gate tree.
//
// Encoding table (subset):
//   therm = 000_0000_0000_0000  -> binary = 0000  (0°)
//   therm = 000_0000_0000_0001  -  binary = 0001  (1°)
//   therm = 000_0000_0000_0011  →  binary = 0010  (2°)
//   therm = 000_0000_0000_0111  →  binary = 0011  (3°)
//   ...
//   therm = 111_1111_1111_1111  →  binary = 1111  (15°)
// =============================================================

module TM2B_encoder (
    input  wire [14:0] therm,   // Bubble-free thermometer code
    output reg  [3:0]  binary   // 4-bit binary result
);

    always @(*) begin
        casez (therm)
            // casez treats ? as don't-care; we match the leading
            // edge of the thermometer (highest 1 bit position).
            15'b000_0000_0000_0000 : binary = 4'd0;
            15'b000_0000_0000_0001 : binary = 4'd1;
            15'b000_0000_0000_0011 : binary = 4'd2;
            15'b000_0000_0000_0111 : binary = 4'd3;
            15'b000_0000_0000_1111 : binary = 4'd4;
            15'b000_0000_0001_1111 : binary = 4'd5;
            15'b000_0000_0011_1111 : binary = 4'd6;
            15'b000_0000_0111_1111 : binary = 4'd7;
            15'b000_0000_1111_1111 : binary = 4'd8;
            15'b000_0001_1111_1111 : binary = 4'd9;
            15'b000_0011_1111_1111 : binary = 4'd10;
            15'b000_0111_1111_1111 : binary = 4'd11;
            15'b000_1111_1111_1111 : binary = 4'd12;
            15'b001_1111_1111_1111 : binary = 4'd13;
            15'b011_1111_1111_1111 : binary = 4'd14;
            15'b111_1111_1111_1111 : binary = 4'd15;
            default                : binary = 4'd0;  // Invalid input → 0
        endcase
    end

endmodule
