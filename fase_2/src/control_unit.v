`timescale 1ns / 1ps

module control_unit(
    input  [31:0] I,

    output reg [31:0] control_signals
);
    // Initialize control signals
    reg [3:0]  ALU_OP;
    reg [3:0]  SOH_OP;
    reg [1:0]  RAM_Size;
    reg        RAM_RW;
    reg        RAM_Enable;
    reg        L;
    reg        RF_LE;
    reg        call;
    reg        jmpl;
    reg        B;

    // Combinational control logic
    always @(*) begin
        // Default values
        ALU_OP     = 4'b0000;
        SOH_OP     = 4'b0000;
        RAM_Size   = 2'b00;
        RAM_RW     = 1'b0;
        RAM_Enable = 1'b0;
        L          = 1'b0;
        RF_LE      = 1'b0;
        call       = 1'b0;
        jmpl       = 1'b0;
        B          = 1'b0;
        control_signals = 32'b0;

        case (I[31:30])
            2'b01: begin
                // Format 1: CALL (placeholder)
            end

            2'b00: begin // Format 2
                case (I[24:22]) // op2 field
                    3'b010: begin // BRANCH
                        // Placeholder for branch control
                    end
                    3'b100: begin // SETHI

                    end
                endcase
            end

            2'b10: begin // Format 3: Arithmetic/Logic
                case (I[24:19]) // op3
                    // Arithmetic
                    6'b010000: ALU_OP = 4'b0000; // addcc
                    6'b011000: ALU_OP = 4'b0001; // addxcc
                    6'b010100: ALU_OP = 4'b0010; // subcc
                    6'b011100: ALU_OP = 4'b0011; // subxcc

                    // Logical
                    6'b010001: ALU_OP = 4'b0100; // andcc
                    6'b010010: ALU_OP = 4'b0101; // orcc
                    6'b010011: ALU_OP = 4'b0110; // xorcc
                    6'b010111: ALU_OP = 4'b0111; // xnorcc
                    6'b010101: ALU_OP = 4'b1000; // andncc
                    6'b010110: ALU_OP = 4'b1001; // orncc

                    // Shifts
                    6'b100101: ALU_OP = 4'b1010; // sll
                    6'b100110: ALU_OP = 4'b1011; // srl
                    6'b100111: ALU_OP = 4'b1100; // sra
                endcase
            end

            2'b11: begin // Format 3: Load/Store
                case (I[24:19]) // op3
                    // Loads
                    6'b001001: begin // lsb
                        RAM_Size = 2'b00;
                        RAM_RW   = 1'b0;
                        RAM_Enable = 1'b1;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b001010: begin // ldsh
                        RAM_Size = 2'b01;
                        RAM_RW   = 1'b0;
                        RAM_Enable = 1'b1;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000000: begin // ld
                        RAM_Size = 2'b10;
                        RAM_RW   = 1'b0;
                        RAM_Enable = 1'b1;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000001: begin // ldub
                        RAM_Size = 2'b00;
                        RAM_RW   = 1'b0;
                        RAM_Enable = 1'b1;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000010: begin // lduh
                        RAM_Size = 2'b01;
                        RAM_RW   = 1'b0;
                        RAM_Enable = 1'b1;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000011: begin // ldd
                        RAM_Size = 2'b11;
                        RAM_RW   = 1'b0;
                        RAM_Enable = 1'b1;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end

                    // Stores
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
                    6'b001101: begin // ldstub
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b001111: begin // swap
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                endcase
            end

            default: begin
                // no-op
            end
        endcase

        control_signals = 32'b0;
        control_signals[16:13] = ALU_OP;
        control_signals[12:9]  = SOH_OP;
        control_signals[8:7]   = RAM_Size;
        control_signals[6]     = RAM_RW;
        control_signals[5]     = RAM_Enable;
        control_signals[4]     = L;
        control_signals[3]     = RF_LE;
        control_signals[2]     = call;
        control_signals[1]     = jmpl;
        control_signals[0]     = B;
    end

endmodule