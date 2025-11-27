`timescale 1ns / 1ps

// Sumador especializado: R = A + 4
module alu_add4 #(
    parameter WIDTH = 32          // Ancho del bus (9 para PC/nPC, 32 para direcciones grandes, etc.)
)(
    input  wire [WIDTH-1:0] A,    // Entrada
    output wire [WIDTH-1:0] R     // Salida = A + 4
);

    // Constante "4" expandida al ancho WIDTH
    localparam [WIDTH-1:0] FOUR = {{(WIDTH-3){1'b0}}, 3'b100};

    assign R = A + FOUR;

endmodule
