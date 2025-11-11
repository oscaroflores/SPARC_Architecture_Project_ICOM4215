`timescale 1ns/1ps
// =======================================
// IF/ID: registro de instrucción
// =======================================
module IF_ID_reg (
    input clk, 
    input reset, 
    input [31:0] instr_in, 
    output reg [31:0] instr_out
);
    always @(posedge clk) begin
        if (reset)
            instr_out <= 32'd0;
        else
            instr_out <= instr_in;
    end
endmodule