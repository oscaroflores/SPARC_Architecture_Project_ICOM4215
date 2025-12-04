`timescale 1ns/1ps

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

    // RF write enables en pipeline
    input        EX_RF_LE,
    input        MEM_RF_LE,
    input        WB_RF_LE,

    // Outputs
    output reg  [1:0] A_S,
    output reg  [1:0] B_S,
    output reg  [1:0] D_S,
    output reg        NOP,
    output reg        LE
);

always @(*) begin
    // Default values
    A_S = 2'b00;
    B_S = 2'b00;
    D_S = 1'b0;
    NOP = 1'b0;
    LE  = SR;     // write enable pasa desde ID, salvo cuando hay stall

    // ----------------------------------------------------------
    // Load-use hazard (stall)
    // EX es load y la instrucción de ID depende
    // ----------------------------------------------------------
    if (EX_L &&
        ((RA != 5'd0 && RA == EX_RD) ||
         (RB != 5'd0 && RB == EX_RD))) begin
        
        NOP = 1'b1;   // convertir la instrucción en ID a NOP
        LE  = 1'b0;   // deshabilitar write-back de esta instrucción
    end

    // ----------------------------------------------------------
    // Forwarding A
    // ----------------------------------------------------------
    if (RA != 5'd0) begin
        if (EX_RF_LE && RA == EX_RD)
            A_S = 2'b01;   // forward from EX
        else if (MEM_RF_LE && RA == MEM_RD)
            A_S = 2'b10;   // forward from MEM
        else if (WB_RF_LE && RA == WB_RD)
            A_S = 2'b11;   // forward from WB
        else
            A_S = 2'b00;   // use RF
    end

    // ----------------------------------------------------------
    // Forwarding B
    // ----------------------------------------------------------
    if (RB != 5'd0) begin
        if (EX_RF_LE && RB == EX_RD)
            B_S = 2'b01;
        else if (MEM_RF_LE && RB == MEM_RD)
            B_S = 2'b10;
        else if (WB_RF_LE && RB == WB_RD)
            B_S = 2'b11;
        else
            B_S = 2'b00;
    end
end

endmodule