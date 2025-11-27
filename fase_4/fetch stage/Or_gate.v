`timescale 1ns / 1ps

// OR de 2 entradas de 1 bit (control signals)
module or2 #(
    input  wire [0:0] a,
    input  wire [0:0] b,
    output wire [0:0] y
);

    assign y = a | b;

endmodule
