`timescale 1ns / 1ps

// OR de 2 entradas de 1 bit (control signals)
module or2 (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a | b;

endmodule