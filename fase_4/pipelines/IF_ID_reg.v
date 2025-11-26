`timescale 1ns/1ps
// =======================================
// IF/ID: registro de instrucción y PC (B_PC)
// =======================================
module IF_ID_reg (
    input        clk, 
    input        reset, 
    input  [31:0] instr_in,
    input  [8:0]  pc_in,      // PC de la instrucción en IF
    output reg [31:0] instr_out,
    output reg [8:0]  pc_out  // B_PC hacia la etapa ID (para TAG)
);
    always @(posedge clk) begin
        if (reset) begin
            instr_out <= 32'd0;
            pc_out    <= 9'd0;
        end else begin
            instr_out <= instr_in;
            pc_out    <= pc_in;
        end
    end
endmodule