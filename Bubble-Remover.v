// =============================================================
// bubble_remover.v
// Removes single-bit glitch bubbles from a thermometer code.
//
// A "bubble" is a spurious 0 embedded in a run of 1s, caused
// by comparator skew during fast input transitions.
//
// Correction rule (applied to each interior bit):
//   T_clean[i] = T_raw[i] | (T_raw[i+1] & T_raw[i-1])
//
// If both neighbours are 1, the bit is forced to 1.
// Boundary bits (MSB and LSB) are passed through unchanged
// because they have only one neighbour.
//
// For a 4-bit binary output we need 2^4 - 1 = 15 comparator
// bits, so the thermometer bus is 15 bits wide.
// =============================================================

module bubble_remover (
    input  wire [14:0] therm_raw,   // Raw thermometer code from comparators
    output wire [14:0] therm_clean  // Bubble-suppressed thermometer code
);

    // --- Boundary bits: pass through unchanged ---
    assign therm_clean[0]  = therm_raw[0];
    assign therm_clean[14] = therm_raw[14];

    // --- Interior bits: apply OR/AND suppression ---
    genvar i;
    generate
        for (i = 1; i <= 13; i = i + 1) begin : suppress
            assign therm_clean[i] = therm_raw[i]
                                  | (therm_raw[i+1] & therm_raw[i-1]);
        end
    endgenerate

endmodule
