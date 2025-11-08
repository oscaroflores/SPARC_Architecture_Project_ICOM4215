// =====================================================
// Control Unit
// - Mapea la instrucción I a:
//   ALU_OP   (4 bits)   → lo usaremos como EX_ctrl
//   RAM_Size (2 bits)   → lo usaremos como MEM_ctrl
//   RAM_RW, RAM_Enable, L, RF_LE (no todos se pipelinean ahora)
// =====================================================
module control_unit(
    input  [31:0] I,
    output reg [3:0] ALU_OP,
    output reg [1:0] RAM_Size,
    output reg       RAM_RW,
    output reg       RAM_Enable,
    output reg       L,
    output reg       RF_LE
);
    wire [1:0] op   = I[31:30];
    wire [2:0] op2  = I[24:22];   // format 2
    wire [5:0] op3  = I[24:19];   // format 3

    always @(*) begin
        // valores por defecto (NOP)
        ALU_OP     = 4'b0000;
        RAM_Size   = 2'b00;
        RAM_RW     = 1'b0;
        RAM_Enable = 1'b0;
        L          = 1'b0;
        RF_LE      = 1'b0;

        case (op)
            2'b01: begin
                // Format 1 → CALL
                // Aquí podrías marcar alguna señal de control específica.
                // Para esta fase, lo dejamos en default.
            end

            2'b00: begin
                // Format 2 (BRANCH / SETHI)
                case (op2)
                    3'b010: begin
                        // BRANCH (bne, etc.) → tu lógica de branch iría aquí
                        // En esta fase solo nos importa que se ve distinto de NOP
                        ALU_OP = 4'b1110; // código arbitrario para "BR"
                    end

                    3'b100: begin
                        // SETHI
                        ALU_OP = 4'b1111; // código arbitrario para "SETHI"
                        RF_LE  = 1'b1;    // escribe registro destino
                    end

                    default: begin
                        // otras op2 de formato 2
                    end
                endcase
            end

            2'b10: begin
                // Format 3; aritmético / lógico / shifts
                case (op3)
                    // arith
                    6'b010000: ALU_OP = 4'b0000; // addcc
                    6'b011000: ALU_OP = 4'b0001; // addxcc
                    6'b010100: ALU_OP = 4'b0010; // subcc
                    6'b011100: ALU_OP = 4'b0011; // subxcc

                    // logic
                    6'b010001: ALU_OP = 4'b0100; // andcc
                    6'b010010: ALU_OP = 4'b0101; // orcc
                    6'b010011: ALU_OP = 4'b0110; // xorcc
                    6'b010111: ALU_OP = 4'b0111; // xnorcc
                    6'b010101: ALU_OP = 4'b1000; // andncc
                    6'b010110: ALU_OP = 4'b1001; // orncc

                    // shifts
                    6'b100101: ALU_OP = 4'b1010; // sll
                    6'b100110: ALU_OP = 4'b1011; // srl
                    6'b100111: ALU_OP = 4'b1100; // sra

                    default: ; // otras op3
                endcase
            end

            2'b11: begin
                // Format 3; load/store
                case (op3)
                    // LOADS (ponemos RAM_Enable y RF_LE)
                    6'b001001: begin // lsb / ldsb
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b001010: begin // ldsh
                        RAM_Size   = 2'b01;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b000000: begin // ld
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b000001: begin // ldub
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b000010: begin // lduh
                        RAM_Size   = 2'b01;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b000011: begin // ldd
                        RAM_Size   = 2'b11;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end

                    // STORES (no RF_LE, RAM_RW=1)
                    6'b000101: begin // stb
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000110: begin // sth
                        RAM_Size   = 2'b01;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000100: begin // st
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000111: begin // std
                        RAM_Size   = 2'b11;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b001101: begin // ldstub (simplificado)
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b001111: begin // swap (simplificado)
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end

                    default: ; // otros op3
                endcase
            end

            default: ; // op = 2'b?? no usado
        endcase
    end
endmodule