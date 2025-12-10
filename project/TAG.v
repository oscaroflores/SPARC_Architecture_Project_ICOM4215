`timescale 1ns/1ps
// TAG: Target Address Generator
// Computes TA = B_PC + (Offset << 2)
// VERIFICAR
module TAG (
    input  wire [8:0]      B_PC,
    input  wire [29:0]     Offset,
    input  wire            CALL,

    output reg  [8:0]     TA
);

    // Internal expanded wires
    reg [31:0] pc_ext;
    reg [31:0] off_ext;
    reg [31:0] off_shift;
    reg [31:0] sum;

    always @(*) begin
        // Zero-extend B_PC
        pc_ext    = {{(32-9){B_PC[8]}}, B_PC };
        // Sign-extend Offset
        if (CALL) begin
            off_ext = { {(32-30){Offset[29]}}, Offset };
        end else begin
            off_ext = { {(32-22){Offset[21]}}, Offset };
        end
        // Shift left by 2 (word addressing)
        off_shift = off_ext << 2;

        // Add
        sum = pc_ext + off_shift;
        
        // Output low PC_WIDTH bits
        TA = sum[8:0];
    end

endmodule