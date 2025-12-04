`timescale 1ns/1ps
// =======================================
// ID/EX: registro de señales de control, instrucción y datos para EX
// =======================================
module ID_EX_reg (
    input        clk,
    input        reset,

    // Control desde ID hacia EX
    input  [31:0] id_ctrl_in,
    output reg [31:0] ex_ctrl_out,

    // RD
    input [4:0] rd_ID,
    output reg [4:0] rd_EX,

    // Instrucción completa en ID (sale en EX)
    input  [31:0] instr_ID,
    output reg [31:0] instr_ID_EX,

    // Datos desde los muxes de data forwarding en ID
    input  [31:0] A_ID,   // operando A en ID
    input  [31:0] B_ID,   // operando B en ID
    input  [31:0] D_ID,   // tercer operando (store data, etc.) en ID

    // Datos registrados hacia la etapa EX
    output reg [31:0] A_EX,
    output reg [31:0] B_EX,
    output reg [31:0] D_EX
);

    always @(posedge clk) begin
        if (reset) begin
            // En reset, inyectar NOP y limpiar datos
            ex_ctrl_out <= 32'b0;
            instr_ID_EX    <= 32'b0;
            A_EX        <= 32'b0;
            B_EX        <= 32'b0;
            D_EX        <= 32'b0;
            rd_EX       <= 5'b0;
        end else begin
            ex_ctrl_out <= id_ctrl_in;
            instr_ID_EX    <= instr_ID;
            A_EX        <= A_ID;
            B_EX        <= B_ID;
            D_EX        <= D_ID;
            rd_EX       <= rd_ID;
        end
    end

endmodule