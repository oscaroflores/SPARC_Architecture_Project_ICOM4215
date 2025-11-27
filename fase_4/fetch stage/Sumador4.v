`timescale 1ns / 1ps

// Sumador especializado: R = A + 4
module alu_add4 #(
    parameter signalWidth = 32          // Ancho del bus (9 para PC/nPC, 32 para direcciones grandes, etc.)
)(
    input  wire [signalWidth-1:0] A,    // Entrada
    output wire [signalWidth-1:0] R     // Salida = A + 4
);
    assign R = A + 4;

endmodule
