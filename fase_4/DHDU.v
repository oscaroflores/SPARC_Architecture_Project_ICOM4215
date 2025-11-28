`timescale 1ns/1ps

// Data Hazard Detection Unit (DHDU)
// - Compara los registros fuente de la instrucción en ID (RA, RB)
//   contra los registros destino de las instrucciones en EX, MEM y WB.
// - Genera banderas de forwarding: EX_RF_LE, MEM_RF_LE, WB_RF_LE
//   con prioridad EX > MEM > WB.
//
// Notas:
// - Ignoramos r0 (registro 0) como fuente para hazards.
// - Usamos NOP y LE para evitar activar forwarding cuando la
//   instrucción en ID no hace nada útil con el RF.
// - EX_L se puede usar para evitar forward desde EX si la instrucción
//   en EX es un load (el dato todavía no está listo en esa etapa).

module DHDU (
    // Control / tipo desde ID
    input        A_S,
    input        D_S,
    input        EX_L,       // instrucción en EX es load
    input        B_S,
    input        SR,
    input        NOP,        // instrucción actual es NOP
    input        LE,         // RF load enable (ID)

    // Registros de la instrucción en ID
    input  [4:0] RA,         // source A
    input  [4:0] RB,         // source B
    input  [4:0] RD,         // destination en ID (no usado aún, pero se deja por si acaso)

    // Registros destino en etapas posteriores
    input  [4:0] EX_RD,      // destino en EX (ya muxed para CALL)
    input  [4:0] MEM_RD,     // destino en MEM
    input  [4:0] WB_RD,      // destino en WB

    // Decisión de forwarding
    output reg   EX_RF_LE,   // usar resultado de EX
    output reg   MEM_RF_LE,  // usar resultado de MEM
    output reg   WB_RF_LE    // usar resultado de WB
);

    // Validez de las fuentes (ignora r0)
    wire srcA_valid = (RA != 5'd0);
    wire srcB_valid = (RB != 5'd0);

    // Comparaciones de hazards para RA o RB con cada etapa
    wire ex_hazard  =
        (srcA_valid && (RA == EX_RD))  ||
        (srcB_valid && (RB == EX_RD));

    wire mem_hazard =
        (srcA_valid && (RA == MEM_RD)) ||
        (srcB_valid && (RB == MEM_RD));

    wire wb_hazard  =
        (srcA_valid && (RA == WB_RD))  ||
        (srcB_valid && (RB == WB_RD));

    always @(*) begin
        // por defecto, sin forwarding
        EX_RF_LE  = 1'b0;
        MEM_RF_LE = 1'b0;
        WB_RF_LE  = 1'b0;

        // si es NOP o no va a escribir RF, no activamos nada
        if (NOP || !LE)
            disable_forwarding: begin end
        else begin
            // Prioridad: EX > MEM > WB
            // Para loads en EX (EX_L=1), normalmente no forwardeas desde EX,
            // sino desde MEM en el próximo ciclo; aquí EX_L nos deja apagar EX_RF_LE.
            if (ex_hazard && !EX_L) begin
                EX_RF_LE = 1'b1;
            end
            else if (mem_hazard) begin
                MEM_RF_LE = 1'b1;
            end
            else if (wb_hazard) begin
                WB_RF_LE = 1'b1;
            end
        end
    end

endmodule