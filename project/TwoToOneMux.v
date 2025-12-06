`timescale 1ns/1ps

module TwoToOneMux #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] in0,
    input  [WIDTH-1:0] in1,
    input              sel,
    output reg [WIDTH-1:0] out
);

    always @* begin
        if (sel)
            out = in1;
        else
            out = in0;
    end

endmodule