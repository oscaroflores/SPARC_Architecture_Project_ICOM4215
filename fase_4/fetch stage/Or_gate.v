`timescale 1ns / 1ps

// OR de 2 entradas (bit a bit)
module or2 #(
    parameter WIDTH = 1
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);

    assign y = a | b;

endmodule
