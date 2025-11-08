//////////////////////////////////////////////////////////////////////////////////////////////////////////////Pipeline Reg
//Registros Pipeline

// =======================================
// IF/ID: registro de instrucción
// - Rising edge-triggered
// - Reset sincrónico
// - Sin load enable (siempre carga)
// =======================================
module IF_ID_reg (
    input clk, 
    input reset, 
    input [31:0] instr_in, 
    output reg [31:0] instr_out
);
    always @(posedge clk) begin
        if (reset)
            instr_out <= 32'd0;    // en reset, NOP (instrucción = 0)
        else
            instr_out <= instr_in; // siempre carga en cada ciclo
    end
endmodule