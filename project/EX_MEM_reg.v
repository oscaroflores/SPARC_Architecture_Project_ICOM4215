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
endmodule