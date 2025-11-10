`timescale 1ns/1ps
// =======================================
// Mux de control para la Unidad de Control
// - Si S = 0: pasan las señales originales de la CU
// - Si S = 1: se inyecta un NOP (todo ceros)
// =======================================

module CU_Mux_Control (
    input S,
    input [31:0] id_ctrl_in,
    output [31:0] id_ctrl_out
);
    assign id_ctrl_out = (S) ? 32'b0 : id_ctrl_in;
endmodule