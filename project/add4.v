`timescale 1ns / 1ps


// Sumador especializado: R = A + 4
module add4 #(
    parameter WIDTH = 32          // Ancho del bus (9 para PC/nPC, 32 para direcciones grandes, etc.)
)(
    input  wire [WIDTH-1:0] A,    // Entrada
    output wire [WIDTH-1:0] R     // Salida = A + 4
);

    reg [WIDTH-1:0] R_reg;
    assign R = R_reg;

    always @* begin
        R_reg = A + 4;
    end

endmodule
