`timescale 1ns / 1ps

module DHDU (
    // Tipo de instrucción en EX
    input        EX_L,        // instrucción en EX es LOAD
    input        SR,          // instrucción actual NO es NOP (1 = válida)

    // Registros fuente de ID
    input  [4:0] RA,
    input  [4:0] RB,
    input  [4:0] RD,
    // Destinos
    input  [4:0] EX_RD,
    input  [4:0] MEM_RD,
    input  [4:0] WB_RD,

    //Señales para el register file load enable de cada una de las etapas
    input  wire       EX_RF_LE,
    input  wire       MEM_RF_LE,
    input  wire       WB_RF_LE,

    // Outputs
    output reg  [1:0] A_S,
    output reg  [1:0] B_S,
    output reg  [1:0] D_S,
    output reg        NOP,
    output reg        LE
);

    wire SRA = ID_SR[0];
    wire SRB = ID_SR[1];
    wire SRC = ID_SR[2];

    always @* begin
        // defaults: no stall, no bubble, no forwarding
        LE  = 1'b1;
        NOP = 1'b0;
        A_S = 2'b00;
        B_S = 2'b00;
        C_S = 2'b00;

        // -----------------------------
        // 1) Load–use data-forwarding hazard (stall + bubble)
        // -----------------------------
        if (EX_L &&
            ( (SRA && (ID_RA == EX_RD)) 
              (SRB && (ID_RB == EX_RD)) 
              (SRC && (ID_RC == EX_RD)) ) ) begin

            LE  = 1'b0;  // hold PC and IF/ID
            NOP = 1'b1;  // send NOP to EX
        end
        else begin
            // -----------------------------
            // 2) Normal RAW hazards with forwarding
            // Priority: EX -> MEM -> WB
            // -----------------------------

            // First source (RA)
            if (SRA) begin
                if (EX_RF_LE  && (ID_RA == EX_RD))
                    A_S = 2'b01;    // forward from EX
                else if (MEM_RF_LE && (ID_RA == MEM_RD))
                    A_S = 2'b10;    // forward from MEM
                else if (WB_RF_LE  && (ID_RA == WB_RD))
                    A_S = 2'b11;    // forward from WB
                // else 00: from RF
            end

            // Second source (RB)
            if (SRB) begin
                if (EX_RF_LE  && (ID_RB == EX_RD))
                    B_S = 2'b01;
                else if (MEM_RF_LE && (ID_RB == MEM_RD))
                    B_S = 2'b10;
                else if (WB_RF_LE  && (ID_RB == WB_RD))
                    B_S = 2'b11;
            end

            // Third source (RC – SPARC store data/source3)
            if (SRC) begin
                if (EX_RF_LE  && (ID_RC == EX_RD))
                    C_S = 2'b01;
                else if (MEM_RF_LE && (ID_RC == MEM_RD))
                    C_S = 2'b10;
                else if (WB_RF_LE  && (ID_RC == WB_RD))
                    C_S = 2'b11;
            end
        end
    end

endmodule