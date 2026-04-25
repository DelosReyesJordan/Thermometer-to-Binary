// =============================================================
// temp_to_binary_top.v
// Top-level 4-bit temperature-to-binary encoder.
//
// Pipeline:
//   therm_raw  →  [bubble_remover]  →  therm_clean
//   therm_clean →  [TM2B_encoder]  →  binary_out
//
// Port descriptions:
//   therm_raw  [14:0]  Raw thermometer code from 15 comparators
//   binary_out  [3:0]  Encoded 4-bit binary temperature value
// =============================================================

module temp_to_binary_top (
    input  wire [14:0] therm_raw,    // Raw comparator outputs
    output wire [3:0]  binary_out    // 4-bit binary result
);

    // Internal wire carrying the bubble-suppressed thermometer code
    wire [14:0] therm_clean;

    // Stage 1: Remove single-bit glitch bubbles
    bubble_remover u_bubble_remover (
        .therm_raw   (therm_raw),
        .therm_clean (therm_clean)
    );

    // Stage 2: Encode clean thermometer code to binary
    TM2B_encoder u_encoder (
        .therm  (therm_clean),
        .binary (binary_out)
    );

endmodule
