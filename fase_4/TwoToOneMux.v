// =======================================
// Generic 2-to-1 mux
//  - WIDTH is parameterizable (default 32 bits)
//  - sel = 0 -> out = in0
//  - sel = 1 -> out = in1
// =======================================
module TwoToOneMux #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] in0,
    input  [WIDTH-1:0] in1,
    input              sel,
    output [WIDTH-1:0] out
);

    assign out = sel ? in1 : in0;

endmodule