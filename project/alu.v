`timescale 1ns/1ps

module ALU (
    output reg [31:0] Out,
    output Z, N, C, V,
    input  [31:0] A, B,
    input  Ci,
    input  [3:0] OP
);

always @(*)
    case (OP)
        4'b0000: Out = A + B; 
        4'b0001: Out = A + B + Ci;
        4'b0010: Out = A - B;
        4'b0011: Out = A - B - Ci;
        4'b0100: Out = A & B; 
        4'b0101: Out = A | B;
        4'b0110: Out = A ^ B;
        4'b0111: Out = ~(A ^ B);
        4'b1000: Out = A & ~B;
        4'b1001: Out = A | ~B;
        4'b1010: Out = A << B[4:0];
        4'b1011: Out = A >> B[4:0];
        4'b1100: Out = $signed(A) >>> B[4:0];
        4'b1101: Out = A;
        4'b1110: Out = B;
        4'b1111: Out = ~B;
    endcase

// El bit Z producirá un valor de uno cuando Out es igual a cero, de lo contrario producirá un cero
assign Z = (Out == 32'b0);

// El bit N representa el signo del resultado de la operación (N = Out[31]).
assign N = Out[31];

wire [32:0] add_ext = {1'b0, A} + {1'b0, B} + Ci;
wire [32:0] sub_ext = {1'b0, A} - ({1'b0, B} + Ci);

//assign C = 0;

assign C = (OP == 4'b0000 || OP == 4'b0001) ? add_ext[32] :   // carry out of add
           (OP == 4'b0010 || OP == 4'b0011) ? sub_ext[32] :   // borrow: 1 if A < B (+Ci)
           1'b0;

assign V = (OP == 4'b0000 || OP == 4'b0001) ? (~(A[31] ^ B[31]) & (A[31] ^ Out[31])) :
           (OP == 4'b0010 || OP == 4'b0011) ? ( (A[31] ^ B[31]) & (A[31] ^ Out[31])) :
           1'b0;

endmodule