// =======================================
// Mux de control para la Unidad de Control
// - Si S = 0: pasan las señales originales de la CU
// - Si S = 1: se inyecta un NOP (todo ceros)
// =======================================

module CU_Mux_Control (
    input        S,             // 0 = normal, 1 = NOP
    // Entradas desde la Control Unit (en etapa ID)
    input  [3:0] ex_ctrl_in,
    input  [1:0] mem_ctrl_in,
    input        wb_ctrl_in,
    // Salidas hacia los registros de pipeline (ID/EX, EX/MEM, MEM/WB)
    output [3:0] ex_ctrl_out,
    output [1:0] mem_ctrl_out,
    output       wb_ctrl_out
);
    // Mux puro combinacional
    assign ex_ctrl_out  = (S) ? 4'b0000 : ex_ctrl_in;
    assign mem_ctrl_out = (S) ? 2'b00   : mem_ctrl_in;
    assign wb_ctrl_out  = (S) ? 1'b0    : wb_ctrl_in;
endmodule

// Instancia del Mux de Control
CU_Mux_Control CU_MUX (
    .S           (S),            // tu señal de control del mux
    .ex_ctrl_in  (ex_ctrl_id),
    .mem_ctrl_in (mem_ctrl_id),
    .wb_ctrl_in  (wb_ctrl_id),
    .ex_ctrl_out (ex_ctrl_mux),
    .mem_ctrl_out(mem_ctrl_mux),
    .wb_ctrl_out (wb_ctrl_mux)
);