`timescale 1ns / 1ps

module control_unit(
    input      [31:0] I,
    output reg [31:0] control_signals
);
    wire [1:0] op    = I[31:30];   
    wire [2:0] op2   = I[24:22];   
    wire [5:0] op3   = I[24:19];   
    wire i_bit       = I[13];      

    //verificamos si es un nop 
    wire is_nop = (I == 32'b0);    

    // Control signals
    reg [3:0] ALU_OP;
    reg [3:0] SOH_OP;
    reg [1:0] RAM_Size;
    reg       RAM_RW;
    reg       RAM_Enable;
    reg       L;
    reg       RF_LE;
    reg       CALL;
    reg       JMPL;
    reg       B;
    reg       CC;
    reg       ID_SR;

    always @(*) begin
        ALU_OP = 4'b0000;
        SOH_OP = {I[31], I[30], I[24], I[13]};
        RAM_Size = 2'b00;
        RAM_RW = 1'b0;
        RAM_Enable = 1'b0;
        L = 1'b0;
        RF_LE = 1'b0;
        CALL = 1'b0;
        JMPL = 1'b0;
        B = 1'b0;
        CC = 1'b0;
        ID_SR = 1'b0;

        if (is_nop) begin
            ALU_OP = 4'b0000;
            SOH_OP = 4'b0000;
            RAM_Size = 2'b00;
            RAM_RW = 1'b0;
            RAM_Enable = 1'b0;
            L = 1'b0;
            RF_LE = 1'b0;
            CALL = 1'b0;
            JMPL = 1'b0;
            B = 1'b0;
            CC = 1'b0;
            ID_SR = 1'b0;
        end else begin
            case (op)
                
                // OP = 00 : Branches and SETHI
                2'b00: begin
                    case (op2)
                        3'b100: begin // SETHI
                        B = 0;
                        RF_LE = 1;
                        ALU_OP = 4'b1110;
                        SOH_OP = 4'b0000;
                        RAM_Size = 2'b01;
                        RAM_RW = 1'b1; 
                        end
                        
                        default: begin // Branch
                        B = 1; 
                        //SOH_OP = 4'b0001; 
                        ALU_OP = 4'b1101;
                        RAM_Size = 2'b01;
                        end
                    endcase
                end
                
                // OP = 01 : CALL
                2'b01: begin
                    CALL = 1;
                    RF_LE = 1;
                    ALU_OP = 4'b1101;
                    //SOH_OP = 4'b0100;
                    RAM_Size = 2'b01;
                end
                
                // OP = 10: Arithmetic, Logical, Shift, JMPL
                2'b10: begin
                    case (op3[4]) // verificar si la instruccion altera los contidion codes
                        1'b0: CC = 0;
                        1'b1: CC = 1;
                    endcase

                    case (op3)
// ---------- Aritméticas ----------
                        6'b000000: begin ALU_OP = 4'b0000; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ADD
                        6'b010000: begin ALU_OP = 4'b0000; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ADDCC
                        6'b001000: begin ALU_OP = 4'b0001; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ADDX
                        6'b011000: begin ALU_OP = 4'b0001; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ADDXCC
                        6'b000100: begin ALU_OP = 4'b0010; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // SUB
                        6'b010100: begin ALU_OP = 4'b0010; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // SUBCC
                        6'b001100: begin ALU_OP = 4'b0011; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // SUBX
                        //6'b011100: begin ALU_OP = 4'b0011; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // SUBXCC

                        // ---------- Lógicas ----------
                        6'b000001: begin ALU_OP = 4'b0100; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // AND
                        6'b010001: begin ALU_OP = 4'b0100; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ANDCC
                        6'b000101: begin ALU_OP = 4'b1000; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ANDN
                        6'b010101: begin ALU_OP = 4'b1000; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ANDNCC
                        6'b000010: begin ALU_OP = 4'b0101; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // OR
                        6'b010010: begin ALU_OP = 4'b0101; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ORCC
                        6'b000110: begin ALU_OP = 4'b1001; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ORN
                        6'b010110: begin ALU_OP = 4'b1001; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ORNCC
                        6'b000011: begin ALU_OP = 4'b0110; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // XOR
                        6'b010011: begin ALU_OP = 4'b0110; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // XORCC
                        6'b000111: begin ALU_OP = 4'b0111; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // XNOR
                        6'b010111: begin ALU_OP = 4'b0111; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // XNORCC

                        // ---------- Shifts ----------
                        6'b100101: begin ALU_OP = 4'b1010; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1011 : 4'b1010); end // SLL
                        6'b100110: begin ALU_OP = 4'b1011; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1011 : 4'b1010); end // SRL
                        6'b100111: begin ALU_OP = 4'b1100; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1011 : 4'b1010); end // SRA

                        // JMPL
                        6'b111000: begin 
                            JMPL = 1; 
                            RF_LE = 1;
                            CC = 0;
                            SOH_OP = (i_bit ? 4'b1001 : 4'b1000);
                            end
                        default: begin
                            ALU_OP = 4'b1111;
                        end
                    endcase
                end


                // OP = 11: Load y store
                2'b11: begin
                    case (op[1:0]) 
                        2'b01: begin
                            RAM_Size = 2'b01;
                            ALU_OP = 4'b0000;
                        end

                        default: begin // store 
                            RAM_Size = 2'b00;
                            ALU_OP = 4'b0000;
                        end
                    endcase

                    case (op3[2])
                        1'b0: begin // load 
                            L = 1;
                            RAM_Enable = 1;
                            RF_LE = 1;
                            SOH_OP = (i_bit ? 4'b1101 : 4'b1100);
                        end

                        default: begin // Store
                            RAM_Enable = 1;
                            RAM_RW = 1;
                            SOH_OP = (i_bit ? 4'b1101 : 4'b1100);
                        end
                    endcase
                end

                default: begin
                    // Unknown OP
                    ALU_OP = 4'b0000;
                end
            endcase
        end

        // Unimos todas las señales en el bus control_signals
        control_signals = 32'b0;
        control_signals[18]    = ID_SR;
        control_signals[17]    = CC;
        control_signals[16:13] = ALU_OP;
        control_signals[12:9]  = SOH_OP;
        control_signals[8:7]   = RAM_Size;
        control_signals[6]     = RAM_RW;
        control_signals[5]     = RAM_Enable;
        control_signals[4]     = L;
        control_signals[3]     = RF_LE;
        control_signals[2]     = CALL;
        control_signals[1]     = JMPL;
        control_signals[0]     = B;
    end
endmodule