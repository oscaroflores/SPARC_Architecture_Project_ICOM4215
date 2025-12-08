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

        // Instruction 1
        Memory[0]  = 8'b10001010;
        Memory[1]  = 8'b00000000;
        Memory[2]  = 8'b00100000;
        Memory[3]  = 8'b00111000;

        // Instruction 2
        Memory[4]  = 8'b11100000;
        Memory[5]  = 8'b01001001;
        Memory[6]  = 8'b01000000;
        Memory[7]  = 8'b00000000;

        // Instruction 3
        Memory[8]  = 8'b11100010;
        Memory[9]  = 8'b00001001;
        Memory[10] = 8'b01100000;
        Memory[11] = 8'b00000001;

        // Instruction 4
        Memory[12] = 8'b11100100;
        Memory[13] = 8'b00001001;
        Memory[14] = 8'b01100000;
        Memory[15] = 8'b00000010;

        // Instruction 5
        Memory[16] = 8'b10001100;
        Memory[17] = 8'b10000000;
        Memory[18] = 8'b00000000;
        Memory[19] = 8'b00010000;

        // Instruction 6
        Memory[20] = 8'b00011100;
        Memory[21] = 8'b10000000;
        Memory[22] = 8'b00000000;
        Memory[23] = 8'b00000101;

        // Instruction 7 (NOP)
        Memory[24] = 8'b00000000;
        Memory[25] = 8'b00000000;
        Memory[26] = 8'b00000000;
        Memory[27] = 8'b00000000;

        // Instruction 8
        Memory[28] = 8'b10001100;
        Memory[29] = 8'b00100100;
        Memory[30] = 8'b10000000;
        Memory[31] = 8'b00010001;

        // Instruction 9
        Memory[32] = 8'b00010000;
        Memory[33] = 8'b10000000;
        Memory[34] = 8'b00000000;
        Memory[35] = 8'b00000011;

        // Instruction 10 (NOP)
        Memory[36] = 8'b00000000;
        Memory[37] = 8'b00000000;
        Memory[38] = 8'b00000000;
        Memory[39] = 8'b00000000;

        // Instruction 11
        Memory[40] = 8'b10001100;
        Memory[41] = 8'b00000100;
        Memory[42] = 8'b10000000;
        Memory[43] = 8'b00010001;

        // Instruction 12
        Memory[44] = 8'b11001100;
        Memory[45] = 8'b00101001;
        Memory[46] = 8'b01100000;
        Memory[47] = 8'b00000011;

        // Instruction 13
        Memory[48] = 8'b00010000;
        Memory[49] = 8'b10000000;
        Memory[50] = 8'b00000000;
        Memory[51] = 8'b00000000;

        // Instruction 14 (NOP)
        Memory[52] = 8'b00000000;
        Memory[53] = 8'b00000000;
        Memory[54] = 8'b00000000;
        Memory[55] = 8'b00000000;

        // Instruction 15
        Memory[56] = 8'b11111100;
        Memory[57] = 8'b00010011;
        Memory[58] = 8'b00100000;
        Memory[59] = 8'b00000000;

    end

endmodule
