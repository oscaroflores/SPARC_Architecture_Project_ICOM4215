`timescale 1ns/1ps
/*
Tarea:
En el diagrama de la página siguiente se muestra un diagrama de bloque y la tabla de la verdad del circuito que
se debe implementar. Este es un circuito combinacional (el efecto de las entradas se puede manifestar en las
salidas casi de manera instantánea). Según indica la tabla de la verdad, el circuito tiene como entradas un
número de 32 bits (R), un número de 22 bits (Imm) y cuatro bits (IS) que corresponden a bits de una
instrucción. El circuito tiene como salida un número N de 32 bits cuyo su valor depende de los inputs según
indica la tabla de la verdad. El símbolo || significa concatenación.
*/
module SOH(
    input  [31:0] R,
  	input  [21:0] Imm,
  	input  [3:0]  Is,
    output reg [31:0] N
);

always @(*) begin
  case (Is)
        4'b0000: N = {Imm, 10'b0};
        4'b0001: N = {Imm, 10'b0};
        4'b0010: N = {Imm, 10'b0};
        4'b0011: N = {Imm, 10'b0};
        4'b0100: N = {{10{Imm[21]}}, Imm};
        4'b0101: N = {{10{Imm[21]}}, Imm};
        4'b0110: N = {{10{Imm[21]}}, Imm};
        4'b0111: N = {{10{Imm[21]}}, Imm};
        4'b1000: N = R;
    	4'b1001: N = {{19{Imm[12]}}, Imm[12:0]};
   	4'b1010: N = {27'b0, R[4:0]};
    	4'b1011: N = {27'b0, Imm[4:0]};
        4'b1100: N = R;
    	4'b1101: N = {{19{Imm[12]}}, Imm[12:0]};
        4'b1110: N = R;
    	4'b1111: N = {{19{Imm[12]}}, Imm[12:0]};
        default: N = 32'b0;
    endcase
end

endmodule

/*
Demostración:
Asignando un número 11100000000000000000000000000011 en R y un número 1000110001000100010011
en Imm, muestre el valor que se produce en la salida N para todas las combinaciones de los inputs IS. Luego
cambie el valor de Imm por el número 1000110000000100010011 y muestre el valor de N para las
combinaciones de los inputs IS de la 8 a la 15.
Para cada caso deben imprimir en una línea el valor de los bits IS, y el valor de N, todos en binario.
*/
module SOH_tester;

    // Inputs
    reg [31:0] R;
    reg [21:0] Imm;
    reg [3:0]  Is;

    // Outputs
    wire [31:0] N;

    // Instanciar SOH
    SOH uut (
        .N(N),
        .R(R),
        .Imm(Imm),
      	.Is(Is)
    );
    
    integer i; // Utilizar i para evitar overflow en los loops

    initial begin
        R   = 32'b11100000000000000000000000000011;
        Imm = 22'b1000110001000100010011;

        $display("============================================================");
        $display(" Caso 1: R = %b, Imm = %b", R, Imm);
        $display("============================================================");

        for (i = 0; i <= 15; i = i + 1) begin
            Is = i[3:0];
            #1;
          $display("Is = %b , N = %b", Is, N);
        end

        Imm = 22'b1000110000000100010011;
        $display("============================================================");
        $display(" Caso 2: Nuevo Imm = %b para Is = 8-15", Imm);
        $display("============================================================");

        for (i = 8; i <= 15; i = i + 1) begin
            Is = i[3:0];
            #1;
          $display("Is = %b , N = %b", Is, N);
        end

        $finish;
    end
endmodule