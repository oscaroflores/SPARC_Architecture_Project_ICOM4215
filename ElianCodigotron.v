`timescale 1ns / 1ps
// Sumador especializado: R = A + 4
module add4 #(
    parameter WIDTH = 32          // Ancho del bus (9 para PC/nPC, 32 para direcciones grandes, etc.)
)(
    input  wire [WIDTH-1:0] A,    // Entrada
    output wire [WIDTH-1:0] R     // Salida = A + 4
);

    reg [WIDTH-1:0] R_reg;
    assign R = R_reg;

    always @* begin
        R_reg = A + 4;
    end

endmodule


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module ALU (
    output reg [31:0] Out,
    output Z, N, C, V,
    input  [31:0] A, B,
    input  Ci,
    input  [3:0] OP
);

always @(*)
    case (OP)
        4'b0000: Out = A + B; 
        4'b0001: Out = A + B + Ci;
        4'b0010: Out = A - B;
        4'b0011: Out = A - B - Ci;
        4'b0100: Out = A & B; 
        4'b0101: Out = A | B;
        4'b0110: Out = A ^ B;
        4'b0111: Out = ~(A ^ B);
        4'b1000: Out = A & ~B;
        4'b1001: Out = A | ~B;
        4'b1010: Out = A << B[4:0];
        4'b1011: Out = A >> B[4:0];
        4'b1100: Out = $signed(A) >>> B[4:0];
        4'b1101: Out = A;
        4'b1110: Out = B;
        4'b1111: Out = ~B;
    endcase

// El bit Z producirá un valor de uno cuando Out es igual a cero, de lo contrario producirá un cero
assign Z = (Out == 32'b0);

// El bit N representa el signo del resultado de la operación (N = Out[31]).
assign N = Out[31];

wire [32:0] add_ext = {1'b0, A} + {1'b0, B} + Ci;
wire [32:0] sub_ext = {1'b0, A} - ({1'b0, B} + Ci);

//assign C = 0;

assign C = (OP == 4'b0000 || OP == 4'b0001) ? add_ext[32] :   // carry out of add
           (OP == 4'b0010 || OP == 4'b0011) ? sub_ext[32] :   // borrow: 1 if A < B (+Ci)
           1'b0;

assign V = (OP == 4'b0000 || OP == 4'b0001) ? (~(A[31] ^ B[31]) & (A[31] ^ Out[31])) :
           (OP == 4'b0010 || OP == 4'b0011) ? ( (A[31] ^ B[31]) & (A[31] ^ Out[31])) :
           1'b0;

endmodule

////////////////////////////////////////////////////////////////////////////////

module CCR (
    input        CC_EN,
    input  [3:0] ICC,
    input        clock,
    input        rst,      // <-- add
    output reg [3:0] CC_OUT,
    output reg       carry_out
);
    always @(posedge clock or posedge rst) begin
        if (rst) begin
            CC_OUT    <= 4'b0000;
            carry_out <= 1'b0;
        end
    end
endmodule


//////////////////////////////////////////////////////

module CH(
    input        BI,    //indica si hay branch (control signal)
    input  [3:0] cond,  //bits [28:25 de la instruccion actual en decod]
    input  [3:0] ACC,   //condition flags directo del ALU
    output reg   J
);

    reg N, Z, V, C;

always @(*) begin

    if (BI == 1) begin
        N = ACC[3];
        Z = ACC[2];
        V = ACC[1];
        C = ACC[0];

        case (cond)
        4'b1000: J = 1'b1;             // BA
        4'b0000: J = 1'b0;             // BN
        4'b1001: J = ~Z;               // BNE
        4'b0001: J =  Z;               // BE
        4'b1010: J = ~(Z | (N ^ V));   // BG
        4'b0010: J =  (Z | (N ^ V));   // BLE
        4'b1011: J = ~(N ^ V);         // BGE
        4'b0011: J =  (N ^ V);         // BL
        4'b1100: J = ~(C | Z);         // BGU
        4'b0100: J =  (C | Z);         // BLEU
        4'b1101: J = ~C;               // BCC
        4'b0101: J =  C;               // BCS
        4'b1110: J = ~N;               // BPOS
        4'b0110: J =  N;               // BNEG
        4'b1111: J = ~V;               // BVC
        4'b0111: J =  V;               // BVS
        default: J = 1'b0;
        endcase
    
    end else begin
        J = 1'b0;
    end

end

endmodule
//////////////////////////////////////////////////////////////////

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
    reg       SIGN_EXT;
    reg [2:0]  ID_SR;

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
        ID_SR = 3'b0;    //no lo estamos cambiando en ningun lado

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
            ID_SR = 3'b0;
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
                        
                        3'b010: begin
                        // ---------- Bicc: all integer conditional branches ----------
                        // BA, BN, BE, BNE, BG, BLE, BGE, BL, BGU, BLEU, BCC, BCS, BPOS, BNEG, BVC, BVS
                        B         = 1'b1;     // "this is a branch"
                        RF_LE     = 1'b0;     // branch doesn't write RF
                        CC        = 1'b0;     // branch does not update PSR.icc
                        CALL      = 1'b0;
                        JMPL      = 1'b0;
                        L         = 1'b0;
                        RAM_Enable= 1'b0;
                        RAM_RW    = 1'b0;
                        RAM_Size  = 2'b00;
                        ID_SR     = 3'b000;   // no register sources for load/store hazard logic

                        ALU_OP    = 4'b1101;  // "PC + disp" path (however you defined it)
                        SOH_OP    = 4'b0001;  // for example: select disp22 as branch offset
               
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

                    ID_SR[0] = 1'b1;      // RA (rs1) es fuente válida
                    if (!i_bit)
                        ID_SR[1] = 1'b1;  // RB (rs2) es fuente válida cuando no es inmediato


                    case (op3[4]) // verificar si la instruccion altera los contidion codes
                        1'b0: CC = 0;
                        1'b1: CC = 1;
                    endcase

                    case (op3)
// ---------- Aritméticas ----------
                        6'b000000: begin ALU_OP = 4'b0000; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ADD
                        6'b010000: begin ALU_OP = 4'b0000; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ADDCC
                        6'b001000: begin ALU_OP = 4'b0001; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ADDX
                        6'b011000: begin ALU_OP = 4'b0001; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ADDXCC
                        6'b000100: begin ALU_OP = 4'b0010; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // SUB
                        6'b010100: begin ALU_OP = 4'b0010; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // SUBCC
                        6'b001100: begin ALU_OP = 4'b0011; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // SUBX
                        //6'b011100: begin ALU_OP = 4'b0011; RF_LE=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // SUBXCC

                        // ---------- Lógicas ----------
                        6'b000001: begin ALU_OP = 4'b0100; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // AND
                        6'b010001: begin ALU_OP = 4'b0100; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ANDCC
                        6'b000101: begin ALU_OP = 4'b1000; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ANDN
                        6'b010101: begin ALU_OP = 4'b1000; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ANDNCC
                        6'b000010: begin ALU_OP = 4'b0101; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // OR
                        6'b010010: begin ALU_OP = 4'b0101; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ORCC
                        6'b000110: begin ALU_OP = 4'b1001; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ORN
                        6'b010110: begin ALU_OP = 4'b1001; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // ORNCC
                        6'b000011: begin ALU_OP = 4'b0110; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // XOR
                        6'b010011: begin ALU_OP = 4'b0110; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // XORCC
                        6'b000111: begin ALU_OP = 4'b0111; RF_LE=1; CC=0; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // XNOR
                        6'b010111: begin ALU_OP = 4'b0111; RF_LE=1; CC=1; SOH_OP = (i_bit ? 4'b1001 : 4'b1000); end // XNORCC

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


                                // OP = 11: Load y Store Integer
                2'b11: begin
                    // Dirección siempre se calcula con la ALU: rs1 + (rs2 | simm13)
                    ALU_OP     = 4'b0000;                        // suma
                    SOH_OP     = (i_bit ? 4'b1101 : 4'b1100);    // genera offset (simm13 o rs2)
                    RAM_Enable = 1'b0;
                    RAM_RW     = 1'b0;
                    RAM_Size   = 2'b00;
                    L          = 1'b0;
                    RF_LE      = 1'b0;
                    SIGN_EXT   = 1'b0;

                    case (op3)
                        // ========= LOADS =========
                        6'b000000: begin
                            // LD  → load word (unsigned, pero es un word completo)
                            RAM_Enable = 1'b1;
                            RAM_RW     = 1'b0;    // read
                            RAM_Size   = 2'b10;   // word
                            L          = 1'b1;    // ruta de load activa
                            RF_LE      = 1'b1;    // escribir en RF
                            SIGN_EXT   = 1'b0;    // no aplica, ya es word
                            if (i_bit)
                                ID_SR = 3'b001;  // [rs1 + simm13], rd
                            else
                            ID_SR = 3'b011;  // [rs1 + rs2], rd
                        end

                        6'b000001: begin
                            // LDUB → load unsigned byte
                            RAM_Enable = 1'b1;
                            RAM_RW     = 1'b0;
                            RAM_Size   = 2'b00;   // byte
                            L          = 1'b1;
                            RF_LE      = 1'b1;
                            SIGN_EXT   = 1'b0;    // zero-extend
                            if (i_bit)
                                ID_SR = 3'b001;  // [rs1 + simm13], rd
                            else
                            ID_SR = 3'b011;  // [rs1 + rs2], rd
                        end

                        6'b001001: begin
                            // LDSB → load signed byte
                            RAM_Enable = 1'b1;
                            RAM_RW     = 1'b0;
                            RAM_Size   = 2'b00;   // byte
                            L          = 1'b1;
                            RF_LE      = 1'b1;
                            SIGN_EXT   = 1'b1;    // sign-extend
                            if (i_bit)
                                ID_SR = 3'b001;  // [rs1 + simm13], rd
                            else
                            ID_SR = 3'b011;  // [rs1 + rs2], rd
                        end

                        6'b000010: begin
                            // LDUH → load unsigned halfword
                            RAM_Enable = 1'b1;
                            RAM_RW     = 1'b0;
                            RAM_Size   = 2'b01;   // halfword
                            L          = 1'b1;
                            RF_LE      = 1'b1;
                            SIGN_EXT   = 1'b0;    // zero-extend
                            if (i_bit)
                                ID_SR = 3'b001;  // [rs1 + simm13], rd
                            else
                            ID_SR = 3'b011;  // [rs1 + rs2], rd
                        end

                        6'b001010: begin
                            // LDSH → load signed halfword
                            RAM_Enable = 1'b1;
                            RAM_RW     = 1'b0;
                            RAM_Size   = 2'b01;   // halfword
                            L          = 1'b1;
                            RF_LE      = 1'b1;
                            SIGN_EXT   = 1'b1;    // sign-extend
                            if (i_bit)
                                ID_SR = 3'b001;  // [rs1 + simm13], rd
                            else
                            ID_SR = 3'b011;  // [rs1 + rs2], rd
                        end
///////////////////////////////////////////////////////////////////////////////////
                        // ========= STORES =========
                        6'b000100: begin
                            // ST → store word
                            RAM_Enable = 1'b1;
                            RAM_RW     = 1'b1;    // write
                            RAM_Size   = 2'b10;   // word
                            if (i_bit)
                                ID_SR = 3'b101;   // rs1, rd
                            else
                                ID_SR = 3'b111;   // rs1, rs2, rd
                            // L=0, RF_LE=0
                        end

                        6'b000101: begin
                            // STB → store byte
                            RAM_Enable = 1'b1;
                            RAM_RW     = 1'b1;
                            RAM_Size   = 2'b00;   // byte
                            if (i_bit)
                                ID_SR = 3'b101;   // rs1, rd
                            else
                                ID_SR = 3'b111;   // rs1, rs2, rd
                        end

                        6'b000110: begin
                            // STH → store halfword
                            RAM_Enable = 1'b1;
                            RAM_RW     = 1'b1;
                            RAM_Size   = 2'b01;   // halfword
                            if (i_bit)
                                ID_SR = 3'b101;   // rs1, rd
                            else
                                ID_SR = 3'b111;   // rs1, rs2, rd
                        end

                        default: begin
                            // Otros (LDD, STD, alternates, etc.) → por ahora NOP o error
                            RAM_Enable = 1'b0;
                            RAM_RW     = 1'b0;
                            L          = 1'b0;
                            RF_LE      = 1'b0;
                            SIGN_EXT   = 1'b0;
                            if (i_bit)
                                ID_SR = 3'b101;   // rs1, rd
                            else
                                ID_SR = 3'b111;   // rs1, rs2, rd
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
        
        control_signals[21]     = SIGN_EXT;
        control_signals[20:18]    = ID_SR;
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

///////////////////////////////////////////////////////////////////////////////////


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
        $readmemb("testcode_sparc2.txt", Memory);

        // // Instruction 1
        // Memory[0]  = 8'b10001010;
        // Memory[1]  = 8'b00000000;
        // Memory[2]  = 8'b00100000;
        // Memory[3]  = 8'b00111000;

        // // Instruction 2
        // Memory[4]  = 8'b11100000;
        // Memory[5]  = 8'b01001001;
        // Memory[6]  = 8'b01000000;
        // Memory[7]  = 8'b00000000;

        // // Instruction 3
        // Memory[8]  = 8'b11100010;
        // Memory[9]  = 8'b00001001;
        // Memory[10] = 8'b01100000;
        // Memory[11] = 8'b00000001;

        // // Instruction 4
        // Memory[12] = 8'b11100100;
        // Memory[13] = 8'b00001001;
        // Memory[14] = 8'b01100000;
        // Memory[15] = 8'b00000010;

        // // Instruction 5
        // Memory[16] = 8'b10001100;
        // Memory[17] = 8'b10000000;
        // Memory[18] = 8'b00000000;
        // Memory[19] = 8'b00010000;

        // // Instruction 6
        // Memory[20] = 8'b00011100;
        // Memory[21] = 8'b10000000;
        // Memory[22] = 8'b00000000;
        // Memory[23] = 8'b00000101;

        // // Instruction 7 (NOP)
        // Memory[24] = 8'b00000000;
        // Memory[25] = 8'b00000000;
        // Memory[26] = 8'b00000000;
        // Memory[27] = 8'b00000000;

        // // Instruction 8
        // Memory[28] = 8'b10001100;
        // Memory[29] = 8'b00100100;
        // Memory[30] = 8'b10000000;
        // Memory[31] = 8'b00010001;

        // // Instruction 9
        // Memory[32] = 8'b00010000;
        // Memory[33] = 8'b10000000;
        // Memory[34] = 8'b00000000;
        // Memory[35] = 8'b00000011;

        // // Instruction 10 (NOP)
        // Memory[36] = 8'b00000000;
        // Memory[37] = 8'b00000000;
        // Memory[38] = 8'b00000000;
        // Memory[39] = 8'b00000000;

        // // Instruction 11
        // Memory[40] = 8'b10001100;
        // Memory[41] = 8'b00000100;
        // Memory[42] = 8'b10000000;
        // Memory[43] = 8'b00010001;

        // // Instruction 12
        // Memory[44] = 8'b11001100;
        // Memory[45] = 8'b00101001;
        // Memory[46] = 8'b01100000;
        // Memory[47] = 8'b00000011;

        // // Instruction 13
        // Memory[48] = 8'b00010000;
        // Memory[49] = 8'b10000000;
        // Memory[50] = 8'b00000000;
        // Memory[51] = 8'b00000000;

        // // Instruction 14 (NOP)
        // Memory[52] = 8'b00000000;
        // Memory[53] = 8'b00000000;
        // Memory[54] = 8'b00000000;
        // Memory[55] = 8'b00000000;

        // // Instruction 15
        // Memory[56] = 8'b11111100;
        // Memory[57] = 8'b00010011;
        // Memory[58] = 8'b00100000;
        // Memory[59] = 8'b00000000;

    end

endmodule


///////////////////////////////////////////////

`timescale 1ns/1ps

module DHDU (
    // Tipo de instrucción en EX
    input        EX_L,          // instrucción en EX es LOAD

    // Señales que indican si RA,RB,RD son válidos (3 bits)
    input  [2:0] SR,            // SR[0]=RA valido, SR[1]=RB valido, SR[2]=RD valido

    // Registros fuente desde ID
    input  [4:0] RA,
    input  [4:0] RB,
    input  [4:0] RD,

    // Registros destino
    input  [4:0] EX_RD,
    input  [4:0] MEM_RD,
    input  [4:0] WB_RD,

    // Register-file load-enable desde EX, MEM y WB
    input        EX_RF_LE,
    input        MEM_RF_LE,
    input        WB_RF_LE,

    // Outputs
    output reg [1:0] A_S,
    output reg [1:0] B_S,
    output reg [1:0] D_S,
    output reg       NOP,
    output reg       LE
);

    // Decode de las señales SR
    wire SRA = SR[0];
    wire SRB = SR[1];
    wire SRC = SR[2];

    always @* begin
        // defaults
        LE  = 1'b1;
        NOP = 1'b0;
        A_S = 2'b00;
        B_S = 2'b00;
        D_S = 2'b00;

        // -----------------------------
        // LOAD–USE hazard => STALL + NOP
        // -----------------------------
        if (EX_L &
           ( (SRA & (RA == EX_RD)) ||
             (SRB & (RB == EX_RD)) ||
             (SRC & (RD == EX_RD)) ) ) begin

            LE  = 1'b0;  
            NOP = 1'b1;  
        end 
        else begin

            // -----------------------------------
            // RAW hazards solved via forwarding
            // -----------------------------------

            // RA forwarding
            if (SRA) begin
                if (EX_RF_LE  & (RA == EX_RD))       A_S = 2'b01;
                else if (MEM_RF_LE & (RA == MEM_RD)) A_S = 2'b10;
                else if (WB_RF_LE  & (RA == WB_RD))  A_S = 2'b11;
            end

            // RB forwarding
            if (SRB) begin
                if (EX_RF_LE  & (RB == EX_RD))       B_S = 2'b01;
                else if (MEM_RF_LE & (RB == MEM_RD)) B_S = 2'b10;
                else if (WB_RF_LE  & (RB == WB_RD))  B_S = 2'b11;
            end

            // RD forwarding (store data)
            if (SRC) begin
                if (EX_RF_LE  & (RD == EX_RD))       D_S = 2'b01;
                else if (MEM_RF_LE & (RD == MEM_RD)) D_S = 2'b10;
                else if (WB_RF_LE  & (RD == WB_RD))  D_S = 2'b11;
            end
        end
    end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
// =======================================
// EX/MEM: registro de señales de control y datos para MEM
// =======================================
module EX_MEM_reg (
    input              clk,
    input              reset,

    // ---- Control ----
    input       [31:0] ex_ctrl_in,
    output reg  [31:0] mem_ctrl_out,

    // ---- Datos ----
    // dato que sale del 3er operando (para stores)
    input       [31:0] ex_third_op_in,
    // salida del ALU en EX
    input       [31:0] ex_alu_out_in,
    // número del registro destino (RD) que se escribirá luego
    input       [4:0]  ex_rd_in,

    // mismos datos ya en la etapa MEM
    output reg  [31:0] mem_third_op_out,
    output reg  [31:0] mem_alu_out,
    output reg  [4:0]  mem_rd_out
);

    always @(posedge clk) begin
        if (reset) begin
            // NOP en control y datos
            mem_ctrl_out     <= 32'b0;
            mem_third_op_out <= 32'b0;
            mem_alu_out      <= 32'b0;
            mem_rd_out       <= 5'b0;
        end
        else begin
            mem_ctrl_out     <= ex_ctrl_in;
            mem_third_op_out <= ex_third_op_in;
            mem_alu_out      <= ex_alu_out_in;
            mem_rd_out       <= ex_rd_in;
        end
    end
always @(posedge clk) begin
        if (reset) begin
            // NOP en control y datos
            mem_ctrl_out     <= 32'b0;
            mem_third_op_out <= 32'b0;
            mem_alu_out      <= 32'b0;
            mem_rd_out       <= 5'b0;
        end
        else begin
            mem_ctrl_out     <= ex_ctrl_in;
            mem_third_op_out <= ex_third_op_in;
            mem_alu_out      <= ex_alu_out_in;
            mem_rd_out       <= ex_rd_in;
        end
    end
endmodule


//////////////////////////////////////////////////////////
`timescale 1ns/1ps
// =======================================
// Generic 4-to-1 forwarding mux
//  - WIDTH can be 32 (normal data) or 9 (TAG-style paths)
//  - sel = 00 -> in0 (RegFile PA/PB/PD)
//  - sel = 01 -> in1 (ALU result, EX stage)
//  - sel = 10 -> in2 (MEM stage value)
//  - sel = 11 -> in3 (WB stage value)
// =======================================
module FourToOneMux #(
    parameter WIDTH = 32
) (
    input  [WIDTH-1:0] in0,   // from 3-port register file (PA / PB / PD)
    input  [WIDTH-1:0] in1,   // from ALU output (EX stage)
    input  [WIDTH-1:0] in2,   // from MEM stage (EX/MEM or MEM result)
    input  [WIDTH-1:0] in3,   // from WB stage (MEM/WB)
    input  [1:0]       sel,   // forwarding select
    output reg [WIDTH-1:0] out
);

    always @* begin
        case(sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = {WIDTH{1'bx}};
        endcase
    end

endmodule

/////////////////////////////////////////////////////////

`timescale 1ns/1ps
// =======================================
// ID/EX: registro de señales de control, instrucción y datos para EX
// =======================================
module ID_EX_reg (
    input        clk,
    input        reset,

    // Control desde ID hacia EX
    input  [31:0] id_ctrl_in,
    output reg [31:0] ex_ctrl_out,

    // RD
    input [4:0] rd_ID,
    output reg [4:0] rd_EX,

    

    // Instrucción completa en ID (sale en EX)
    input  [31:0] instr_ID,
    output reg [31:0] instr_EX,

    input  [8:0] B_PC_ID,
    output reg [8:0] B_PC_EX,

    // Datos desde los muxes de data forwarding en ID
    input  [31:0] A_ID,   // operando A en ID
    input  [31:0] B_ID,   // operando B en ID
    input  [31:0] D_ID,   // tercer operando (store data, etc.) en ID

    // Datos registrados hacia la etapa EX
    output reg [31:0] A_EX,
    output reg [31:0] B_EX,
    output reg [31:0] D_EX
);

    always @(posedge clk) begin
        if (reset) begin
            // En reset, inyectar NOP y limpiar datos
            ex_ctrl_out <= 32'b0;
            instr_EX    <= 32'b0;
            A_EX        <= 32'b0;
            B_EX        <= 32'b0;
            D_EX        <= 32'b0;
            rd_EX       <= 5'b0;
            B_PC_EX     <= 9'b0;
        end else begin
            ex_ctrl_out <= id_ctrl_in;
            instr_EX    <= instr_ID;
            A_EX        <= A_ID;
            B_EX        <= B_ID;
            D_EX        <= D_ID;
            rd_EX       <= rd_ID;
            B_PC_EX     <= B_PC_ID;
        end
    end

endmodule

//////////////////////////////////////////////////////////

`timescale 1ns/1ps
// =======================================
// IF/ID: registro de instrucción y PC (B_PC)
// =======================================
module IF_ID_reg (
    input        clk, 
    input        reset, 
    input  [31:0] instr_in,
    input  [8:0]  pc_in,      // PC de la instrucción en IF
    input        LE,         // Load Enable para stalls
    output reg [31:0] instr_out,
    output reg [8:0]  pc_out  // B_PC hacia la etapa ID (para TAG)
);
    always @(posedge clk) begin

        if (reset) begin
            instr_out <= 32'd0;
            pc_out    <= 9'd0;
        end else if (LE) begin
            instr_out <= instr_in;
            pc_out    <= pc_in;
        end
    end
endmodule

//////////////////////////////////////////////////////////////

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
        $readmemb("testcode_sparc2.txt", Memory);
        // -----------------------------------------------------
        // Instruction 1: 10001010 00000000 00100000 00111000
        // -----------------------------------------------------
        // Memory[0]  = 8'b10001010;
        // Memory[1]  = 8'b00000000;
        // Memory[2]  = 8'b00100000;
        // Memory[3]  = 8'b00111000;

        // // Instruction 2
        // Memory[4]  = 8'b11100000;
        // Memory[5]  = 8'b01001001;
        // Memory[6]  = 8'b01000000;
        // Memory[7]  = 8'b00000000;

        // // Instruction 3
        // Memory[8]  = 8'b11100010;
        // Memory[9]  = 8'b00001001;
        // Memory[10] = 8'b01100000;
        // Memory[11] = 8'b00000001;

        // // Instruction 4
        // Memory[12] = 8'b11100100;
        // Memory[13] = 8'b00001001;
        // Memory[14] = 8'b01100000;
        // Memory[15] = 8'b00000010;

        // // Instruction 5
        // Memory[16] = 8'b10001100;
        // Memory[17] = 8'b10000000;
        // Memory[18] = 8'b00000000;
        // Memory[19] = 8'b00010000;

        // // Instruction 6
        // Memory[20] = 8'b00011100;
        // Memory[21] = 8'b10000000;
        // Memory[22] = 8'b00000000;
        // Memory[23] = 8'b00000101;

        // // Instruction 7
        // Memory[24] = 8'b00000000;
        // Memory[25] = 8'b00000000;
        // Memory[26] = 8'b00000000;
        // Memory[27] = 8'b00000000;

        // // Instruction 8
        // Memory[28] = 8'b10001100;
        // Memory[29] = 8'b00100100;
        // Memory[30] = 8'b10000000;
        // Memory[31] = 8'b00010001;

        // // Instruction 9
        // Memory[32] = 8'b00010000;
        // Memory[33] = 8'b10000000;
        // Memory[34] = 8'b00000000;
        // Memory[35] = 8'b00000011;

        // // Instruction 10
        // Memory[36] = 8'b00000000;
        // Memory[37] = 8'b00000000;
        // Memory[38] = 8'b00000000;
        // Memory[39] = 8'b00000000;

        // // Instruction 11
        // Memory[40] = 8'b10001100;
        // Memory[41] = 8'b00000100;
        // Memory[42] = 8'b10000000;
        // Memory[43] = 8'b00010001;

        // // Instruction 12
        // Memory[44] = 8'b11001100;
        // Memory[45] = 8'b00101001;
        // Memory[46] = 8'b01100000;
        // Memory[47] = 8'b00000011;

        // // Instruction 13
        // Memory[48] = 8'b00010000;
        // Memory[49] = 8'b10000000;
        // Memory[50] = 8'b00000000;
        // Memory[51] = 8'b00000000;

        // // Instruction 14
        // Memory[52] = 8'b00000000;
        // Memory[53] = 8'b00000000;
        // Memory[54] = 8'b00000000;
        // Memory[55] = 8'b00000000;

        // // Instruction 15
        // Memory[56] = 8'b11111100;
        // Memory[57] = 8'b00010011;
        // Memory[58] = 8'b00100000;
        // Memory[59] = 8'b00000000;
    end
endmodule

////////////////////////////////////////////////////////

`timescale 1ns/1ps

module MEM_WB_reg (
    input        clk,
    input        reset,

    // Control that flows from MEM to WB
    input  [31:0] mem_ctrl_in,
    output reg [31:0] wb_ctrl_out,

    // Data that will be written back to the register file (PW)
    input  [31:0] pw_data_in,
    output reg [31:0] pw_data_out,

    // Destination register (e.g., rd_ex_muxed, can be r15 on CALL)
    input  [4:0]  rd_in,
    output reg [4:0]  rd_out
);

    // Pipeline register
    always @(posedge clk) begin
        if (reset) begin
            wb_ctrl_out  <= 32'b0;
            pw_data_out  <= 32'b0;
            rd_out       <= 5'b0;
        end else begin
            wb_ctrl_out  <= mem_ctrl_in;
            pw_data_out  <= pw_data_in;
            rd_out       <= rd_in;
        end
    end

endmodule


////////////////////////////////////////////////////////////

`timescale 1ns/1ps
// =======================================
// NPC_reg: registro del Next Program Counter (NPC)
// =======================================
module NPC_reg (
    input clk,
    input reset,
    input LE,
    input [8:0] I,
    output reg [8:0] O
);
    always @(posedge clk) begin
        if (reset)
            O <= 9'd4;
        else if (LE)
            O <= I;
    end
endmodule

////////////////////////////////////
`timescale 1ns/1ps
// =======================================
// PC_reg: registro del Program Counter (PC)
// =======================================
module PC_reg (
    input clk,
    input reset,
    input LE,
    input [8:0] I,
    output reg [8:0] O
);
    always @(posedge clk) begin
        if (reset)
            O <= 9'd0;
        else if (LE)
            O <= I;
    end
endmodule

//////////////////////////////////////////////////
`timescale 1ns / 1ps

// OR de 2 entradas de 1 bit (control signals)
module or2 (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a | b;

endmodule
///////////////////////////////////////////////
module reset_handler(
    input jumpl,
    input call,
    input J,
    input I_29,
    input global_reset,
    output reg reset_out
);

    always @(*) begin
        if(~J && I_29) begin // Detalle arquitectural 3
            reset_out = 1'b1;
        end else
        if (jumpl || call || J || global_reset) begin
            reset_out = 1'b1;
        end else begin
            reset_out = 1'b0;
        end
    end

endmodule
/////////////////////////////////////////////////////////

`timescale 1ns/1ps
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


/////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module TAG_OffsetMux #(
    parameter WIDTH = 30
)(
    input  wire               CALL,       // 1 → use offset30 (CALL instruction)
    input  wire [WIDTH-1:0]   offset22,   // Sign-extended imm22
    input  wire [WIDTH-1:0]   offset30,   // Raw 30-bit displacement (CALL)
    output reg  [WIDTH-1:0]   OffsetOut
);

    always @(*) begin
        case (CALL)
            1'b0: OffsetOut = offset22;
            1'b1: OffsetOut = offset30;
            default: OffsetOut = {WIDTH{1'bx}}; // prevents latch inference, safe default
        endcase
    end

endmodule

///////////////////////////////////////////////////////////
`timescale 1ns/1ps
// TAG: Target Address Generator
// Computes TA = B_PC + (Offset << 2)

module TAG #(
    parameter PC_WIDTH     = 9,
    parameter OFFSET_WIDTH = 30
)(
    input  wire [PC_WIDTH-1:0]     B_PC,
    input  wire [OFFSET_WIDTH-1:0] Offset,
    output reg  [PC_WIDTH-1:0]     TA
);

    // Internal expanded wires
    reg [31:0] pc_ext;
    reg [31:0] off_ext;
    reg [31:0] off_shift;
    reg [31:0] sum;

    always @(*) begin
        // Zero-extend PC (PC is not signed)
        pc_ext = { {(32-PC_WIDTH){1'b0}}, B_PC };

        // Sign-extend Offset (signed immediate)
        off_ext = { {(32-OFFSET_WIDTH){Offset[OFFSET_WIDTH-1]}}, Offset };

        // Shift left by 2 (word addressing)
        off_shift = off_ext << 2;

        // Add
        sum = pc_ext + off_shift;

        // Output low PC_WIDTH bits
        TA = sum[PC_WIDTH-1:0];
    end

endmodule
///////////////////////////////////////////////////////


// Autor: Elian Graciano Vazquez
// Titulo: SPARC Three-Port Register File 
////////////////////////////////////////////

`timescale 1ns/1ps

// Modulo del decoder 5x32. 
module decoder_5to32 (output [31:0] O, input [4:0] D, input E);
    assign O = E ? (32'b1 << D) : 32'b0;
endmodule

//Modulo de los registros de 32 bits. Los mismos son "rising edge" utilizando posedge.
module Register32 (output reg [31:0] Q, input [31:0] D, input LE, Clk);
    initial begin
        Q = 32'h0000_0000;
    end
    
    always @(posedge Clk) begin
        if (LE) Q <= D;
    end
endmodule

// Modulo de un mux de 32x1 con entradas de 32 bits
module mux_32to1 (output reg [31:0] Y,input [4:0] S, input [31:0] I0, input [31:0] I1, input [31:0] I2, input [31:0] I3, input [31:0] I4, input [31:0] I5, input [31:0] I6, input [31:0] I7,
    input [31:0] I8, input [31:0] I9, input [31:0] I10, input [31:0] I11, input [31:0] I12, input [31:0] I13, input [31:0] I14, input [31:0] I15, input [31:0] I16, input [31:0] I17, input [31:0] I18, input [31:0] I19,
    input [31:0] I20, input [31:0] I21, input [31:0] I22, input [31:0] I23, input [31:0] I24, input [31:0] I25, input [31:0] I26, input [31:0] I27, input [31:0] I28, input [31:0] I29, input [31:0] I30, input [31:0] I31);

    always @(*) begin
        case (S)
            5'd0: Y = I0;   
            5'd1: Y = I1;   
            5'd2: Y = I2;   
            5'd3: Y = I3;
            5'd4: Y = I4;   
            5'd5: Y = I5;   
            5'd6: Y = I6;   
            5'd7: Y = I7;
            5'd8: Y = I8;   
            5'd9: Y = I9;   
            5'd10: Y = I10;  
            5'd11: Y = I11;
            5'd12: Y = I12;  
            5'd13: Y = I13;  
            5'd14: Y = I14;  
            5'd15: Y = I15;
            5'd16: Y = I16;  
            5'd17: Y = I17;  
            5'd18: Y = I18;  
            5'd19: Y = I19;
            5'd20: Y = I20;  
            5'd21: Y = I21;  
            5'd22: Y = I22;  
            5'd23: Y = I23;
            5'd24: Y = I24;  
            5'd25: Y = I25;  
            5'd26: Y = I26;  
            5'd27: Y = I27;
            5'd28: Y = I28;  
            5'd29: Y = I29;  
            5'd30: Y = I30;  
            5'd31: Y = I31;
            default: Y = 32'h0000_0000;
        endcase
    end
endmodule 


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Modulo implementando el Three-Port Register File utilizando el decoder, register y mux implementados anteriormente.  

module threePortRegisterFile_32x32 (output [31:0] PA, PB, PD, input [4:0] RA, RB, RD, RW, input [31:0] PW, input LE, Clk);
   
    //Se inicializa el decoder 5x32 y se crea el wire de output del mismo.
    wire [31:0] dec_out;
    decoder_5to32 decoder (dec_out, RW, LE);

    // Wires de las salidas de los registros (r# siendo el numero de registro).
    wire [31:0] r0,  r1,  r2,  r3,  r4,  r5,  r6,  r7, r8,  r9,  r10, r11, r12, r13, r14, r15;
    wire [31:0] r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31;

    // Obligamos el registro R0 a siempre tener un valor de 0 (wire de output del registro es 0). 
    assign r0 = 32'h0000_0000;

    // Inicializamos los registros 1-31 (el registro 0 ya se obliga a ser 0 arriba). Se utiliza como input PW y el output de los decoder proveen el Load. 
    Register32 R1 (r1, PW, dec_out[1], Clk);
    Register32 R2 (r2, PW, dec_out[2], Clk);
    Register32 R3 (r3, PW, dec_out[3], Clk);
    Register32 R4 (r4, PW, dec_out[4], Clk);
    Register32 R5 (r5, PW, dec_out[5], Clk);
    Register32 R6 (r6, PW, dec_out[6], Clk);
    Register32 R7 (r7, PW, dec_out[7], Clk);
    Register32 R8 (r8, PW, dec_out[8], Clk);
    Register32 R9 (r9, PW, dec_out[9], Clk);
    Register32 R10 (r10, PW, dec_out[10], Clk);
    Register32 R11 (r11, PW, dec_out[11], Clk);
    Register32 R12 (r12, PW, dec_out[12], Clk);
    Register32 R13 (r13, PW, dec_out[13], Clk);
    Register32 R14 (r14, PW, dec_out[14], Clk);
    Register32 R15 (r15, PW, dec_out[15], Clk);
    Register32 R16 (r16, PW, dec_out[16], Clk);
    Register32 R17 (r17, PW, dec_out[17], Clk);
    Register32 R18 (r18, PW, dec_out[18], Clk);
    Register32 R19 (r19, PW, dec_out[19], Clk);
    Register32 R20 (r20, PW, dec_out[20], Clk);
    Register32 R21 (r21, PW, dec_out[21], Clk);
    Register32 R22 (r22, PW, dec_out[22], Clk);
    Register32 R23 (r23, PW, dec_out[23], Clk);
    Register32 R24 (r24, PW, dec_out[24], Clk);
    Register32 R25 (r25, PW, dec_out[25], Clk);
    Register32 R26 (r26, PW, dec_out[26], Clk);
    Register32 R27 (r27, PW, dec_out[27], Clk);
    Register32 R28 (r28, PW, dec_out[28], Clk);
    Register32 R29 (r29, PW, dec_out[29], Clk);
    Register32 R30 (r30, PW, dec_out[30], Clk);
    Register32 R31 (r31, PW, dec_out[31], Clk);

    // Se inicializan los mux 32x1. Estos cogen el output de los registros y tienen output PA, PB, PD.
    mux_32to1 MUX_A (PA, RA,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,
        r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,r30,r31);

    mux_32to1 MUX_B (PB, RB,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,
        r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,r30,r31);

    mux_32to1 MUX_D (PD, RD,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,
        r16,r17,r18,r19,r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,r30,r31);
  
endmodule

//////////////////////////////////////////////////

`timescale 1ns/1ps

// =======================================
// Generic 2-to-1 mux
//  - WIDTH is parameterizable (default 32 bits)
//  - sel = 0 -> out = in0
//  - sel = 1 -> out = in1
// =======================================

module TwoToOneMux #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0] in0,
    input  [WIDTH-1:0] in1,
    input              sel,
    output reg [WIDTH-1:0] out
);

    always @* begin
        if (sel)
            out = in1;
        else
            out = in0;
    end

endmodule

`timescale 1ns / 1ps

// =====================
//  FETCH PATH (IF stage)
// =====================
module fetch_stage_path #(
    parameter ADDR_WIDTH = 9,
    parameter INST_WIDTH = 32,
    // Puedes ajustar estos valores de reset si el profesor quiere algo distinto
    parameter [ADDR_WIDTH-1:0] RESET_PC  = {ADDR_WIDTH{1'b0}},
    parameter [ADDR_WIDTH-1:0] RESET_nPC = 9'd4      // PC=0, nPC=4 (byte addresses)
)(
    input  wire clk,
    input  wire reset,
    input  wire LE_DHDU, // VERIFICAR: señal de enable desde DHDU

    // Enables para poder hacer stalls más adelante
    input  wire pc_LE,
    input  wire npc_LE,

    // Señales de control
    input  wire call,   // control de instrucción JMPL
    input  wire J,      // condición de branch tomada (condition handler)
    input  wire jmpl,   // control de instrucción JMPL
    // Entradas desde otras etapas
    // TA y ALU_out vendrán luego del TA generator y del EX stage
    input  wire [ADDR_WIDTH-1:0] TA,       // Target Address (branch/call)
    input  wire [ADDR_WIDTH-1:0] ALU_out,  // Resultado de ALU para JMPL

    // Salidas hacia el pipeline IF/ID
    output wire [INST_WIDTH-1:0] instr_F,  // instrucción leída (a IF/ID)
    output wire [ADDR_WIDTH-1:0] B_PC,     // PC para el TA generator en ID (B_PC)

    // (Opcional) para debug/monitoreo
    output wire [ADDR_WIDTH-1:0] PC_out,
    output wire [ADDR_WIDTH-1:0] nPC_out
);

    // ======================
    //  Registros PC y nPC
    // ======================
    reg [ADDR_WIDTH-1:0] PC_reg;
    reg [ADDR_WIDTH-1:0] nPC_reg;

    // ======================
    //  Wires internos
    // ======================

    // Resultados de los ALU +4
    wire [ADDR_WIDTH-1:0] TA_plus4;
    wire [ADDR_WIDTH-1:0] nPC_plus4;
    wire [ADDR_WIDTH-1:0] ALUout_plus4;

    // Salida del OR (jumpl OR J)
    wire branch_or_call;

    // Salidas de los muxes
    wire [ADDR_WIDTH-1:0] mux_TA_nPC_plus4_out; // escoge entre nPC+4 y TA+4
    wire [ADDR_WIDTH-1:0] mux_TA_nPC_out;       // escoge entre nPC y TA
    wire [ADDR_WIDTH-1:0] mux_nPC_next_src;     // entrada final de nPC
    wire [ADDR_WIDTH-1:0] mux_PC_next_src;      // entrada final de PC

    // ======================
    //  Lógica combinacional
    // ======================

    // OR gate: call OR J
    or2 u_or_branch_call (
        .a(call),
        .b(J),
        .y(branch_or_call)
    );

    // ALU: TA + 4
    add4 #(.WIDTH(ADDR_WIDTH)) u_add4_TA (
        .A(TA),
        .R(TA_plus4)
    );

    // ALU: nPC + 4
    add4 #(.WIDTH(ADDR_WIDTH)) u_add4_nPC (
        .A(nPC_reg),
        .R(nPC_plus4)
    );

    // ALU: ALU_out + 4 (para JMPL)
    add4 #(.WIDTH(ADDR_WIDTH)) u_add4_ALUout (
        .A(ALU_out),
        .R(ALUout_plus4)
    );

    // Primer par de muxes (controlados por OR(jmpl, J))
    // Mux 1: escoge entre nPC+4 (secuencial) y TA+4 (brinco)
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_TA_nPC_plus4 (
        .in0(nPC_plus4),       // camino normal: nPC + 4
        .in1(TA_plus4),        // camino de salto: TA + 4
        .sel(branch_or_call),
        .out(mux_TA_nPC_plus4_out)
    );

    // Mux 2: escoge entre nPC y TA para el PC
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_TA_nPC (
        .in0(nPC_reg),         // camino normal: PC <- nPC
        .in1(TA),              // camino de salto: PC <- TA
        .sel(branch_or_call),
        .out(mux_TA_nPC_out)
    );

    // Segundo par de muxes (controlados directamente por jumpl)

    // Mux 3: entrada final del registro nPC
    // Entradas: (TA+4 / nPC+4) vs (ALU_out + 4)
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_nPC_next (
        .in0(mux_TA_nPC_plus4_out), // normal / branch
        .in1(ALUout_plus4),
        .sel(jmpl),
        .out(mux_nPC_next_src)
    );

    // Mux 4: entrada final del registro PC
    // Entradas: (TA / nPC) vs ALU_out directo
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_PC_next (
        .in0(mux_TA_nPC_out),   // normal / branch
        .in1(ALU_out),          // JMPL
        .sel(jmpl),
        .out(mux_PC_next_src)
    );

    // ======================
    //  Registros PC y nPC
    // ======================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_reg  <= RESET_PC;
            nPC_reg <= RESET_nPC;
        end else begin
            if (pc_LE)
                PC_reg <= mux_PC_next_src;
            if (npc_LE)
                nPC_reg <= mux_nPC_next_src;
        end
    end

    // ======================
    //  Instruction Memory
    // ======================
    instruction_memory u_imem (
        .A(PC_reg),     // dirección = PC de 9 bits
        .I(instr_F)     // instrucción de 32 bits hacia IF/ID
    );

    // ======================
    //  Salidas hacia IF/ID
    // ======================
    assign B_PC    = PC_reg;   // PC que se mandará al registro IF/ID (para TA generator)
    assign PC_out  = PC_reg;   // opcionales, por si los quieres ver en testbench
    assign nPC_out = nPC_reg;

endmodule

`timescale 1ns / 1ps

module decoding_stage_path #(
    parameter ADDR_WIDTH = 9,
    parameter RESET_PC   = 9'd0,
    parameter RESET_nPC  = 9'd4
)(
    input  wire                     clk,
    input  wire                     reset,
    input  wire [8:0]               B_PC_ID,         // desde IF/ID
    input  wire [31:0]              instr_ID,       // desde IF/ID
    

    // Forwarding / valores de etapas posteriores (necesarios para los muxes)
    input  wire [31:0]              ALU_Out_EX,     // forwarding desde EX stage
    input  wire [31:0]              data_mem_mux,   // forwarding desde MEM/WB
    input  wire [31:0]              PW_WB,          // writeback data from WB stage        // forwarding desde MEM/WB
    input  wire [4:0]               RW_WB,          // writeback destination reg from WB stage
    input  wire                     RF_LE_WB,       // register file write enable (WB stage)
    input  wire                     NOP,           // desde DHDU
    input  wire                     LE_DHDU,            // desde DHDU      // desde control signals de writeback stage
    // Señales para CCR (vienen normalmente del EX stage / control)
    input  wire [3:0]               ALU_CC,        // datos a cargar en CCR (desde EX stage)
    input  wire [31:0]              ex_ctrl_in,    // señales de control

    // DHDU
    input  wire [1:0]               A_S,
    input  wire [1:0]               B_S,
    input  wire [1:0]               D_S,
    // Salidas hacia la etapa EX (operandos y señales)
    output wire [31:0]              A_src,
    output wire [31:0]              B_src,
    output wire [31:0]              D_src,
    output wire [31:0]              instr_EX,
    output wire [ADDR_WIDTH-1:0]    TA,
    output wire                     J,            // Va para la etapa de fetch
    output wire                     carry_out,    // Va para el alu en EX stage
    output wire [31:0]              id_ctrl_out
);
    

    // ------------------------------------------------------------
    // Internal wires / señales auxiliares
    // ------------------------------------------------------------
    // TAG related
    wire [29:0] disp22_ext = { {8{instr_ID[21]}}, instr_ID[21:0] }; // sign-extend 22 -> 30
    wire [29:0] TAG_Offset;

    // Register file ports / decoded register addresses
    wire [4:0] RA_rf;
    wire [4:0] RB_rf;
    wire [4:0] RD_rf;

    // RF read data
    wire [31:0] PA_rf;
    wire [31:0] PB_rf;
    wire [31:0] PD_rf;

    // Forwarding selects (PROVISIONAL — deben venir del control unit)
    wire [1:0] sel_A = A_S;
    wire [1:0] sel_B = B_S;
    wire [1:0] sel_D = D_S;

    // ------------------------------------------------------------
    // Decode register numbers
    // ------------------------------------------------------------
    assign RA_rf = instr_ID[18:14];   // rs1
    assign RB_rf = instr_ID[4:0];     // rs2
    assign RD_rf = instr_ID[29:25];   // rd

    // ------------------------------------------------------------
    // TAG unit (genera TA)
    // ------------------------------------------------------------
    TAG #(
        .PC_WIDTH(ADDR_WIDTH),
        .OFFSET_WIDTH(30)
    ) TAG0 (
        .B_PC   (B_PC_ID[ADDR_WIDTH-1:0]), // maybe cambiar
        .Offset (TAG_Offset),
        .TA     (TA)
    );

    TAG_OffsetMux #(.WIDTH(30)) TAG_Offset_Mux (
        .CALL   (id_ctrl_out[2]),
        .offset22 (disp22_ext),
        .offset30 ({instr_ID[29:0]}),
        .OffsetOut (TAG_Offset)
    );
    // ------------------------------------------------------------
    // Register File (3-port)
    // ------------------------------------------------------------
    threePortRegisterFile_32x32 REG_FILE (
        .PA (PA_rf),
        .PB (PB_rf),
        .PD (PD_rf),

        .RA (RA_rf),
        .RB (RB_rf),
        .RD (RD_rf),
        .RW (RW_WB),

        .PW (PW_WB),
        .LE (RF_LE_WB),
        .Clk(clk)
    );

    // ------------------------------------------------------------
    // Forwarding Muxes -> salida A_src, B_src, D_src
    // ------------------------------------------------------------
    FourToOneMux #(.WIDTH(32)) mux_A (
        .in0 (PA_rf),
        .in1 (ALU_Out_EX),
        .in2 (data_mem_mux),
        .in3 (PW_WB),
        .sel (sel_A),
        .out (A_src)
    );

    FourToOneMux #(.WIDTH(32)) mux_B (
        .in0 (PB_rf),
        .in1 (ALU_Out_EX),
        .in2 (data_mem_mux),
        .in3 (PW_WB),
        .sel (sel_B),
        .out (B_src)
    );

    FourToOneMux #(.WIDTH(32)) mux_D (
        .in0 (PD_rf),
        .in1 (ALU_Out_EX),
        .in2 (data_mem_mux),
        .in3 (PW_WB),
        .sel (sel_D),
        .out (D_src)
    );

    // ------------------------------------------------------------
    // CCR: registro de flags global (instancio aquí; opcionalmente puede residir fuera)
    // CCR interface (esperada): (CC_EN, ICC, clock, CC_OUT, carry_out)
    // ------------------------------------------------------------
    wire [3:0] CCR_out;
    wire [3:0] CCR_out_muxed;
    CCR u_CCR (
        .CC_EN(ex_ctrl_in[17]),
        .ICC(ALU_CC),
        .clock(clk),
        .rst(reset),
        .CC_OUT(CCR_out),
        .carry_out(carry_out)
    );

    TwoToOneMux #(.WIDTH(4)) ccr_mux (
        .in0 (CCR_out),
        .in1 (ALU_CC),
        .sel (ex_ctrl_in[17]),
        .out (CCR_out_muxed)
    );

    // ------------------------------------------------------------
    // CH: condition handler (combinacional) -> produce J (branch taken)
    // CH expects: BI, cond, ACC[3:0] -> J
    // Mapear BI y cond desde instr_ID (ajusta según tu encoding)
    // ------------------------------------------------------------
    wire BI   = id_ctrl_out[0];         // asunción: bit 30 = BI (ajusta si hace falta)
    wire [3:0] cond = instr_ID[28:25];
    wire [31:0] control_signals;
    wire reset_signal;

    CH u_CH (
        .BI(BI),
        .cond(cond),
        .ACC(CCR_out_muxed),
        .J(J)
    );

    control_unit CU (
        .I(instr_ID),
        .control_signals(control_signals)
    );

    TwoToOneMux #(.WIDTH(32)) NOP_mux_CU (
        .in0 (control_signals),
        .in1 (32'd0),
        .sel (NOP),
        .out (id_ctrl_out)
    );

    reset_handler RESET_HANDLER (
        .jumpl(ex_ctrl_in[1]),
        .call(id_ctrl_out[2]),
        .J(J),
        .I_29(instr_ID[29]),
        .global_reset(reset),
        .reset_out(reset_signal)
    );

    // ------------------------------------------------------------
    // Passthrough de B_PC e instrucción a EX
    // ------------------------------------------------------------
    assign instr_EX = instr_ID;

endmodule

module memory_stage_path (
    input  wire [31:0]  alu_result_in,
    input  wire [31:0]  mem_ctrl_in,
    input  wire [4:0]   rd_in,
    input  wire [31:0]  DI,

    output wire [31:0]  data_mux_out,
    output wire [31:0]  mem_ctrl_out,
    output wire [4:0]   rd_out
);

// Señales internas
wire [1:0] Size;
wire       RW;
wire       E;
wire       L;

wire [31:0] data_out;
wire SIGN_EXTEND;
// Señales de control
assign Size = mem_ctrl_in[8:7];
assign RW   = mem_ctrl_in[6];
assign E    = mem_ctrl_in[5];
assign L    = mem_ctrl_in[4];
assign SIGN_EXTEND = mem_ctrl_in[21];

data_memory data_memory_inst (
    .DI   (DI),
    .A    (alu_result_in[8:0]),
    .Size (Size),
    .RW   (RW),
    .E    (E),
    .SIGN_EXT (SIGN_EXTEND),
    .DO   (data_out)
);

assign data_mux_out = (L) ? data_out : alu_result_in;
assign mem_ctrl_out = mem_ctrl_in;
assign rd_out       = rd_in;

endmodule


//////////////////////////////

module sparc_top (
    input wire clk,
    input wire reset,

    // outputs visibles para el testbench
    output [8:0]  PC_fetch,
    output [8:0]  nPC_fetch,
    output [31:0] instr_F,

    output [31:0] instr_ID,
    output [8:0]  B_PC_ID,
    output [8:0]  B_PC_EX,

    output [31:0] A_EX,
    output [31:0] B_EX,
    output [31:0] D_EX,
    output [31:0] instr_EX2,
    output [31:0] id_ctrl_out,
    output [8:0]  TA,

    output [31:0] ex_ctrl_out,
    output [31:0] D_MEM_tmp,
    output [31:0] ALU_out_EX,
    output [4:0]  RD_EX_out,
    output [3:0]  CC_EX,

    output [31:0] mem_ctrl_out,

    output [31:0] data_mux_out,
    output [4:0]  rd_mem,

    output [31:0] PW_WB,
    output [4:0]  RW_WB,
    output        RF_LE_WB,

    output [31:0] wb_ctrl_out
);

    // ======================================================
    //  Señales internas entre FETCH → IF/ID
    // ======================================================
    // instr_F, PC_fetch, nPC_fetch ya son puertos de salida (wire implícito)
    wire [8:0]  B_PC_F;

    // ======================================================
    //  Señales IF/ID → DECODING
    // ======================================================
    // instr_ID y B_PC_ID ya son puertos de salida

    // ======================================================
    //  DECODING → ID/EX
    // ======================================================
    // A_EX, B_EX, D_EX, instr_EX, id_ctrl_out, TA ya son puertos
    wire        J;
    wire        carry_flag;
    // 'call' no se usa en este top, así que lo omito

    // ======================================================
    //  ID/EX → EXECUTE
    // ======================================================
    // ex_ctrl_out, D_MEM_tmp, ALU_out_EX, RD_EX_out, CC_EX ya son puertos

    // ======================================================
    //  EXECUTE → EX/MEM → MEMORY
    // ======================================================
    wire [31:0] alu_result_in;
    wire [31:0] mem_ctrl_in;
    wire [31:0] mempipe_ctrl_in;
    wire [4:0]  rd_in;
    wire [31:0] DI;

    // ======================================================
    //  MEM/WB → WRITEBACK
    // ======================================================
    // PW_WB, RW_WB, RF_LE_WB y wb_ctrl_out ya son puertos
    assign RF_LE_WB = wb_ctrl_out[3];

    // ======================================================
    //  Señales para DHDU
    // ======================================================
    wire [1:0] A_S;
    wire [1:0] B_S;
    wire [1:0] D_S;
    wire       NOP;
    wire       LE_DHDU;

    // ======================================================
    //  ETAPA FETCH
    // ======================================================
    fetch_stage_path FETCH (
        .clk(clk),
        .reset(reset),
        .pc_LE(LE_DHDU),
        .npc_LE(LE_DHDU),
        .call(ex_ctrl_out[2]),
        .jmpl(ex_ctrl_out[1]),
        .LE_DHDU(LE_DHDU),
        .J(J),
        .TA(TA),
        .ALU_out(ALU_out_EX[8:0]),

        .instr_F(instr_F),
        .B_PC(B_PC_F),

        .PC_out(PC_fetch),
        .nPC_out(nPC_fetch)
    );
   

    // ======================================================
    //  REGISTRO IF/ID
    // ======================================================
    IF_ID_reg IF_ID0 (
        .clk(clk),
        .reset(reset),
        .instr_in(instr_F),
        .pc_in(B_PC_F),
        .LE(LE_DHDU),
        .instr_out(instr_ID),
        .pc_out(B_PC_ID)
    );
    /*
    always @(posedge clk) begin
        if (!reset) begin
            $display("IF/ID @t=%0t | instr_F=%h instr_ID=%h",
                     $time,
                    instr_F,
                    instr_ID);       
        end
    end
*/
    // ======================================================
    // ETAPA DECODING
    // ======================================================
    wire [3:1] alu_ICC;
    decoding_stage_path #(
        .ADDR_WIDTH(9),
        .RESET_PC(9'd0),
        .RESET_nPC(9'd4)
    ) ID (
        .clk(clk),
        .reset(reset),
        .B_PC_ID(B_PC_ID),
        .instr_ID(instr_ID),

        // Forwarding inputs
        .ALU_Out_EX(Mux_to_mem),
        .data_mem_mux(data_mux_out),
        .PW_WB(PW_WB), //------------------------------->cambiar a PW_WB
        .RW_WB(RW_WB), //------------------------------->cambiar a RW_WB
        .RF_LE_WB(RF_LE_WB ), //------------------------------------------------>cambiar a RF_LE_WB 

        // DHDU hazard control
        .NOP(NOP),
        .LE_DHDU(LE_DHDU),

        // ALU condition codes into the CCR
        .ALU_CC(CC_EX),

        // Control signals from EX
        .ex_ctrl_in(ex_ctrl_out),

        // Selector inputs from DHDU
        .A_S(A_S),
        .B_S(B_S),
        .D_S(D_S),

        // Outputs
        .A_src(A_EX),
        .B_src(B_EX),
        .D_src(D_EX),
        .instr_EX(instr_EX2),
        .TA(TA),
        .J(J),
        .carry_out(carry_flag),
        .id_ctrl_out(id_ctrl_out)

   
    );
 
    wire[31:0] instr_EX3;
    wire[31:0] D_EX2;
    wire[31:0] A_EX2;
    wire[31:0] B_EX2;
    // ======================================================
    // REGISTRO ID/EX
    // ======================================================
    ID_EX_reg ID_EX0 (
        .clk(clk),
        .reset(reset),
        .instr_ID(instr_EX2),
        .A_ID(A_EX), 
        .B_ID(B_EX), 
        .D_ID(D_EX), 
        .id_ctrl_in(id_ctrl_out),
        .B_PC_ID(B_PC_ID),

        .instr_EX(instr_EX3),
        .A_EX(A_EX2),
        .B_EX(B_EX2),
        .D_EX(D_EX2),
        .ex_ctrl_out(ex_ctrl_out),
        .B_PC_EX(B_PC_EX)
    );
/*
    always @(posedge clk) begin
        if (!reset) begin
            $display("ID/EX @t=%0t | id_ctrl_out=%h ex_ctrl_out=%h",
                     $time,
                    id_ctrl_out,
                    ex_ctrl_out);       
        end
    end
    */

  // Entradas
  
      // ======================================================
    // ETAPA DE EJECUCIÓN (EX) INLINE
    // ======================================================

    // Decode de la instrucción en EX (viene del ID/EX)
    wire [4:0] RD_EX  = instr_EX3[29:25];
    wire [4:0] RS1_EX = instr_EX3[18:14];
    wire [4:0] RS2_EX = instr_EX3[4:0];

    // Señales de control del EX stage (desde ID/EX_reg → ex_ctrl_out)
    wire [3:0] ALU_OP  = ex_ctrl_out[16:13];
    wire [3:0] SOH_OP  = ex_ctrl_out[12:9];
    wire       CALLbit = ex_ctrl_out[2];

    wire Z_EX, N_EX, C_EX, V_EX;
    // CC y resultado hacia afuera
   
    wire psr_carry = CC_EX[0];
    wire is_addx = (ALU_OP == 4'b0001); // your encoding for ADDX
    wire is_subx = (ALU_OP == 4'b0011); // your encoding for SUBX
    wire use_carry_in = is_addx || is_subx;
    wire Ci_to_ALU = use_carry_in ? psr_carry : 1'b0;
    
    // SOH UNIT
    wire [31:0] SOH_out;

    SOH soh0 (
        .R   (B_EX2),
        .Imm (instr_EX3[21:0]),
        .Is  (SOH_OP),
        .N   (SOH_out)
    );

    // ALU
    wire [31:0] ALU_Out_EX2;
   

    ALU alu0 (
        .Out (ALU_Out_EX2),
        .Z   (Z_EX),
        .N   (N_EX),
        .C   (C_EX),
        .V   (V_EX),
        .A   (A_EX2),
        .B   (SOH_out),
        .Ci  (carry_flag),
        .OP  (ALU_OP)
    );
    
    
     assign CC_EX = {N_EX, Z_EX, V_EX, C_EX};
    
    // MUX RD
    TwoToOneMux #(.WIDTH(5)) RD_mux (
        .in0 (RD_EX),
        .in1 (5'd15),
        .sel (CALLbit),
        .out (RD_EX_out)
    );
    wire [31:0] Mux_to_mem;
    // MUX ALU/PC
    TwoToOneMux #(.WIDTH(32)) ALU_mux (
        .in0 (ALU_Out_EX2),
        .in1 (B_PC_EX),
        .sel (CALLbit),
        .out (Mux_to_mem)
    );

    // Señales directas hacia MEM (igual que antes)
    assign mempipe_ctrl_in = ex_ctrl_out;
    assign D_MEM_tmp       = D_EX2;
/*
  
*/
    // ======================================================
    // REGISTRO EX/MEM
    // ======================================================
    
    EX_MEM_reg EX_MEM0 (
        .clk(clk),
        .reset(reset),

        .ex_alu_out_in(Mux_to_mem), 
        .ex_ctrl_in(mempipe_ctrl_in),
        .ex_rd_in(RD_EX_out),
        .ex_third_op_in(D_MEM_tmp),

        .mem_alu_out(alu_result_in),
        .mem_ctrl_out(mem_ctrl_in),
        .mem_rd_out(rd_in),
        .mem_third_op_out(DI)
    );
/*
  always @(posedge clk) begin
    if (!reset) begin
        $display("");  // blank line for readability
        $display("EX/MEM @ t=%0t", $time);
        $display("  mux to mem   = %0d", Mux_to_mem);
        $display("  mem_alu_out  = %0d", alu_result_in);
        $display("");  // blank line for readability
    end
end
*/

    // ======================================================
    // ETAPA DE MEMORIA
    // ======================================================
    memory_stage_path MEM (
        .alu_result_in(alu_result_in), 
        .mem_ctrl_in(mem_ctrl_in),
        .rd_in(rd_in),
        .DI(DI),

        .data_mux_out(data_mux_out),
        .mem_ctrl_out(mem_ctrl_out),
        .rd_out(rd_mem)
    );

    // ======================================================
    // REGISTRO MEM/WB
    // ======================================================
    MEM_WB_reg MEM_WB0 (
        .clk(clk),
        .reset(reset),

        .pw_data_in(data_mux_out),
        .rd_in(rd_mem),
        .mem_ctrl_in(mem_ctrl_out),

        .pw_data_out(PW_WB), //PW_WB
        .rd_out(RW_WB),
        .wb_ctrl_out(wb_ctrl_out)
    );
   
  /*
    always @(posedge clk) begin
        if (!reset) begin
            $display("ID/EX @t=%0t |  PW_WB=%h RW_WB=%0d",
                     $time,
                    PW_WB,
                    RW_WB);       
        end
    end
*/

    // ======================================================
    // DHDU: Data Hazard Detection Unit
    // ======================================================
    DHDU DHDU (
        .EX_L(ex_ctrl_out[4]),
        .SR(id_ctrl_out[20:18]),
        .RA(instr_ID[18:14]),
        .RB(instr_ID[4:0]),
        .RD(instr_ID[29:25]),
        .EX_RD(RD_EX_out),
        .MEM_RD(rd_mem),
        .WB_RD(RW_WB),
        .EX_RF_LE(ex_ctrl_out[3]),
        .MEM_RF_LE(mem_ctrl_out[3]),
        .WB_RF_LE(wb_ctrl_out[3]),

        .A_S(A_S),
        .B_S(B_S),
        .D_S(D_S),
        .NOP(NOP),
        .LE(LE_DHDU)
    );
endmodule

module sparc_tb();

    reg clk;
    reg reset;

    // ============================
    // Instancia del DUT
    // ============================
    sparc_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // =============================================================
    // Wires importantes
    // =============================================================
    wire signed [31:0] r1  = DUT.ID.REG_FILE.r1;
    wire signed [31:0] r2  = DUT.ID.REG_FILE.r2;
    wire signed [31:0] r3 = DUT.ID.REG_FILE.r3;
    wire signed [31:0] r4  = DUT.ID.REG_FILE.r4;
    wire signed [31:0] r5  = DUT.ID.REG_FILE.r5;
    wire signed [31:0] r6  = DUT.ID.REG_FILE.r6;
    wire signed [31:0] r8  = DUT.ID.REG_FILE.r8;
    wire signed [31:0] r10 = DUT.ID.REG_FILE.r10;
    wire signed [31:0] r11 = DUT.ID.REG_FILE.r11;
    wire signed [31:0] r12 = DUT.ID.REG_FILE.r12;
    wire signed [31:0] r15 = DUT.ID.REG_FILE.r15;
    wire signed [31:0] r16 = DUT.ID.REG_FILE.r16;
    wire signed [31:0] r17 = DUT.ID.REG_FILE.r17;
    wire signed [31:0] r18 = DUT.ID.REG_FILE.r18;

    integer i;

    // ============================================
    // Inicialización de reloj
    // ============================================
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end

    // ====================================
    // Inicialización de reset
    // ====================================
    initial begin
        reset = 1;
        #3 reset = 0;
    end

    // =============================================================
    // SELECCIÓN DE TEST
    // =============================================================

`ifdef debugging
    initial begin
        $monitor(
            { "==== debugging ==== \n",
            "PC=%0d NPC=%0d | PW_WB=%0d RW_WB=%0d RF_LE_WB=%0b\n",
            "r5=%0d r6=%0d r16=%0d r17=%0d r18=%0d\n"
            },
            DUT.PC_fetch, DUT.nPC_fetch,
            DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB,
            r5, r6, r16, r17, r18
        );
    end

    initial begin
        #76;
        $display("DM[56 to 59] = %b %b %b %b",
            DUT.MEM.data_memory_inst.Memory[56],
            DUT.MEM.data_memory_inst.Memory[57],
            DUT.MEM.data_memory_inst.Memory[58],
            DUT.MEM.data_memory_inst.Memory[59]
        );
    end

    initial begin
        #80 $finish;
    end

`elsif sparc1
    initial begin
        $monitor(
            { "==== testcode_sparc1 ====\n",
              "PC=%0d NPC=%0d | PW_WB=%0d RW_WB=%0d RF_LE_WB=%0b\n",
              "r1=%0d r2=%0d r3=%0d r5=%0d\n"
            },
            DUT.PC_fetch, DUT.nPC_fetch,
            DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB,
            r1, r2, r3, r5
        );
    end

    initial begin
        #160;
        $display("DM[44-47] = %b %b %b %b",
            DUT.MEM.data_memory_inst.Memory[44],
            DUT.MEM.data_memory_inst.Memory[45],
            DUT.MEM.data_memory_inst.Memory[46],
            DUT.MEM.data_memory_inst.Memory[47]
        );
    end

    initial begin
        #164 $finish;
    end

`elsif sparc2
    initial begin
        $monitor(
            { "==== sparc2 ====\n",
              "PC=%0d NPC=%0d | PW_WB=%0d RW_WB=%0d RF_LE_WB=%0b\n",
              "r1=%0d r2=%0d r3=%0d\n",
              "r4=%0d r5=%0d r8=%0d\n",
              "r10=%0d r11=%0d\n",
              "r12=%0d r15=%0d\n"
            },
            DUT.PC_fetch, DUT.nPC_fetch,
            DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB,
            r1, r2, r3,
            r4, r5, r8,
            r10, r11,
            r12, r15
        );
    end

    initial begin
        #240;
        for (i = 224; i < 264; i = i + 4) begin
            $display("D[%0d]= %b, D[%0d]= %b, D[%0d]= %b, D[%0d]= %b",
                i,
                DUT.MEM.data_memory_inst.Memory[i],
                i+1,
                DUT.MEM.data_memory_inst.Memory[i+1],
                i+2,
                DUT.MEM.data_memory_inst.Memory[i+2],
                i+3,
                DUT.MEM.data_memory_inst.Memory[i+3]
            );
        end
    end

    initial begin
        #244 $finish;
    end
`else
    initial begin
        $display("ERROR: use command \"iverilog -Ddebugging\" Define debugging, testcode_sparc1 or sparc2");
        $finish;
    end
`endif

endmodule