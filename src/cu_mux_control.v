////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////MUX
// =======================================
// Mux de control para la Unidad de Control
// - Si S = 0: pasan las señales originales de la CU
// - Si S = 1: se inyecta un NOP (todo ceros)
// =======================================

module cu_mux_control (input S,
    // Entradas desde el Control Unit (en etapa ID)
    input [3:0] ex_ctrl_in,
    input [1:0] mem_ctrl_in,
    input wb_ctrl_in,
    // Salidas hacia los registros de pipeline 
    output [3:0] ex_ctrl_out,
    output [1:0] mem_ctrl_out,
    output wb_ctrl_out
);
    // logica del mux
    assign ex_ctrl_out  = (S) ? 4'b0000 : ex_ctrl_in;
    assign mem_ctrl_out = (S) ? 2'b00   : mem_ctrl_in;
    assign wb_ctrl_out  = (S) ? 1'b0    : wb_ctrl_in;
endmodule