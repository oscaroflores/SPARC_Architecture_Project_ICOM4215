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
        if (EX_L &&
           ( (SRA && (RA == EX_RD)) ||
             (SRB && (RB == EX_RD)) ||
             (SRC && (RD == EX_RD)) ) ) begin

            LE  = 1'b0;  
            NOP = 1'b1;  
        end 
        else begin

            // -----------------------------------
            // RAW hazards solved via forwarding
            // -----------------------------------

            // RA forwarding
            if (SRA) begin
                if (EX_RF_LE  && (RA == EX_RD))       A_S = 2'b01;
                else if (MEM_RF_LE && (RA == MEM_RD)) A_S = 2'b10;
                else if (WB_RF_LE  && (RA == WB_RD))  A_S = 2'b11;
            end

            // RB forwarding
            if (SRB) begin
                if (EX_RF_LE  && (RB == EX_RD))       B_S = 2'b01;
                else if (MEM_RF_LE && (RB == MEM_RD)) B_S = 2'b10;
                else if (WB_RF_LE  && (RB == WB_RD))  B_S = 2'b11;
            end

            // RD forwarding (store data)
            if (SRC) begin
                if (EX_RF_LE  && (RD == EX_RD))       D_S = 2'b01;
                else if (MEM_RF_LE && (RD == MEM_RD)) D_S = 2'b10;
                else if (WB_RF_LE  && (RD == WB_RD))  D_S = 2'b11;
            end
        end
    end

endmodule
