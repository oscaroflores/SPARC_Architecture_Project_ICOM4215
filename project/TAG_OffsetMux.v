`timescale 1ns / 1ps

module TAG_OffsetMux #(
    parameter WIDTH = 30
)(
    input  wire               CALL,       // 1 → use offset30 (CALL instruction)
    input  wire [WIDTH-1:0]   offset22,   // Sign-extended imm22
    input  wire [WIDTH-1:0]   offset30,   // Raw 30-bit displacement (CALL)
    output reg  [WIDTH-1:0]   OffsetOut
);

    always @(*) begin
        case (CALL)
            1'b0: OffsetOut = offset22;
            1'b1: OffsetOut = offset30;
            default: OffsetOut = {WIDTH{1'bx}}; // prevents latch inference, safe default
        endcase
    end

endmodule