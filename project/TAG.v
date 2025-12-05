`timescale 1ns/1ps
// TAG: Target Address Generator
// Computes TA = B_PC + (Offset << 2)

module TAG #(
    parameter PC_WIDTH     = 9,
    parameter OFFSET_WIDTH = 30
)(
    input  wire [PC_WIDTH-1:0]     B_PC,
    input  wire [OFFSET_WIDTH-1:0] Offset,
    output reg  [PC_WIDTH-1:0]     TA
);

    // Internal expanded wires
    reg [31:0] pc_ext;
    reg [31:0] off_ext;
    reg [31:0] off_shift;
    reg [31:0] sum;

    always @(*) begin
        // Zero-extend PC (PC is not signed)
        pc_ext = { {(32-PC_WIDTH){1'b0}}, B_PC };

        // Sign-extend Offset (signed immediate)
        off_ext = { {(32-OFFSET_WIDTH){Offset[OFFSET_WIDTH-1]}}, Offset };

        // Shift left by 2 (word addressing)
        off_shift = off_ext << 2;

        // Add
        sum = pc_ext + off_shift;

        // Output low PC_WIDTH bits
        TA = sum[PC_WIDTH-1:0];
    end

endmodule