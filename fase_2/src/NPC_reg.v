`timescale 1ns/1ps
// =======================================
// NPC_reg: registro del Next Program Counter (NPC)
// =======================================
module NPC_reg (
    input clk,
    input reset,
    input LE,
    input [8:0] D,
    output reg [8:0] Q
);
    always @(posedge clk) begin
        if (reset)
            Q <= 8'd4;
        else if (LE)
            Q <= D;
    end
endmodule