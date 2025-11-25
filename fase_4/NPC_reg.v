`timescale 1ns/1ps
// =======================================
// NPC_reg: registro del Next Program Counter (NPC)
// =======================================
module NPC_reg (
    input clk,
    input reset,
    input LE,
    input [8:0] I,
    output reg [8:0] O
);
    always @(posedge clk) begin
        if (reset)
            O <= 9'd4;
        else if (LE)
            O <= I + 9'd4;
    end
endmodule