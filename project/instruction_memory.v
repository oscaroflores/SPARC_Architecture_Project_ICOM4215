`timescale 1ns/1ps
// =======================================
// Instruction Memory
// =======================================

module instruction_memory (
    input  [8:0] A,
    output reg [31:0] I
);
    reg [7:0] Memory [0:511];

    always @(*) begin
        I = {Memory[A], Memory[A+1], Memory[A+2], Memory[A+3]};
    end

    initial begin
        //$readmemb("codes/debugging_code_SPARC.txt", Memory);
        //$readmemb("codes/testcode_sparc1.txt", Memory);
        $readmemb("codes/testcode_sparc2.txt", Memory);
    end
endmodule