`timescale 1ns / 1ps

module TAG_OffsetMux #(
    parameter WIDTH = 30  // Ancho de los offsets (30 bits para SPARC)
)(
    input  wire               CALL,       // Señal de control: 1=usa offset30, 0=usa offset22
    input  wire [WIDTH-1:0]   offset22,   // Offset extendido de 22 bits (sign-extended)
    input  wire [WIDTH-1:0]   offset30,   // Offset de 30 bits directo
    output wire [WIDTH-1:0]   OffsetOut   // Offset seleccionado
);

    // Multiplexor 2:1 para seleccionar entre offset22 y offset30
    assign OffsetOut = CALL ? offset30 : offset22;

endmodule