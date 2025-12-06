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