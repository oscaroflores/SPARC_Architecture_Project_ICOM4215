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
/* Tarea:
En la página siguiente se muestra un diagrama de bloque y la tabla de la verdad del ALU que se debe
implementar. El ALU es un circuito combinacional (el efecto de las entradas se puede manifestar en las salidas
casi de manera instantánea). Según indica la tabla de la verdad, el ALU toma dos números (A y B) y un bit de
carry (Ci) y realiza operaciones con los mismos determinadas por la señal OP. El resultado de las operaciones
es un número Out y cuatro flag bits de condiciones (Z, N, C y V). 
*/
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

/*
C representa el bit de ”overflow” de operaciones de suma o resta de números sin signo. Se le
denomina como “carry” para suma y como “borrow” para resta. Para la suma de dos números de n bits
C es el bit n+1 del resultado de la suma. Para la resta de dos números (A - B) C será igual a 1 si A < B.
*/
wire [32:0] add_ext = {1'b0, A} + {1'b0, B} + Ci;
wire [32:0] sub_ext = {1'b0, A} - ({1'b0, B} + Ci);

//assign C = 0;

assign C = (OP == 4'b0000 || OP == 4'b0001) ? add_ext[32] :   // carry out of add
           (OP == 4'b0010 || OP == 4'b0011) ? sub_ext[32] :   // borrow: 1 if A < B (+Ci)
           1'b0;

/*
V representa el bit de “overflow” de operaciones de suma o resta de números con signo. V es igual a 1
cuando el signo del resultado de la suma o la resta no es consistente con las reglas de asignación de
signo de operaciones aritméticas de números con signo, de lo contrario es igual a cero. V se puede
determinar mediante una ecuación booleana de los signos de A, B y Out.
Para A + B: V = ˜(A[31] ˆ B[31]) & (A[31] ˆ Out[31]).
Para A - B: V = (A[31] ˆ B[31]) & (A[31] ˆ Out[31]).
*/
assign V = (OP == 4'b0000 || OP == 4'b0001) ? (~(A[31] ^ B[31]) & (A[31] ^ Out[31])) :
           (OP == 4'b0010 || OP == 4'b0011) ? ( (A[31] ^ B[31]) & (A[31] ^ Out[31])) :
           1'b0;


    // =============================================================
    // Debug display: Entradas A y B de la ALU
    // =============================================================
/*
    initial begin
        $display("==== MONITOREO ALU ====");
    end

    always @(*) begin
        $display("t = %0t", $time);
        $display("  Out  = %0d", Out);
        $display("  OP  = %b", OP);
        $display("  Ci  = %b", Ci);
        $display("  A   = %h", A);
        $display("  B   = %h", B);
        $display("  Z = %h", Z);
        $display("  N = %h", N);
        $display("  C = %h", C);
        $display("  V = %h", V);
        $display("--------------------------\n");
    end
*/
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
            /*
            // DEBUG display
            $display("t=%0t | CCR RESET -> CC_OUT=0000 carry=0", $time);
        end else if (CC_EN) begin
            CC_OUT    <= ICC;
            carry_out <= ICC[0]; 
               // DEBUG display
            $display("t=%0t | CCR UPDATE | ICC=%b (N Z V C) | CC_OUT=%b | carry=%b",
                     $time, ICC, ICC, ICC[0]);
                     */
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



/////////////////////////////////////////////////////////////////////



///////////////////////////////////////

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
/*
            // Debug: lectura
            $display("DATA_MEM READ  @t=%0t | A=%0d Size=%b RW=%b E=%b SIGN_EXT=%b",
                     $time, A, Size, RW, E, SIGN_EXT);
            $display("   Bytes crudos: M[A]=%d M[A+1]=%d M[A+2]=%d M[A+3]=%d",
                     Memory[A], Memory[A+1], Memory[A+2], Memory[A+3]);
            $display("   DO (resultado) = %d\n", DO);
        
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
                default:  sin cambio */;
            
/*
            // Debug: escritura
            $display("DATA_MEM WRITE @t=%0t | A=%0d Size=%b RW=%b E=%b",
                     $time, A, Size, RW, E);
            $display("   DI (entrada)   = %h\n", DI);
            */
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
/*
    // ============================
    // Debug display EX → MEM
    // ============================
    initial begin
        $display("===== EX_MEM_reg MONITOR =====");
        $display(" t | ex_alu_out_in | mem_alu_out");
        $display("================================");
    end

    // Usa $strobe para ver mem_alu_out ya actualizado
    always @(posedge clk) begin
        if (!reset) begin
            $strobe("t=%0t | ex_alu_out_in=%0d | mem_alu_out=%0d",
                    $time, ex_alu_out_in, mem_alu_out);
        end
    end
    */
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
        // -----------------------------------------------------
        // Instruction 1: 10001010 00000000 00100000 00111000
        // -----------------------------------------------------
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

        // Instruction 7
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

        // Instruction 10
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

        // Instruction 14
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

/*
module instruction_memory (
    input  [8:0]  A,
    output reg [31:0] I
);
    reg [31:0] mem [0:511];
    integer i;
    initial begin
    
    // Default everything to NOP (32'b0)
        for (i = 0; i < 512; i = i + 1) begin
            mem[i] = 32'b0;
        end
        // Some recognizable pattern
        mem[0]  = 32'hAAAA0000;
        mem[4]  = 32'hBBBB0001;
        mem[8]  = 32'hCCCC0002;
        mem[12] = 32'hDDDD0003;
        mem[16] = 32'hEEEE0004;
        // ... etc
    end

    always @(*) begin
        I = mem[A];
    end
endmodule

*/
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

    // ============================
    // DEBUG: monitorear lo que pasa por MEM→WB
    // ============================
    // Asumiendo:
    //   wb_ctrl_out[4] = L    (load, usar dato de memoria)
    //   wb_ctrl_out[3] = RF_LE_WB (enable de escritura al RF)
    //
    // Puedes cambiar la condición if (...) como quieras:
    //   - solo cuando RF_LE_WB=1
    //   - o siempre, mientras debuggeas.
    // ============================
    /*
    always @(posedge clk) begin
        if (!reset) begin
            // Modo “verboso”: imprime siempre
            $display("WB_PIPE @t=%0t | mem_ctrl_in=%h pw_data_in=%h rd_in=%0d | wb_ctrl_out=%h pw_data_out=%h rd_out=%0d | L=%b RF_LE_WB=%b",
                     $time,
                     mem_ctrl_in, pw_data_in, rd_in,
                     wb_ctrl_out, pw_data_out, rd_out,
                     wb_ctrl_out[4], wb_ctrl_out[3]);

            // Si quieres verlo solo cuando intenta escribir al RF, comenta lo de arriba
            // y descomenta esto:
            
            if (wb_ctrl_out[3]) begin
                $display("WB WRITE @t=%0t | rd=%0d pw=%h | ctrl=%h (L=%b RF_LE_WB=%b)",
                         $time,
                         rd_out, pw_data_out,
                         wb_ctrl_out, wb_ctrl_out[4], wb_ctrl_out[3]);
            end
           
        end
    end */

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
/*
Tarea:
En el diagrama de la página siguiente se muestra un diagrama de bloque y la tabla de la verdad del circuito que
se debe implementar. Este es un circuito combinacional (el efecto de las entradas se puede manifestar en las
salidas casi de manera instantánea). Según indica la tabla de la verdad, el circuito tiene como entradas un
número de 32 bits (R), un número de 22 bits (Imm) y cuatro bits (IS) que corresponden a bits de una
instrucción. El circuito tiene como salida un número N de 32 bits cuyo su valor depende de los inputs según
indica la tabla de la verdad. El símbolo || significa concatenación.
*/
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
/*
     // Debug display: todas las entradas y la salida
    $display("========== SOH ==========");
    $display("t   = %0t", $time);
    $display("Is  = %b",  Is);
    $display("R   = %b",  R);
    $display("Imm = %b",  Imm);
    $display("N   = %b",  N);
    $display("=========================\n");
    */
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
   // =============================================================
    // Debug display: contenido completo del Register File
    // =============================================================
    /*always @(posedge Clk) begin
        $display("==================================================");
        $display("t = %0t", $time);
        $display("RA = %0d", RA);
        $display("RB = %0d", RB);
        $display("RD = %0d", RD);
        $display("RW = %0d", RW);
        $display("PW = %d", PW);
        $display("LE = %b", LE);
        $display("PA = %h", PA);
        $display("PB = %h", PB);
        $display("PD = %h", PD);
        $display("----------------- REGISTERS ----------------------");
        $display("R0  = %d", r0);
        $display("R1  = %d", r1);
        $display("R2  = %d", r2);
        $display("R3  = %d", r3);
        $display("R4  = %d", r4);
        $display("R5  = %d", r5);
        $display("R6  = %d", r6);
        $display("R7  = %d", r7);
        $display("R8  = %d", r8);
        $display("R9  = %d", r9);
        $display("R10 = %d", r10);
        $display("R11 = %d", r11);
        $display("R12 = %d", r12);
        $display("R13 = %d", r13);
        $display("R14 = %d", r14);
        $display("R15 = %d", r15);
        $display("R16 = %d", r16);
        $display("R17 = %d", r17);
        $display("R18 = %d", r18);
        $display("R19 = %d", r19);
        $display("R20 = %d", r20);
        $display("R21 = %d", r21);
        $display("R22 = %d", r22);
        $display("R23 = %d", r23);
        $display("R24 = %d", r24);
        $display("R25 = %d", r25);
        $display("R26 = %d", r26);
        $display("R27 = %d", r27);
        $display("R28 = %d", r28);
        $display("R29 = %d", r29);
        $display("R30 = %d", r30);
        $display("R31 = %d", r31);
        $display("==================================================\n");
    end
*/
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
    // OJO: usa el nombre real de tu módulo de memoria de instrucciones
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
/*
module tb_fetch_stage_path;

    // Clock and reset
    reg clk;
    reg reset;

    // Control / inputs
    reg LE_DHDU;
    reg pc_LE;
    reg npc_LE;
    reg call;
    reg J;
    reg jmpl;
    reg [8:0] TA;
    reg [8:0] ALU_out;

    // Outputs
    wire [31:0] instr_F;
    wire [8:0]  B_PC;
    wire [8:0]  PC_out;
    wire [8:0]  nPC_out;

    // ===============================
    // DUT: fetch_stage_path instance
    // ===============================
    fetch_stage_path #(
        .ADDR_WIDTH(9),
        .INST_WIDTH(32),
        .RESET_PC(9'd0),
        .RESET_nPC(9'd4)
    ) DUT (
        .clk      (clk),
        .reset    (reset),
        .LE_DHDU  (LE_DHDU),

        .pc_LE    (pc_LE),
        .npc_LE   (npc_LE),

        .call     (call),
        .J        (J),
        .jmpl     (jmpl),

        .TA       (TA),
        .ALU_out  (ALU_out),

        .instr_F  (instr_F),
        .B_PC     (B_PC),

        .PC_out   (PC_out),
        .nPC_out  (nPC_out)
    );

    // ===============================
    // Clock generation
    // ===============================
    initial begin
        clk = 0;
        forever #2 clk = ~clk;   // toggle every 2ns → rising edges at 2,6,10,...
    end

    // ===============================
    // Stimulus
    // ===============================
    initial begin
        // Default values
        LE_DHDU  = 1'b1;   // no stalls for now
        pc_LE    = 1'b1;
        npc_LE   = 1'b1;
        call     = 1'b0;
        J        = 1'b0;
        jmpl     = 1'b0;
        TA       = 9'd0;
        ALU_out  = 9'd0;

        // Apply reset
        reset = 1'b1;
        #3;
        reset = 1'b0;

        // Let it run “sequentially” for a while
        #40;

        // Example: simulate a branch taken to TA = 32
        TA   = 9'd32;
        J    = 1'b1;   // branch or call asserted for one cycle
        #4;
        J    = 1'b0;

        // Let it run more
        #40;

        $finish;
    end

    // ===============================
    // Debug prints
    // ===============================
    initial begin
        $display("time | PC  nPC  B_PC  instr_F");
        $monitor("t=%0t | PC=%0d  nPC=%0d  B_PC=%0d  instr=%h",
                 $time, PC_out, nPC_out, B_PC, instr_F);
    end

endmodule
*/







//////////////////////////////
/*
module execution_stage_path (
    // Entradas
    input  wire [31:0] A_EX,          // operando A desde RF
    input  wire [31:0] B_EX,          // operando B desde RF
    input  wire [31:0] instr_EX,      // instrucción en EX
    input  wire [31:0] ex_ctrl_in,    // pasa directo a MEM
    input  wire [31:0] D_EX,          // pasa directo a MEM
    input  wire        C_flag,        // Carry del PSR (cuando aplique)

    // Salidas
    output wire [31:0] ALU_mux_out,
    output wire [4:0]  RD_EX_out,
    output wire [3:0]  CC_EX, 
    output wire [31:0] ex_ctrl_out,
    output wire [31:0] D_MEM_out,
    output wire        L_EX,
    output wire        RF_LE_EX
);

    // -----------------------------------------
    // Decode de la instrucción
    // -----------------------------------------
    wire [4:0] RD_EX  = instr_EX[29:25];
    //wire [4:0] RS1_EX = instr_EX[18:14];
    //wire [4:0] RS2_EX = instr_EX[4:0];

    // -----------------------------------------
    // Señales de control del EX stage
    // -----------------------------------------
    wire [3:0] ALU_OP  = ex_ctrl_in[16:13];
    wire [3:0] SOH_OP  = ex_ctrl_in[12:9];
    wire       CALLbit = ex_ctrl_in[2];

    // -----------------------------------------
    // SOH UNIT
    // -----------------------------------------
    wire [31:0] SOH_out;

    SOH soh0 (
        .R   (B_EX),
        .Imm (instr_EX[21:0]),
        .Is  (SOH_OP),
        .N   (SOH_out)
    );

    // -----------------------------------------
    // ALU
    // -----------------------------------------
    wire [31:0] ALU_Out_EX;
    wire Z_EX, N_EX, C_EX, V_EX;

    ALU alu0 (
        .Out (ALU_Out_EX),
        .Z   (Z_EX),
        .N   (N_EX),
        .C   (C_EX),
        .V   (V_EX),
        .A   (A_EX),
        .B   (SOH_out),
        .Ci  (C_flag),
        .OP  (ALU_OP)
    );

    assign CC_EX = {N_EX, Z_EX, V_EX, C_EX};

    // -----------------------------------------
    // MUX para CALL (rd = 15)
    // -----------------------------------------
    assign RD_EX_out = (CALLbit) ? 5'd15 : RD_EX;

    // -----------------------------------------
    // Sin PC en EX → pasar ALU directamente
    // -----------------------------------------
    assign ALU_mux_out = ALU_Out_EX;  

    // -----------------------------------------
    // Señales directas hacia MEM
    // -----------------------------------------
    assign ex_ctrl_out = ex_ctrl_in;
    assign D_MEM_out   = D_EX;
    assign L_EX        = ex_ctrl_in[4];
    assign RF_LE_EX    = ex_ctrl_in[3];

     // =============================================================
    // Debug: monitoreo de señales de la ALU en EX
    // =============================================================
    
    initial begin
        $display("======== MONITOREO ALU (EX STAGE) ========");
        $display("t | ALU_OP | Ci | A_EX | SOH_out(B) | ALU_Out_EX | Z N C V");
        $display("==========================================");
    end

    always @(*) begin
      
        $display("  ALU_MUX_OUT del path  = %d", ALU_mux_out);
        $display("  ALU_Out_EX del path  = %d",  ALU_Out_EX);
       
        $display("------------------------------------------\n");
    end


endmodule
*/
/*
`timescale 1ns / 1ps

module tb_execution_stage_path;

    // ============================
    // DUT inputs
    // ============================
    reg [31:0] A_EX;
    reg [31:0] B_EX;
    reg [31:0] instr_EX;
    reg [31:0] ex_ctrl_in;
    reg [31:0] D_EX;
    reg        C_flag;

    // ============================
    // DUT outputs
    // ============================
    wire [31:0] ALU_mux_out;
    wire [4:0]  RD_EX_out;
    wire [3:0]  CC_EX;
    wire [31:0] ex_ctrl_out;
    wire [31:0] D_MEM_out;
    wire        L_EX;
    wire        RF_LE_EX;

    // ============================
    // Device Under Test
    // ============================
    execution_stage_path DUT (
        .A_EX       (A_EX),
        .B_EX       (B_EX),
        .instr_EX   (instr_EX),
        .ex_ctrl_in (ex_ctrl_in),
        .D_EX       (D_EX),
        .C_flag     (C_flag),

        .ALU_mux_out(ALU_mux_out),
        .RD_EX_out  (RD_EX_out),
        .CC_EX      (CC_EX),
        .ex_ctrl_out(ex_ctrl_out),
        .D_MEM_out  (D_MEM_out),
        .L_EX       (L_EX),
        .RF_LE_EX   (RF_LE_EX)
    );

    // ============================
    // Localparams for control bits
    // Adjust these to match your ALU encoding!
    // ============================
    localparam [3:0] ALUOP_ADD = 4'b0000; // TODO: set to your real ADD code
    localparam [3:0] ALUOP_SUB = 4'b0001; // TODO: set to your real SUB code

    // For SOH_OP, we assume:
    // - one value that passes through R (B_EX)
    // - one value that uses Imm (instr[21:0]) somehow
    // Adjust to match your SOH unit truth table.
    localparam [3:0] SOH_R    = 4'b0000; // use B_EX directly
    localparam [3:0] SOH_IMM  = 4'b0001; // use Imm (example)

    // Bit positions in ex_ctrl_in:
    // ex_ctrl_in[16:13] = ALU_OP
    // ex_ctrl_in[12:9]  = SOH_OP
    // ex_ctrl_in[4]     = L_EX
    // ex_ctrl_in[3]     = RF_LE_EX
    // ex_ctrl_in[2]     = CALLbit

    // ============================
    // Helper to build instr_EX with RD, RS1, RS2
    // ============================
    function [31:0] make_reg_instr;
        input [4:0] rd;
        input [4:0] rs1;
        input [4:0] rs2;
        reg   [31:0] tmp;
    begin
        tmp            = 32'b0;
        tmp[29:25]     = rd;
        tmp[18:14]     = rs1;
        tmp[4:0]       = rs2;
        make_reg_instr = tmp;
    end
    endfunction

    // ============================
    // Helper: pack ex_ctrl_in fields
    // ============================
    task set_ex_ctrl;
        input [3:0] alu_op;
        input [3:0] soh_op;
        input       L_bit;
        input       RF_LE_bit;
        input       CALLbit;
    begin
        ex_ctrl_in = 32'b0;
        ex_ctrl_in[16:13] = alu_op;
        ex_ctrl_in[12:9]  = soh_op;
        ex_ctrl_in[4]     = L_bit;
        ex_ctrl_in[3]     = RF_LE_bit;
        ex_ctrl_in[2]     = CALLbit;
    end
    endtask

    // ============================
    // Simple checker tasks
    // ============================
    task check_pass_through_ctrl;
    begin
        if (ex_ctrl_out !== ex_ctrl_in) begin
            $display("**ERROR: ex_ctrl_out != ex_ctrl_in. ex_ctrl_out=%h ex_ctrl_in=%h",
                     ex_ctrl_out, ex_ctrl_in);
        end
        if (L_EX !== ex_ctrl_in[4])
            $display("**ERROR: L_EX != ex_ctrl_in[4]. L_EX=%b expected=%b",
                     L_EX, ex_ctrl_in[4]);
        if (RF_LE_EX !== ex_ctrl_in[3])
            $display("**ERROR: RF_LE_EX != ex_ctrl_in[3]. RF_LE_EX=%b expected=%b",
                     RF_LE_EX, ex_ctrl_in[3]);
    end
    endtask

    task check_D_pass;
    begin
        if (D_MEM_out !== D_EX)
            $display("**ERROR: D_MEM_out != D_EX. D_MEM_out=%h D_EX=%h",
                     D_MEM_out, D_EX);
    end
    endtask

    task check_RD_normal;
        input [4:0] expected_rd;
    begin
        if (RD_EX_out !== expected_rd)
            $display("**ERROR: RD_EX_out mismatch (CALLbit=0). RD_EX_out=%0d expected=%0d",
                     RD_EX_out, expected_rd);
    end
    endtask

    task check_RD_call;
    begin
        if (RD_EX_out !== 5'd15)
            $display("**ERROR: RD_EX_out mismatch (CALLbit=1). RD_EX_out=%0d expected=15",
                     RD_EX_out);
    end
    endtask

    // ============================
    // Main stimulus
    // ============================
    initial begin
        $display("=== Start of execution_stage_path test ===");

        // Default inputs
        A_EX      = 32'd0;
        B_EX      = 32'd0;
        instr_EX  = 32'd0;
        ex_ctrl_in = 32'd0;
        D_EX      = 32'd0;
        C_flag    = 1'b0;

        #5;

        // -----------------------------------------
        // Phase 1: Simple ALU test with SOH passing B_EX
        // -----------------------------------------
        $display("\n[Phase 1] ALU basic operation with SOH passing B_EX (no CALL)");

        A_EX     = 32'd10;
        B_EX     = 32'd3;
        instr_EX = make_reg_instr(5'd4, 5'd1, 5'd2); // RD=4, RS1=1, RS2=2 (for decode only)
        D_EX     = 32'hDEAD_BEEF;
        C_flag   = 1'b0;

        // ex_ctrl: ADD, SOH_R (pass B_EX), L_EX=1, RF_LE_EX=1, CALLbit=0
        set_ex_ctrl(ALUOP_ADD, SOH_R, 1'b1, 1'b1, 1'b0);

        #1; // allow combinational to settle

        // Checks:
        check_pass_through_ctrl();
        check_D_pass();
        check_RD_normal(5'd4);

        $display("  A_EX=%0d, B_EX=%0d, ALU_mux_out=%0d, CC_EX=%b",
                 A_EX, B_EX, ALU_mux_out, CC_EX);
        $display("  ex_ctrl_in =%h ex_ctrl_out=%h L_EX=%b RF_LE_EX=%b",
                 ex_ctrl_in, ex_ctrl_out, L_EX, RF_LE_EX);
        $display("  D_EX=%h D_MEM_out=%h", D_EX, D_MEM_out);

        // If ALUOP_ADD really means A+B, you would expect ALU_mux_out = 13 here.
        // Adjust ALUOP_ADD to match your actual ALU encoding.

        // -----------------------------------------
        // Phase 2: ALU with carry-in and different ALU_OP
        // -----------------------------------------
        $display("\n[Phase 2] ALU with carry-in, different ALU_OP (e.g., SUB)");

        A_EX   = 32'd20;
        B_EX   = 32'd5;
        C_flag = 1'b1;

        // ex_ctrl: SUB, SOH_R, L_EX=0, RF_LE_EX=1, CALLbit=0
        set_ex_ctrl(ALUOP_SUB, SOH_R, 1'b0, 1'b1, 1'b0);

        #1;

        check_pass_through_ctrl();
        check_D_pass();
        check_RD_normal(5'd4);

        $display("  A_EX=%0d, B_EX=%0d, C_flag=%b, ALU_mux_out=%0d, CC_EX=%b",
                 A_EX, B_EX, C_flag, ALU_mux_out, CC_EX);
        $display("  (Interpret CC_EX={N,Z,V,C} according to your ALU design)");

        // -----------------------------------------
        // Phase 3: SOH using Imm instead of B_EX
        // -----------------------------------------
        $display("\n[Phase 3] SOH using immediate (Imm) instead of B_EX (check path A->SOH->ALU)");

        // Example: set some immediate in instr[21:0]
        instr_EX         = make_reg_instr(5'd6, 5'd1, 5'd2);
        instr_EX[21:0]   = 22'd7;  // immediate value 7, interpret per your SOH design

        A_EX   = 32'd5;
        B_EX   = 32'd999; // should be ignored if SOH_OP uses Imm
        C_flag = 1'b0;

        // ex_ctrl: ADD, SOH_IMM, L_EX=0, RF_LE_EX=0, CALLbit=0
        set_ex_ctrl(ALUOP_ADD, SOH_IMM, 1'b0, 1'b0, 1'b0);

        #1;

        check_pass_through_ctrl();
        check_D_pass();
        check_RD_normal(5'd6);

        $display("  instr_EX[21:0]=%0d, A_EX=%0d, B_EX=%0d, ALU_mux_out=%0d, CC_EX=%b",
                 instr_EX[21:0], A_EX, B_EX, ALU_mux_out, CC_EX);
        $display("  (Verify that SOH_out uses the Imm as expected in your SOH unit)");

        // -----------------------------------------
        // Phase 4: CALLbit behavior (RD override to 15)
        // -----------------------------------------
        $display("\n[Phase 4] CALLbit behavior (RD_EX_out should become 15 when CALLbit=1)");

        // Base instruction with RD=9
        instr_EX = make_reg_instr(5'd9, 5'd1, 5'd2);
        A_EX     = 32'd100;
        B_EX     = 32'd200;

        // CALLbit=0
        set_ex_ctrl(ALUOP_ADD, SOH_R, 1'b0, 1'b0, 1'b0);
        #1;
        check_RD_normal(5'd9);
        $display("  CALLbit=0, instr.RD=9 -> RD_EX_out=%0d (expected 9)", RD_EX_out);

        // CALLbit=1
        set_ex_ctrl(ALUOP_ADD, SOH_R, 1'b0, 1'b0, 1'b1);
        #1;
        check_RD_call();
        $display("  CALLbit=1, instr.RD=9 -> RD_EX_out=%0d (expected 15)", RD_EX_out);

        // -----------------------------------------
        // Phase 5: Control pass-through and D_EX with different patterns
        // -----------------------------------------
        $display("\n[Phase 5] Stress control bits and D_EX pass-through");

        D_EX = 32'h1234_5678;
        set_ex_ctrl(ALUOP_ADD, SOH_R, 1'b1, 1'b0, 1'b0);  // L_EX=1, RF_LE_EX=0
        #1;
        check_pass_through_ctrl();
        check_D_pass();
        $display("  ex_ctrl_in=%h ex_ctrl_out=%h L_EX=%b RF_LE_EX=%b D_MEM_out=%h",
                 ex_ctrl_in, ex_ctrl_out, L_EX, RF_LE_EX, D_MEM_out);

        D_EX = 32'h8765_4321;
        set_ex_ctrl(ALUOP_SUB, SOH_IMM, 1'b0, 1'b1, 1'b0); // L_EX=0, RF_LE_EX=1
        #1;
        check_pass_through_ctrl();
        check_D_pass();
        $display("  ex_ctrl_in=%h ex_ctrl_out=%h L_EX=%b RF_LE_EX=%b D_MEM_out=%h",
                 ex_ctrl_in, ex_ctrl_out, L_EX, RF_LE_EX, D_MEM_out);

        // -----------------------------------------
        // Done
        // -----------------------------------------
        $display("\n=== End of execution_stage_path test ===");
        $finish;
    end

    // ============================
    // Continuous monitoring (for waveform + console sanity)
    // ============================
    initial begin
        $display("Time | instr_EX          | RD | A_EX        B_EX        | ALU_mux_out   CC_EX ex_ctrl_in      ex_ctrl_out     D_EX        D_MEM_out    L RFLE C");
        $monitor("t=%0t | %h | %2d | %8h %8h | %8h %b %8h %8h %8h %8h %b %b %b",
                 $time,
                 instr_EX,
                 instr_EX[29:25],
                 A_EX, B_EX,
                 ALU_mux_out, CC_EX,
                 ex_ctrl_in, ex_ctrl_out,
                 D_EX, D_MEM_out,
                 L_EX, RF_LE_EX, C_flag);
    end

endmodule
*/

///////////////////////////
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
    always @(posedge clk) begin
    $display("ex ctrl in : %b", ex_ctrl_in);
    $display("id ctrl out: %b", id_ctrl_out);
end

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
        .LE (RF_LE_WB),   //RF_LE_WB     -------------------------->>>>>>>>>>>>>>>> cambiar esto 
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
        .ICC(CC_EX),
        .clock(clk),
        .rst(reset),
        .CC_OUT(CCR_out),
        .carry_out(carry_out)
    );

    TwoToOneMux #(.WIDTH(4)) ccr_mux (
        .in0 (CCR_out),
        .in1 (CC_EX),
        .sel (ex_ctrl_in[17]),
        .out (CCR_out_muxed)
    );

    // ------------------------------------------------------------
    // CH: condition handler (combinacional) -> produce J (branch taken)
    // CH expects: BI, cond, ACC[3:0] -> J
    // Mapear BI y cond desde instr_ID (ajusta según tu encoding)
    // ------------------------------------------------------------
    wire BI   = id_ctrl_out[0];         // asunción: bit 30 = BI (ajusta si hace falta)
    wire [3:0] cond = instr_ID[28:25]; ////////////////////////////////////////////////////////////////////////////////
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
/*   
    always @(posedge clk) begin
        $display("ID @t=%0t | instr_ID=%h instr_EX=%h | id_ctrl_out=%h",
                 $time, instr_ID, instr_EX, id_ctrl_out);
    end
*/

endmodule

/*
`timescale 1ns / 1ps

module tb_decoding_stage_path;

    // ============================
    // DUT inputs
    // ============================
    reg         clk;
    reg         reset;

    reg  [8:0]  B_PC_ID;
    reg  [31:0] instr_ID;

    // Forwarding / later stages
    reg  [31:0] ALU_Out_EX;
    reg  [31:0] data_mem_mux;
    reg  [31:0] PW_WB;
    reg  [4:0]  RW_WB;
    reg         RF_LE_WB;
    reg         NOP;
    reg         LE_DHDU;      // not used inside, but drive it anyway

    // CCR / control
    reg  [3:0]  ALU_CC;
    reg  [31:0] ex_ctrl_in;

    // DHDU selects
    reg  [1:0]  A_S;
    reg  [1:0]  B_S;
    reg  [1:0]  D_S;

    // ============================
    // DUT outputs
    // ============================
    wire [31:0] A_src;
    wire [31:0] B_src;
    wire [31:0] D_src;
    wire [31:0] instr_EX;
    wire [8:0]  TA;
    wire        J;
    wire        carry_out;
    wire [31:0] id_ctrl_out;

    // ============================
    // Device Under Test
    // ============================
    decoding_stage_path #(
        .ADDR_WIDTH(9),
        .RESET_PC(9'd0),
        .RESET_nPC(9'd4)
    ) DUT (
        .clk        (clk),
        .reset      (reset),

        .B_PC_ID    (B_PC_ID),
        .instr_ID   (instr_ID),

        .ALU_Out_EX (ALU_Out_EX),
        .data_mem_mux (data_mem_mux),
        .PW_WB      (PW_WB),
        .RW_WB      (RW_WB),
        .RF_LE_WB   (RF_LE_WB),
        .NOP        (NOP),
        .LE_DHDU    (LE_DHDU),

        .ALU_CC     (ALU_CC),
        .ex_ctrl_in (ex_ctrl_in),

        .A_S        (A_S),
        .B_S        (B_S),
        .D_S        (D_S),

        .A_src      (A_src),
        .B_src      (B_src),
        .D_src      (D_src),
        .instr_EX   (instr_EX),
        .TA         (TA),
        .J          (J),
        .carry_out  (carry_out),
        .id_ctrl_out(id_ctrl_out)
    );

    // ============================================================
    // Clock generation: 4ns period (rising at 2, 6, 10, ...)
    // ============================================================
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;
    end

    // ============================================================
    // Helper: build a fake "R-type" instruction with rd, rs1, rs2
    // NOTE: This only cares about the register fields used by ID:
    //   RD = bits [29:25]
    //   RS1 = bits [18:14]
    //   RS2 = bits [4:0]
    // The rest of the bits are left as 0.
    // ============================================================
    function [31:0] make_reg_instr;
        input [4:0] rd;
        input [4:0] rs1;
        input [4:0] rs2;
        reg   [31:0] tmp;
    begin
        tmp             = 32'b0;
        tmp[29:25]      = rd;
        tmp[18:14]      = rs1;
        tmp[4:0]        = rs2;
        make_reg_instr  = tmp;
    end
    endfunction

    // ============================================================
    // Helper: write one register via WB interface
    // NOTE: In your current decoding_stage_path, the RF LE is hardwired
    //       to 1'b1 inside REG_FILE, so RF_LE_WB is ignored.
    //       Here we treat writes as "any posedge with RW_WB & PW_WB set".
    // ============================================================
    task write_reg;
        input [4:0]  rw;
        input [31:0] data;
    begin
        @(negedge clk);
        RW_WB <= rw;
        PW_WB <= data;
        // LE is effectively 1'b1 inside REG_FILE
        @(posedge clk);
        #1;  // small delay to allow write to settle
        // After writing, we can move writes to register 0 so we don't
        // keep overwriting others each cycle.
        RW_WB <= 5'd0;
        PW_WB <= 32'h0000_0000;
    end
    endtask

    // ============================================================
    // Main stimulus
    // Phases:
    //  1) Reset + defaults
    //  2) Write a few registers via WB and read them (no forwarding)
    //  3) Exercise forwarding muxes (A_S/B_S/D_S)
    //  4) Test NOP signal on control (id_ctrl_out -> 0)
    //  5) Simple CCR/CH behavior example (manual observation)
    // ============================================================
    initial begin
        // ============================
        // Phase 0: default values
        // ============================
        B_PC_ID      = 9'd0;
        instr_ID     = 32'd0;

        ALU_Out_EX   = 32'hAAAA_BBBB;
        data_mem_mux = 32'hCCCC_DDDD;
        PW_WB        = 32'hEEEE_FFFF;
        RW_WB        = 5'd0;
        RF_LE_WB     = 1'b1;      // not used inside, but set it

        NOP          = 1'b0;
        LE_DHDU      = 1'b1;

        ALU_CC       = 4'b0000;
        ex_ctrl_in   = 32'd0;

        A_S          = 2'b00;
        B_S          = 2'b00;
        D_S          = 2'b00;

        // ============================
        // Phase 1: reset
        // ============================
        reset = 1'b1;
        #5;
        reset = 1'b0;

        $display("=== Start of decoding_stage_path test ===");

        // ============================
        // Phase 2: write some registers via WB
        // ============================
        $display("\n[Phase 2] Writing registers via WB interface...");

        // Write R1, R2, R3
        write_reg(5'd1, 32'h1111_1111);
        write_reg(5'd2, 32'h2222_2222);
        write_reg(5'd3, 32'h3333_3333);

        // ============================
        // Now select them via RA/RB/RD using instr_ID
        // RA = 1, RB = 2, RD = 3
        // A_src <- R1, B_src <- R2, D_src <- R3 when A_S=B_S=D_S=0
        // ============================
        instr_ID = make_reg_instr(5'd3, 5'd1, 5'd2);
        B_PC_ID  = 9'd100;   // arbitrary PC for TAG

        A_S = 2'b00;
        B_S = 2'b00;
        D_S = 2'b00;

        @(posedge clk);
        #1;  // allow combinational logic to settle

        $display("[Phase 2] No forwarding (A_S=B_S=D_S=00)");
        $display("  Expected: A_src=R1=0x11111111, B_src=R2=0x22222222, D_src=R3=0x33333333");
        $display("  Got      A_src=%h B_src=%h D_src=%h", A_src, B_src, D_src);

        if (A_src !== 32'h1111_1111)
            $display("  **ERROR: A_src mismatch**");
        if (B_src !== 32'h2222_2222)
            $display("  **ERROR: B_src mismatch**");
        if (D_src !== 32'h3333_3333)
            $display("  **ERROR: D_src mismatch**");

        // ============================
        // Phase 3: Forwarding muxes
        // ============================
        $display("\n[Phase 3] Testing forwarding muxes A/B/D...");

        // We'll keep RA/RB/RD as before, but change selects and upstream data.
        ALU_Out_EX   = 32'hAAAA_BBBB;
        data_mem_mux = 32'hCCCC_DDDD;
        PW_WB        = 32'hEEEE_FFFF;

        // --- sel = 01 -> ALU_Out_EX ---
        A_S = 2'b01;
        B_S = 2'b01;
        D_S = 2'b01;
        @(posedge clk); #1;
        $display("  sel=01 (ALU_Out_EX): A_src=%h B_src=%h D_src=%h (expected AAAA_BBBB)", 
                 A_src, B_src, D_src);

        // --- sel = 10 -> data_mem_mux ---
        A_S = 2'b10;
        B_S = 2'b10;
        D_S = 2'b10;
        @(posedge clk); #1;
        $display("  sel=10 (data_mem_mux): A_src=%h B_src=%h D_src=%h (expected CCCC_DDDD)",
                 A_src, B_src, D_src);

        // --- sel = 11 -> PW_WB ---
        A_S = 2'b11;
        B_S = 2'b11;
        D_S = 2'b11;
        @(posedge clk); #1;
        $display("  sel=11 (PW_WB): A_src=%h B_src=%h D_src=%h (expected EEEE_FFFF)",
                 A_src, B_src, D_src);

        // ============================
        // Phase 4: NOP test (control_unit gating)
        // ============================
        $display("\n[Phase 4] Testing NOP gating on control signals (NOP_mux_CU)...");

        // First, NOP = 0 (normal operation)
        NOP = 1'b0;
        @(posedge clk); #1;
        $display("  NOP=0  -> id_ctrl_out=%h, J=%b (from real control_unit)", id_ctrl_out, J);

        // Then NOP = 1 (control_signals should be forced to 0)
        NOP = 1'b1;
        @(posedge clk); #1;
        $display("  NOP=1  -> id_ctrl_out=%h, J=%b (expected id_ctrl_out=0)", id_ctrl_out, J);
        if (id_ctrl_out !== 32'd0)
            $display("  **ERROR: id_ctrl_out not zero under NOP=1**");

        // ============================
        // Phase 5: Simple CCR / CH example
        // NOTE: This depends on your control_unit + CH implementation.
        // Here we just show how to drive it so you can inspect J / carry_out.
        // ============================
        $display("\n[Phase 5] Simple CCR/CH observation...");

        NOP      = 1'b0;   // allow real control_signals
        ALU_CC   = 4'b0010; // e.g., set Z flag or something per your design

        // Build an "instruction" with some cond bits in [28:25]
        //   For example: cond = 4'b1000 (often 'always' in SPARC),
        //   but adjust according to your CH encoding.
        instr_ID = make_reg_instr(5'd3, 5'd1, 5'd2);
        instr_ID[28:25] = 4'b1000; // overwrite cond field

        @(posedge clk); #1;
        $display("  After ALU_CC=%b, cond=%b -> carry_out=%b, J=%b, CCR/CH behavior depends on your logic.",
                 ALU_CC, instr_ID[28:25], carry_out, J);
        $display("  id_ctrl_out=%h", id_ctrl_out);

        // At this point, you should open the waveform and:
        //  - Inspect CCR_out inside DUT.u_CCR
        //  - Inspect ACC input to CH and J output
        //  - See how id_ctrl_out[17] (CC_EN) affects CCR updates

        // ============================
        // Done
        // ============================
        #20;
        $display("\n=== End of decoding_stage_path test ===");
        $finish;
    end

    // ============================================================
    // Continuous monitoring (optional, helps see what is happening)
    // ============================================================
    
    initial begin
        $display("\nTime | instr_ID          | RA RB RD | A_src       B_src       D_src       | TA   J carry id_ctrl_out");
        $monitor("t=%0t | %h | %2d %2d %2d | %h %h %h | %3d  %b   %b   %h",
                 $time,
                 instr_ID,
                 instr_ID[18:14], instr_ID[4:0], instr_ID[29:25],
                 A_src, B_src, D_src,
                 TA, J, carry_out, id_ctrl_out);
    end
    
        // ============================================================
    // Extra RF debug: show R5, R6, R16, R17, R18 every cycle
    // ============================================================
    initial begin
        $display("\nTime | R5         R6         R16        R17        R18");
        forever begin
            @(posedge clk);
            #1; // small delay to let write settle
            $display("t=%0t | %h %h %h %h %h %h %h %h",
                     $time,
                     DUT.REG_FILE.r1,
                     DUT.REG_FILE.r2,
                     DUT.REG_FILE.r3,
                     DUT.REG_FILE.r5,
                     DUT.REG_FILE.r6,
                     DUT.REG_FILE.r16,
                     DUT.REG_FILE.r17,
                     DUT.REG_FILE.r18);
        end
    end


endmodule

*/


//////////////////////////////////////////

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

/*
`timescale 1ns / 1ps

module tb_memory_stage_path;

    // ============================
    // DUT inputs
    // ============================
    reg [31:0] alu_result_in;
    reg [31:0] mem_ctrl_in;
    reg [4:0]  rd_in;
    reg [31:0] DI;

    // ============================
    // DUT outputs
    // ============================
    wire [31:0] data_mux_out;
    wire [31:0] mem_ctrl_out;
    wire [4:0]  rd_out;

    // ============================
    // Device Under Test
    // ============================
    memory_stage_path DUT (
        .alu_result_in (alu_result_in),
        .mem_ctrl_in   (mem_ctrl_in),
        .rd_in         (rd_in),
        .DI            (DI),

        .data_mux_out  (data_mux_out),
        .mem_ctrl_out  (mem_ctrl_out),
        .rd_out        (rd_out)
    );

    // ============================
    // Convenience: decode control bits
    // (for prints, not needed by DUT)
    // ============================
    wire [1:0] Size = mem_ctrl_in[8:7];
    wire       RW   = mem_ctrl_in[6];
    wire       E    = mem_ctrl_in[5];
    wire       L    = mem_ctrl_in[4];

    // ============================
    // Helper: set mem_ctrl_in
    // ============================
    // Size: 2'b00 = byte, 2'b01 = halfword, 2'b10 = word (per your data_memory)
    // RW:   0 = read, 1 = write
    // E:    enable (used for writes)
    // L:    load to RF? (controls ALU vs memory in data_mux_out)
    task set_ctrl;
        input [1:0] size;
        input       rw;
        input       e;
        input       l;
    begin
        mem_ctrl_in = 32'b0;
        mem_ctrl_in[8:7] = size;
        mem_ctrl_in[6]   = rw;
        mem_ctrl_in[5]   = e;
        mem_ctrl_in[4]   = l;
    end
    endtask

    // ============================
    // Helper checkers
    // ============================
    task check_ctrl_pass;
    begin
        if (mem_ctrl_out !== mem_ctrl_in) begin
            $display("**ERROR: mem_ctrl_out != mem_ctrl_in. mem_ctrl_out=%h mem_ctrl_in=%h",
                     mem_ctrl_out, mem_ctrl_in);
        end
        if (rd_out !== rd_in) begin
            $display("**ERROR: rd_out != rd_in. rd_out=%0d rd_in=%0d", rd_out, rd_in);
        end
    end
    endtask

    // For comparing values, print both expected & actual
    task check_value;
        input [31:0] expected;
        input [31:0] actual;
        input [256*8-1:0] msg;
    begin
        if (actual !== expected) begin
            $display("**ERROR: %s. Expected=%h, Got=%h", msg, expected, actual);
        end else begin
            $display("  OK: %s. Value=%h", msg, actual);
        end
    end
    endtask

    // ============================
    // Main stimulus
    // ============================
    initial begin
        $display("=== Start of memory_stage_path test ===");

        // Default
        alu_result_in = 32'd0;
        mem_ctrl_in   = 32'd0;
        rd_in         = 5'd0;
        DI            = 32'd0;

        #5;

        // -----------------------------------------
        // Phase 1: No memory access, L=0 (ALU passthrough)
        // -----------------------------------------
        $display("\n[Phase 1] ALU passthrough when L=0 (no load)");

        alu_result_in = 32'hAAAA_BBBB;
        rd_in         = 5'd10;
        set_ctrl(2'b00, 1'b0, 1'b0, 1'b0); // Size=byte, RW=read, E=0, L=0
        #1;

        check_ctrl_pass();
        check_value(32'hAAAA_BBBB, data_mux_out, "L=0: data_mux_out should be alu_result_in");

        // -----------------------------------------
        // Phase 2: Word write & read (Size=10)
        // -----------------------------------------
        $display("\n[Phase 2] Word write & read (Size=2'b10)");

        // Write a word at address 0x10
        alu_result_in = 32'h0000_0010;   // address (lower 9 bits used by memory)
        DI            = 32'hDEAD_BEEF;   // data to write
        rd_in         = 5'd3;

        // Write: Size=word(10), RW=1, E=1, L=0
        set_ctrl(2'b10, 1'b1, 1'b1, 1'b0);
        #1;   // allow write to occur

        check_ctrl_pass();
        // For a pure write, data_mux_out = alu_result_in because L=0:
        check_value(alu_result_in, data_mux_out, "Word write: with L=0, data_mux_out should be alu_result_in");

        // Now read back: Size=word(10), RW=0, E=1, and set L=1 so mux chooses memory output
        set_ctrl(2'b10, 1'b0, 1'b1, 1'b1);
        #1;

        check_ctrl_pass();
        check_value(32'hDEAD_BEEF, data_mux_out, "Word read: data_mux_out should return stored 0xDEADBEEF");

        // -----------------------------------------
        // Phase 3: Halfword write & read (Size=01)
        // -----------------------------------------
        $display("\n[Phase 3] Halfword write & read (Size=2'b01)");

        // Write a halfword at address 0x20
        alu_result_in = 32'h0000_0020;
        DI            = 32'h0000_ABCD;   // Only low 16 bits are relevant
        rd_in         = 5'd7;

        // Write: Size=halfword(01), RW=1, E=1, L=0
        set_ctrl(2'b01, 1'b1, 1'b1, 1'b0);
        #1;

        check_ctrl_pass();
        check_value(alu_result_in, data_mux_out, "Halfword write: L=0, data_mux_out should be alu_result_in");

        // Read back: Size=halfword(01), RW=0, E=1, L=1
        set_ctrl(2'b01, 1'b0, 1'b1, 1'b1);
        #1;

        check_ctrl_pass();
        // With your data_memory coding:
        //   Memory[A]   = DI[15:8] = 0xAB
        //   Memory[A+1] = DI[7:0]  = 0xCD
        // Read case: {16'b0, Memory[A], Memory[A+1]} => 0x0000_ABCD
        check_value(32'h0000_ABCD, data_mux_out, "Halfword read: should get 0x0000ABCD");

        // -----------------------------------------
        // Phase 4: Byte write & read (Size=00)
        // -----------------------------------------
        $display("\n[Phase 4] Byte write & read (Size=2'b00)");

        // Write a byte at address 0x30
        alu_result_in = 32'h0000_0030;
        DI            = 32'h0000_00EF;   // Only low 8 bits are relevant
        rd_in         = 5'd12;

        // Write: Size=byte(00), RW=1, E=1, L=0
        set_ctrl(2'b00, 1'b1, 1'b1, 1'b0);
        #1;

        check_ctrl_pass();
        check_value(alu_result_in, data_mux_out, "Byte write: L=0, data_mux_out should be alu_result_in");

        // Read: Size=byte(00), RW=0, E=1, L=1
        set_ctrl(2'b00, 1'b0, 1'b1, 1'b1);
        #1;

        check_ctrl_pass();
        // data_memory read for byte: {24'b0, Memory[A]} => 0x000000EF
        check_value(32'h0000_00EF, data_mux_out, "Byte read: should get 0x000000EF");

        // -----------------------------------------
        // Phase 5: Test L=0 vs L=1 with a non-zero memory value
        // -----------------------------------------
        $display("\n[Phase 5] L=0 vs L=1 behavior (choose between ALU and memory)");

        // Reuse the word we wrote at address 0x10: 0xDEAD_BEEF
        alu_result_in = 32'h0000_0010;
        rd_in         = 5'd5;

        // Read word, but L=0: we should get ALU result, NOT memory
        set_ctrl(2'b10, 1'b0, 1'b1, 1'b0);
        #1;

        check_ctrl_pass();
        check_value(alu_result_in, data_mux_out,
                    "Word read with L=0: data_mux_out should be alu_result_in (bypass memory)");

        // Read word, with L=1: we should now see memory contents
        set_ctrl(2'b10, 1'b0, 1'b1, 1'b1);
        #1;

        check_ctrl_pass();
        check_value(32'hDEAD_BEEF, data_mux_out,
                    "Word read with L=1: data_mux_out should be loaded from memory");

        // -----------------------------------------
        // Done
        // -----------------------------------------
        $display("\n=== End of memory_stage_path test ===");
        $finish;
    end

    // ============================
    // Continuous monitor
    // ============================
    initial begin
        $display("Time | alu_result_in DI          | Size RW E L | data_mux_out  mem_ctrl_in   mem_ctrl_out  rd_in rd_out");
        $monitor("t=%0t | %8h %8h |  %b%b  %b %b | %8h  %8h  %8h  %2d    %2d",
                 $time,
                 alu_result_in, DI,
                 Size, RW, E, L,
                 data_mux_out,
                 mem_ctrl_in, mem_ctrl_out,
                 rd_in, rd_out);
    end

endmodule
*/

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
 
    
/*    
// =====================
// DEBUG DISPLAY FOR DECODING
// =====================
always @(posedge clk) begin
    if (!reset) begin
        $display("==== DECODING @t=%0t ====", $time);
        $display("  B_PC_ID     = %h", B_PC_ID);
        $display("  instr_ID    = %h", instr_ID);

        // Forwarding-related inputs
        $display("  ALU_out_EX  = %h", ALU_out_EX);
        $display("  data_mem_mux= %h", data_mux_out);
        $display("  PW_WB       = %h", PW_WB);
        $display("  RW_WB       = %0d", RW_WB);
        $display("  RF_LE_WB    = %b", RF_LE_WB);

        // DHDU & control
        $display("  NOP         = %b", NOP);
        $display("  LE_DHDU     = %b", LE_DHDU);
        $display("  ALU_CC      = %b", CC_EX);
        $display("  ex_ctrl_in  = %h", ex_ctrl_out);
        $display("  A_S         = %b", A_S);
        $display("  B_S         = %b", B_S);
        $display("  D_S         = %b", D_S);

        // Outputs towards EX
        $display("  A_EX (A_src)= %h", A_EX);
        $display("  B_EX (B_src)= %h", B_EX);
        $display("  D_EX (D_src)= %h", D_EX);
        $display("  instr_EX2   = %h", instr_EX2);
        $display("  TA          = %h", TA);
        $display("  J           = %b", J);
        $display("  carry_flag  = %b", carry_flag);
        $display("  id_ctrl_out = %h", id_ctrl_out);
        $display("========================\n");
    end
end

*/
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
    
    // ======================================================
    // ETAPA DE EJECUCIÓN (EX)
    // ======================================================
    /*execution_stage_path EX (
        .A_EX(A_EX2),
        .B_EX(B_EX2),
        .instr_EX(instr_EX3),
        .ex_ctrl_in(id_ctrl_out),
        .D_EX(D_EX2),
        .C_flag(carry_flag),

        .ALU_mux_out(ALU_out_EX2),
        .RD_EX_out(RD_EX_out),
        .CC_EX(CC_EX),
        .ex_ctrl_out(mempipe_ctrl_in),
        .D_MEM_out(D_MEM_tmp)
    );
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
    assign CC_EX        = {N_EX, Z_EX, V_EX, C_EX};
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
        .Ci  (Ci_to_ALU),
        .OP  (ALU_OP)
    );

    
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
  always @(posedge clk) begin
    if (!reset) begin
        $display("=============== EX STAGE @ t=%0t ===============", $time);
        // Entradas desde ID/EX
        $display("  instr_EX3        = %h", instr_EX3);
        $display("  ex_ctrl_out      = %h", ex_ctrl_out);
        $display("  A_EX2            = %h", A_EX2);
        $display("  B_EX2            = %h", B_EX2);
        $display("  D_EX2            = %h", D_EX2);
        $display("  carry_flag (Ci)  = %b", carry_flag);

        // Campos decodificados de la instrucción
        $display("  RD_EX            = %0d", RD_EX);
        $display("  RS1_EX           = %0d", RS1_EX);
        $display("  RS2_EX           = %0d", RS2_EX);

        // Señales de control para EX
        $display("  ALU_OP           = %b", ALU_OP);
        $display("  SOH_OP           = %b", SOH_OP);
        $display("  CALLbit          = %b", CALLbit);

        // SOH
        $display("  SOH_out          = %h", SOH_out);

        // ALU
        $display("  ALU_Out_EX2      = %h", ALU_Out_EX2);
        $display("  Z_EX             = %b", Z_EX);
        $display("  N_EX             = %b", N_EX);
        $display("  C_EX             = %b", C_EX);
        $display("  V_EX             = %b", V_EX);

        // Salidas hacia el resto del pipeline
        $display("  CC_EX            = %b", CC_EX);
        $display("  RD_EX_out        = %0d", RD_EX_out);
        $display("  mempipe_ctrl_in  = %h", mempipe_ctrl_in);
        $display("  D_MEM_tmp        = %h", D_MEM_tmp);
        $display("=================================================\n");
    end
  end
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
    /*
    always @(posedge clk) begin
        if (!reset) begin
            $display("ID/EX @t=%0t | alu in=%h data mux out=%b memcontrolIN=%b",
                     $time,
                    alu_result_in,
                   data_mux_out,
                    mem_ctrl_in);       
        end
    end
    */
    /*
    always @(posedge clk) begin
    if (!reset) begin
        $display("MEM @t=%0t | alu_result_in=%h mem_ctrl_in=%h rd_in=%0d DI=%h | data_mux_out=%h mem_ctrl_out=%h rd_mem=%0d",
                 $time,
                 alu_result_in,
                 mem_ctrl_in,
                 rd_in,
                 DI,
                 data_mux_out,
                 mem_ctrl_out,
                 rd_mem);
    end
end
    */
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


`timescale 1ns/1ps

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

    // ============================
    // Generación del reloj (toggle cada 2)
    // ============================
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;
    end

    // ============================
    // Reset: 1 → 0 en t = 3
    // ============================
    initial begin
        reset = 1'b1;
        #3 reset = 1'b0;
    end


    

    

    // =============================================================
    // Wires para debug de registros específicos (RF interno)
    // =============================================================
    wire signed [31:0] r5  = DUT.ID.REG_FILE.r5;
    wire signed [31:0] r6  = DUT.ID.REG_FILE.r6;
    wire signed [31:0] r16 = DUT.ID.REG_FILE.r16;
    wire signed [31:0] r17 = DUT.ID.REG_FILE.r17;
    wire signed [31:0] r18 = DUT.ID.REG_FILE.r18;

    // =============================================================
    // Imprimir en cada flanco de subida del reloj
    // =============================================================
/*
    initial begin
    $monitor("t=%0t | PC=%0d  r5=%0d  r6=%0d  r16=%0d  r17=%0d  r18=%0d",
             $time,
             DUT.PC_fetch,
             r5, r6, r16, r17, r18);
end
*/
    wire [1:0] opcode  = DUT.instr_ID[31:30];
    wire [3:0] cond    = DUT.instr_ID[28:25];
    wire [2:0] opcode2 = DUT.instr_ID[24:22];
    wire [5:0] opcode3 = DUT.instr_ID[24:19];

    
    always @(posedge clk) begin
        // pequeño delay opcional para que se actualicen señales
        #1;
        $display("------------------------------------------------");
        $write("t=%0t ns | PC=%0d | Z=%b, N=%b, C=%b, V=%b, Ci=%b CC_En control_unit", $time, DUT.PC_fetch, DUT.Z_EX, DUT.N_EX, DUT.C_EX, DUT.V_EX, DUT.Ci_to_ALU);

        // Manejo de NOP
        if (DUT.instr_ID === 32'b0) begin
            $write("Instr=NOP ");
        end else begin
            case (opcode)
                2'b00: begin 
                    case (opcode2)
                        3'b100: begin
                            $write("Instr=SETHI ");
                        end
                        default: begin
                            case (cond)
                                4'b1000: $write("Instr=BA ");
                                4'b0000: $write("Instr=BN ");
                                4'b1001: $write("Instr=BNE ");
                                4'b0001: $write("Instr=BE ");
                                4'b1010: $write("Instr=BG ");
                                4'b0010: $write("Instr=BLE ");
                                4'b1011: $write("Instr=BGE ");
                                4'b0011: $write("Instr=BL ");
                                4'b1100: $write("Instr=BGU ");
                                4'b0100: $write("Instr=BLEU ");
                                4'b1101: $write("Instr=BCC ");
                                4'b0101: $write("Instr=BCS ");
                                4'b1110: $write("Instr=BPOS ");
                                4'b0110: $write("Instr=BNEG "); 
                                4'b1111: $write("Instr=BVC ");
                                4'b0111: $write("Instr=BVS ");
                                default: $write("Instr=UNKNOWN COND ");
                            endcase
                        end
                    endcase
                end
                
                2'b01: begin
                    $write("Instr=CALL ");
                end

                2'b10: begin
                    case (opcode3)
                        // Basic Arithmetic Instructions
                        6'b000000: $write("Instr=ADD ");
                        6'b010000: $write("Instr=ADDCC ");
                        6'b001000: $write("Instr=ADDX ");
                        6'b011000: $write("Instr=ADDXCC ");
                        6'b000100: $write("Instr=SUB ");
                        6'b010100: $write("Instr=SUBCC ");
                        6'b001100: $write("Instr=SUBX ");
                        6'b011100: $write("Instr=SUBXCC ");

                        // Tagged Arithmetic Instructions
                        6'b100000: $write("Instr=TADDCC ");
                        6'b100010: $write("Instr=TADDCCTV ");
                        6'b100001: $write("Instr=TSUBCC ");
                        6'b100011: $write("Instr=TSUBCCTV ");

                        // Other Arithmetic Instructions
                        6'b100101: $write("Instr=MULSCC ");
                        6'b001010: $write("Instr=UMUL ");
                        6'b011010: $write("Instr=UMULCC ");
                        6'b001001: $write("Instr=SMUL ");
                        6'b011001: $write("Instr=SMULCC ");
                        6'b001110: $write("Instr=UDIV ");
                        6'b011110: $write("Instr=UDIVCC ");
                        6'b001111: $write("Instr=SDIV ");
                        6'b011111: $write("Instr=SDIVCC ");

                        // Logical Instructions
                        6'b000001: $write("Instr=AND ");
                        6'b010001: $write("Instr=ANDCC ");
                        6'b000101: $write("Instr=ANDN ");
                        6'b010101: $write("Instr=ANDNCC ");
                        6'b000010: $write("Instr=OR ");
                        6'b010010: $write("Instr=ORCC ");
                        6'b000110: $write("Instr=ORN ");
                        6'b010110: $write("Instr=ORNCC ");
                        6'b000011: $write("Instr=XOR ");
                        6'b010011: $write("Instr=XORCC ");
                        6'b000111: $write("Instr=XNOR ");
                        6'b010111: $write("Instr=XNORCC ");

                        // Shift Instructions
                        6'b100101: $write("Instr=SLL ");
                        6'b100110: $write("Instr=SRL ");
                        6'b100111: $write("Instr=SRA ");

                        // Save and Restore Instruction Format
                        6'b111100: $write("Instr=SAVE ");
                        6'b111101: $write("Instr=RESTORE ");

                        // JMPL Instruction
                        6'b111000: $write("Instr=JMPL ");

                        // Trap on Integer Condition Codes
                        6'b111010: $write("Instr=TRAP ");

                        // Return from Trap Instruction - RETT
                        6'b111001: $write("Instr=RETT ");

                        // Read State Register Instructions
                        6'b101001: $write("Instr=RDPSR ");
                        6'b101010: $write("Instr=RDWIM ");
                        6'b101011: $write("Instr=RDTBR ");

                        // Write State Register Instructions
                        6'b110001: $write("Instr=WRPSR ");
                        6'b110010: $write("Instr=WRWIM ");
                        6'b110011: $write("Instr=WRTBR ");

                        default:   $write("Instr=UNKNOWN (op3=%b) ", opcode3);
                    endcase
                end

                2'b11: begin
                    case (opcode3)
                        6'b001001: $write("Instr=LSB ");
                        6'b001010: $write("Instr=LDSH ");
                        6'b000000: $write("Instr=LD ");
                        6'b000001: $write("Instr=LDUB ");
                        6'b000010: $write("Instr=LDUH ");
                        6'b000011: $write("Instr=LDD ");
                        6'b000101: $write("Instr=STB ");
                        6'b000110: $write("Instr=STH ");
                        6'b000100: $write("Instr=ST ");
                        6'b000111: $write("Instr=STD ");
                        6'b001101: $write("Instr=LDSTUB ");
                        6'b001111: $write("Instr=SWAP ");
                        default:   $write("Instr=LOAD/STORE OTHER ");
                    endcase
                end

                default: begin
                    $write("Instr=UNKNOWN OP ");
                end
            endcase
        end
    end
/*
initial begin
        $monitor(
            "PC = %d\n\
            ALU_OUT     = %d\n\
            DI          = %d\n\
            Address   = %d\n\
            D_MUX_OUT   = %d\n\
            ALU_A   = %d\n\
            ALU_B   = %d\n\
            ALU_OP   = %d\n",
            DUT.PC_fetch,
            DUT.ALU_Out_EX2,
            DUT.DI,
            DUT.alu_result_in,
            DUT.MEM.data_mux_out,
            DUT.A_EX2,
            DUT.SOH_out,
            DUT.ALU_OP

        );
    end
    */
    // =============================================================
    // Leer palabra en DM[56] en t ≈ 76
    // =============================================================
    reg [31:0] word56;

/*
    initial begin
        #76;
        word56 = {
            DUT.MEM.data_memory_inst.Memory[56],
            DUT.MEM.data_memory_inst.Memory[57],
            DUT.MEM.data_memory_inst.Memory[58],
            DUT.MEM.data_memory_inst.Memory[59]
        };

        $display("t=%0t | DM[56] = %b", $time, word56);
    end
*/
    // =============================================================
    // Terminar simulación en t=80
    // =============================================================
    initial begin
        #80;
        $finish;
    end

endmodule
