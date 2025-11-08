////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////MUX
// =======================================
// Mux de control para la Unidad de Control
// - Si S = 0: pasan las señales originales de la CU
// - Si S = 1: se inyecta un NOP (todo ceros)
// =======================================

module CU_Mux_Control (
    // Entradas desde el Control Unit (en etapa ID)
    input S,
    input [31:0] id_ctrl_in,
    // Salidas hacia los registros de pipeline
    output [31:0] id_ctrl_out
);
    // logica del mux
    assign id_ctrl_out = (S) ? 32'b0 : id_ctrl_in;
endmodule