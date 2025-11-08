module control_unit(
    input       [31:0]  I,
    output reg  [3:0]   ALU_OP,
    output reg  [3:0]   SOH_OP,
    output reg  [1:0]   RAM_Size,
    output reg          RAM_RW,
    output reg          RAM_Enable,
    output reg          L,
    output reg          RF_LE,
    output reg          B,
    output reg          CALL,
    output reg          JMPL
);

    always @(*) begin // combinational logic

        // defaults
        ALU_OP      = 4'b0000;
        SOH_OP      = 4'b1000;
        RAM_Size    = 2'b00;
        RAM_RW      = 1'b0;
        RAM_Enable  = 1'b0;
        L           = 1'b0;
        RF_LE       = 1'b0;
        B           = 1'b0;
        CALL        = 1'b0;
        JMPL        = 1'b0;

        // Format select (I[31:30])
        if (I[31:30] == 2'b01) begin // Format 1
            // CALL
            CALL    = 1'b1;
        end else if (I[31:30] == 2'b00) begin // Format 2
            // op2 decode (I[24:22])
            if (I[24:22] == 3'b010) begin // BRANCH
                B       = 1'b1;
                JMPL    = 1'b1;
            end else if (I[24:22] == 3'b100) begin // SETHI
                RF_LE   = 1'b1;
                SOH_OP  = 4'b0000;
            end
        end else if (I[31:30] == 2'b10) begin // Format 3; arithmetic
            // op3 decode (I[24:19])
            if (I[24:19] == 6'b010000) begin // addcc: rd <= rs1 + (rs2 or simm13), modify icc
                ALU_OP = 4'b0000;
            end else if (I[24:19] == 6'b011000) begin // addxcc: rd <= rs1 + (rs2 or simm13) + Carry, modify icc
                ALU_OP = 4'b0001;
            end else if (I[24:19] == 6'b010100) begin // subcc: rd <= rs1 - (rs2 or simm13), modify icc
                ALU_OP = 4'b0010;
            end else if (I[24:19] == 6'b011100) begin // subxcc: rd <= rs1 - (rs2 or simm13) - Carry, modify icc
                ALU_OP = 4'b0011;
            end else if (I[24:19] == 6'b010001) begin // andcc: rd <= rs1 bitwise AND (rs2 or simm13), modify icc
                ALU_OP = 4'b0100;
            end else if (I[24:19] == 6'b010010) begin // orcc: rd <= rs1 bitwise OR (rs2 or simm13), modify icc
                ALU_OP = 4'b0101;
            end else if (I[24:19] == 6'b010011) begin // xorcc: rd <= rs1 bitwise XOR (rs2 or simm13), modify icc
                ALU_OP = 4'b0110;
            end else if (I[24:19] == 6'b010111) begin // xnorcc: rd <= rs1 bitwise XNOR (rs2 or simm13), modify icc
                ALU_OP = 4'b0111;
            end else if (I[24:19] == 6'b010101) begin // andncc: rd <= rs1 bitwise AND  (NOT(rs2 or simm13)), modify icc
                ALU_OP = 4'b1000;
            end else if (I[24:19] == 6'b010110) begin // orncc: rd <= rs1 bitwise OR  (NOT(rs2 or simm13)), modify icc
                ALU_OP = 4'b1001;
            end else if (I[24:19] == 6'b100101) begin // sll: shift left logical rs1 count positions
                ALU_OP = 4'b1010;
            end else if (I[24:19] == 6'b100110) begin // srl: shift right logical rs1 count positions
                ALU_OP = 4'b1011;
            end else if (I[24:19] == 6'b100111) begin // sra: shift right arithmetic rs1 count positions
                ALU_OP = 4'b1100;
            end
            SOH_OP = I[13] ? 4'b1111 : 4'b1000;
        end else if (I[31:30] == 2'b11) begin // Format 3; load/store
            if (I[24:19] == 6'b001001) begin // lsb: load sign byte
                RAM_Size = 2'b00;
                RAM_RW   = 1'b0;
                L        = 1'b1;
                RF_LE    = 1'b1;
            end else if (I[24:19] == 6'b001010) begin // ldsh: load sign halfword
                RAM_Size = 2'b01;
                RAM_RW   = 1'b0;
                L        = 1'b1;
                RF_LE    = 1'b1;
            end else if (I[24:19] == 6'b000000) begin // ld: load word
                RAM_Size = 2'b10;
                RAM_RW   = 1'b0;
                L        = 1'b1;
                RF_LE    = 1'b1;
            end else if (I[24:19] == 6'b000001) begin // ldub: load unsigned byte
                RAM_Size = 2'b00;
                RAM_RW   = 1'b0;
                L        = 1'b1;
                RF_LE    = 1'b1;
            end else if (I[24:19] == 6'b000010) begin // lduh: load unsigned halfword
                RAM_Size = 2'b01;
                RAM_RW   = 1'b0;
                L        = 1'b1;
                RF_LE    = 1'b1;
            end else if (I[24:19] == 6'b000011) begin // ldd: load double
                RAM_Size = 2'b11;
                RAM_RW   = 1'b0;
                L        = 1'b1;
                RF_LE    = 1'b1;
            end else if (I[24:19] == 6'b000101) begin // stb: store byte
                RAM_Size   = 2'b00;
                RAM_RW     = 1'b1;
                RAM_Enable = 1'b1;
            end else if (I[24:19] == 6'b000110) begin // sth: store halfword
                RAM_Size   = 2'b01;
                RAM_RW     = 1'b1;
                RAM_Enable = 1'b1;
            end else if (I[24:19] == 6'b000100) begin // st: store word
                RAM_Size   = 2'b10;
                RAM_RW     = 1'b1;
                RAM_Enable = 1'b1;
            end else if (I[24:19] == 6'b000111) begin // std: store double
                RAM_Size   = 2'b11;
                RAM_RW     = 1'b1;
                RAM_Enable = 1'b1;
            end else if (I[24:19] == 6'b001101) begin // ldstub: atomic load-store unsigned byte ??
                RAM_Size   = 2'b00;
                RAM_RW     = 1'b1;
                RAM_Enable = 1'b1;
            end else if (I[24:19] == 6'b001111) begin // swap: swap register with memory
                RAM_Size   = 2'b10;
                RAM_RW     = 1'b1;
                RAM_Enable = 1'b1;
            end
            SOH_OP = I[13] ? 4'b1111 : 4'b1000;
        end
    end

endmodule