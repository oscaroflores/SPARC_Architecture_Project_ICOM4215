`timescale 1ns/1ps
// =======================================
// Instruction Memory
// - 512 bytes de memoria (128 instrucciones de 32 bits)
// - Dirección de 9 bits (byte addressable)
// - Salida de 32 bits (instrucción)
// =======================================
module instruction_memory (
    input [8:0] A,
    output reg [31:0] I
);
    reg [7:0] Memory [0:511];

    always @(*) begin
        I = {Memory[A], Memory[A+1], Memory[A+2], Memory[A+3]};
    end

    initial begin
        $readmemb("precharge.txt", Memory);
    end
endmodule