module control_unit(
    input       [31:0]  I,
    output reg  []      ALU_OP,
    output reg  [1:0]   RAM_Size,
    output reg          RAM_RW,
    output reg          RAM_Enable,
    output reg          L,
    output reg          RF_LE,
)


    always @(*) begin // combinational logic
    
        // defaults
        RAM_Size   = 2'b00;
        RAM_RW     = 1'b0;
        RAM_Enable = 1'b0;
        L = 1'b0;
        RF_LE = 1'b0;

        case (I[31:30])
            2'b01: // Format 1
                // CALL
            2'b00: begin // Format 2
                    case (I[24:22]) // op2
                        2'b010: begin // BRANCH
                            // assert B wire
                        end
                        2'b100: begin // SETHI
                            rd_data = {imm22, 10'b0};
                        end
                    endcase
            end
            2'b10: begin // Format 3; arithmetic
                case (I[24:19]) // op3
                    // arith
                    6'b010000: // addcc: rd <= rs1 + (rs2 or simm13), modify icc
                        ALU_OP = 4'b0000;
                    6'b011000: // addxcc: rd <= rs1 + (rs2 or simm13) + Carry, modify icc
                        ALU_OP = 4'b0001;
                    6'b010100: // subcc: rd <= rs1 - (rs2 or simm13), modify icc
                        ALU_OP = 4'b0010;
                    6'b011100: // subxcc: rd <= rs1 - (rs2 or simm13) - Carry, modify icc
                        ALU_OP = 4'b0011;

                    // logic
                    6'b010001: // andcc: rd <= rs1 bitwise AND (rs2 or simm13), modify icc
                        ALU_OP = 4'b0100;
                    6'b010010: // orcc: rd <= rs1 bitwise OR (rs2 or simm13), modify icc
                        ALU_OP = 4'b0101;
                    6'b010011: // xorcc: rd <= rs1 bitwise XOR (rs2 or simm13), modify icc
                        ALU_OP = 4'b0110;
                    6'b010111: // xnorcc: rd <= rs1 bitwise XNOR (rs2 or simm13), modify icc
                        ALU_OP = 4'b0111;
                    6'b010101: // andncc: rd <= rs1 bitwise AND  (NOT(rs2 or simm13)), modify icc
                        ALU_OP = 4'b1000;
                    6'b010110: // orncc: rd <= rs1 bitwise OR  (NOT(rs2 or simm13)), modify icc
                        ALU_OP = 4'b1001;

                    // shifts
                    6'b100101: // sll: shift left logical rs1 count positions
                        ALU_OP = 4'b1010;
                    6'b100110: // srl: shift right logical rs1 count positions
                        ALU_OP = 4'b1011;
                    6'b100111: // sra: shift right arithmetic rs1 count positions
                        ALU_OP = 4'b1100;
                endcase
                SOH_OP = I[13] ? 4'b1111 : 4'b1000;
            end
            2'b11: begin // Format 3; load/store
                case (I[24:19]) // op3
                    6'b001001: begin // lsb: load sign byte
                        RAM_Size = 2'b00;
                        RAM_RW   = 1'b0;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b001010: begin // ldsh: load sign halfword
                        RAM_Size = 2'b01;
                        RAM_RW   = 1'b0;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000000: begin // ld: load word
                        RAM_Size = 2'b10;
                        RAM_RW   = 1'b0;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000001: begin // ldub: load unsigned byte
                        RAM_Size = 2'b00;
                        RAM_RW   = 1'b0;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000010: begin // lduh: load unsigned halfword
                        RAM_Size = 2'b01;
                        RAM_RW   = 1'b0;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000011: begin // ldd: load double
                        RAM_Size = 2'b11;
                        RAM_RW   = 1'b0;
                        L        = 1'b1;
                        RF_LE    = 1'b1;
                    end
                    6'b000101: begin // stb: store byte
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000110: begin // sth: store halfword
                        RAM_Size   = 2'b01;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000100: begin // st: store word
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000111: begin // std: store double
                        RAM_Size   = 2'b11;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b001101: begin // ldstub: atomic load-store unsigned byte ??
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b001111: begin // swap: swap register with memory
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                endcase
                case (I[13])
                    1'b1: // sign extended
                    1'b0:
                endcase
            end
            default:
        endcase
    end


endmodule