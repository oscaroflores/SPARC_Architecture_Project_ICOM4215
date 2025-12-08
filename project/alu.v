`timescale 1ns/1ps
/* Tarea:
En la página siguiente se muestra un diagrama de bloque y la tabla de la verdad del ALU que se debe
implementar. El ALU es un circuito combinacional (el efecto de las entradas se puede manifestar en las salidas
casi de manera instantánea). Según indica la tabla de la verdad, el ALU toma dos números (A y B) y un bit de
carry (Ci) y realiza operaciones con los mismos determinadas por la señal OP. El resultado de las operaciones
es un número Out y cuatro flag bits de condiciones (Z, N, C y V). 
*/
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

/*
C representa el bit de ”overflow” de operaciones de suma o resta de números sin signo. Se le
denomina como “carry” para suma y como “borrow” para resta. Para la suma de dos números de n bits
C es el bit n+1 del resultado de la suma. Para la resta de dos números (A - B) C será igual a 1 si A < B.
*/
wire [32:0] add_ext = {1'b0, A} + {1'b0, B} + Ci;
wire [32:0] sub_ext = {1'b0, A} - ({1'b0, B} + Ci);

assign C = (OP == 4'b0000 || OP == 4'b0001) ? add_ext[32] :   // carry out of add
           (OP == 4'b0010 || OP == 4'b0011) ? sub_ext[32] :   // borrow: 1 if A < B (+Ci)
           1'b0;

/*
V representa el bit de “overflow” de operaciones de suma o resta de números con signo. V es igual a 1
cuando el signo del resultado de la suma o la resta no es consistente con las reglas de asignación de
signo de operaciones aritméticas de números con signo, de lo contrario es igual a cero. V se puede
determinar mediante una ecuación booleana de los signos de A, B y Out.
Para A + B: V = ˜(A[31] ˆ B[31]) & (A[31] ˆ Out[31]).
Para A - B: V = (A[31] ˆ B[31]) & (A[31] ˆ Out[31]).
*/
assign V = (OP == 4'b0000 || OP == 4'b0001) ? (~(A[31] ^ B[31]) & (A[31] ^ Out[31])) :
           (OP == 4'b0010 || OP == 4'b0011) ? ( (A[31] ^ B[31]) & (A[31] ^ Out[31])) :
           1'b0;


endmodule