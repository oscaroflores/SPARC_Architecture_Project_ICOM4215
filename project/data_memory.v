`timescale 1ns/1ps

module data_memory(
    input   [31:0]  DI,
    input   [8:0]   A,
    input   [1:0]   Size,
    input           RW,
    input           E,
    input           SIGN_EXT,  // 1 = sign-extend para loads de byte/half
    output reg [31:0] DO
    
);

    reg [7:0] Memory[0:511]; // 512 bytes

    always @(*) begin
        DO = 32'b0;

         // =========================
        // READ (LOAD)
        // =========================
        if (!RW && E) begin
            case (Size)
                2'b00: begin
                    // BYTE
                    if (SIGN_EXT)
                        DO = {{24{Memory[A][7]}}, Memory[A]};  // signed byte
                    else
                        DO = {24'b0, Memory[A]};               // unsigned byte
                end
                2'b01: begin
                    // HALFWORD: Memory[A] es el byte alto
                    if (SIGN_EXT)
                        DO = {{16{Memory[A][7]}}, Memory[A], Memory[A+1]}; // signed half
                    else
                        DO = {16'b0, Memory[A], Memory[A+1]};              // unsigned half
                end
                2'b10: begin
                    // WORD (no aplica sign-extend, ya es 32 bits)
                    DO = {Memory[A], Memory[A+1], Memory[A+2], Memory[A+3]};
                end
                default: DO = 32'b0;
            endcase

           
        end
        // =========================
        // WRITE (STORE)
        // =========================
        else if (RW && E) begin
            case (Size)
                2'b00: begin
                    // STORE BYTE (DI[7:0])
                    Memory[A] = DI[7:0];
                end
                2'b01: begin
                    // STORE HALFWORD (DI[15:8] alto, DI[7:0] bajo)
                    Memory[A]   = DI[15:8];
                    Memory[A+1] = DI[7:0];
                end
                2'b10: begin
                    // STORE WORD (big-endian)
                    Memory[A]   = DI[31:24];
                    Memory[A+1] = DI[23:16];
                    Memory[A+2] = DI[15:8];
                    Memory[A+3] = DI[7:0];
                end
                default: /* sin cambio */;
            endcase
    end
    end
    // ==========================================
    // Pre-cargar Data Memory con instrucciones
    // ==========================================
    initial begin
        $readmemb("codes/debugging_code_SPARC.txt", Memory);
        //$readmemb("codes/testcode_sparc1.txt", Memory);
        //$readmemb("codes/testcode_sparc2.txt", Memory);

    end

endmodule