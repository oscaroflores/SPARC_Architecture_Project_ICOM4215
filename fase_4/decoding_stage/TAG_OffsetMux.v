`timescale 1ns/1ps
// =======================================================
// TAG_OffsetMux
// Selecciona el offset correcto para el TAG:
// 0 → disp22 (sign-extended a 30 bits)
// 1 → disp30 (I[29:0]) usado por CALL
// =======================================================

module TAG_OffsetMux #(
    parameter WIDTH = 30      // ancho del offset usado por TAG
)(
    input  wire              CALL,      // selección del mux
    input  wire [WIDTH-1:0]  offset22,  // disp22 sign-extended → 30 bits
    input  wire [WIDTH-1:0]  offset30,  // disp30 → I[29:0]
    output wire [WIDTH-1:0]  OffsetOut  // va directo al TAG
);

    assign OffsetOut = CALL ? offset30 : offset22;

endmodule
