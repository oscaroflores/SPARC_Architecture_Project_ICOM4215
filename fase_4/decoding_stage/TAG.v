`timescale 1ns/1ps
// TAG: Target Address Generator
// Calcula TA = B_PC + (Offset << 2)
// - Soporta branches (disp22 extendido a 30 bits) y CALL (disp30)

module TAG #(
    parameter PC_WIDTH     = 9,   // ancho del PC (proyecto: 9 bits)
    parameter OFFSET_WIDTH = 30   // disp30 / disp22 extendido a 30 bits
)(
    input  wire [PC_WIDTH-1:0]     B_PC,    // PC del branch / call
    input  wire [OFFSET_WIDTH-1:0] Offset,  // disp30 o disp22-extendido
    output wire [PC_WIDTH-1:0]     TA       // Target Address (PC')
);

    // Extender a 32 bits para hacer la suma cómodamente
    // PC es una dirección -> se extiende con ceros (no es signed)
    wire [31:0] pc_ext   = { {(32-PC_WIDTH){1'b0}}, B_PC };

    // Offset sí es signed -> sign-extend desde su MSB (bit 29)
    wire [31:0] off_ext  =
        { {(32-OFFSET_WIDTH){Offset[OFFSET_WIDTH-1]}}, Offset };

    // Los disp son en palabras, así que desplazamos 2 bits a la izquierda
    wire [31:0] off_shift = off_ext << 2;

    // Suma PC + offset desplazado
    wire [31:0] sum = pc_ext + off_shift;

    // Para el proyecto solo usamos los PC_WIDTH bits menos significativos
    assign TA = sum[PC_WIDTH-1:0];

endmodule
