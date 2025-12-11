`timescale 1ns/1ps
// =======================================
// PC_reg: registro del Program Counter (PC)
// =======================================
module PC_reg (
    input clk,
    input reset,
    input LE,
    input [8:0] I,
    output reg [8:0] O
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            O <= 9'd0;
        else if (LE)
            O <= I;
    end
endmodule