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
assign C = (OP == 4'b0000 || OP == 4'b0001) ? {1'b0, A} + {1'b0, B} + Ci :
           (OP == 4'b0010 || OP == 4'b0011) ? ~({1'b0, A} - {1'b0, B} - Ci) :
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

/*
Demostración:
Deben asignar a las entradas A, B y Ci los valores que se indican a continuación:
A = 10011100000000000000000000111000
B = 01110000000000000000000000000011
Ci = 0
Entonces, comenzando con OP igual a 0000 deben ir incrementando OP cada dos unidades de tiempo hasta
que OP sea 1111. Con una instrucción de monitor deben imprimir en una línea el valor de OP en binario, los
números A y B (en decimal y binario), el output Out (en decimal y binario) y los flags (en binario).
Luego deben cambiar el valor de Ci a 1 y repetir el procedimiento anterior hasta el OP igual a 0011.
*/
module ALU_tester();

    // Entradas
    reg [31:0] A, B;
    reg Ci;
    reg [3:0] OP;

    // Salidas
    wire [31:0] Out;
    wire Z, N, C, V;

    // Instanciar la ALU
    ALU uut (
        .Out(Out),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V),
        .A(A),
        .B(B),
        .Ci(Ci),
        .OP(OP)
    );

    integer i; // para los loops

    initial begin
        // Inicializar valores de prueba
        A  = 32'b10011100000000000000000000111000; // en decimal: 2550136824
        B  = 32'b01110000000000000000000000000011; // en decimal: 1879048195
        Ci = 0;

        $display("==============================================================================================================================================================");
        $display(" OP  |                 A (dec/bin)                   |                 B (dec/bin)                   |                Out (dec/bin)                 | Z N C V");
        $display("==============================================================================================================================================================");

        // Recorre OP de 0000 hasta 1111 usando un entero para evitar overflow
        for (i = 0; i <= 15; i = i + 1) begin
            OP = i[3:0];
            #2;
            $display("%b | %0d (%b) | %0d (%b) | %0d (%b) | %b %b %b %b",
                     OP, A, A, B, B, Out, Out, Z, N, C, V);
        end

        // Cambiar Ci = 1 y repetir solo para OP = 0000 hasta 0011
      
        Ci = 1;
        $display("\n===================================== Repitiendo con Ci = 1 (solo OP=0000 a 0011) =================================\n");
        for (i = 0; i <= 3; i = i + 1) begin
            OP = i[3:0];
            #2;
            $display("%b | %0d (%b) | %0d (%b) | %0d (%b) | %b %b %b %b",
                     OP, A, A, B, B, Out, Out, Z, N, C, V);
        end

        $finish; // terminar simulación
    end

endmodule