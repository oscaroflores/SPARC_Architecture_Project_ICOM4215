`timescale 1ns/1ps
// =======================================
// PPU_ControlPath: Path de control del PPU
// =======================================
module PPU_ControlPath (
    input        clk,
    input        reset,
    input        S,             // selección del MUX de control

    // Salidas para debugging / testbench
    output [8:0] PC,
    output [8:0] nPC,
    output [31:0] instr_IF,
    output [31:0] instr_ID,
    output [31:0] EX_ctrl,
    output [31:0] MEM_ctrl,
    output [31:0] WB_ctrl,
    output [31:0] control_signals

);

    // ---------------- PC y nPC ----------------
    wire [8:0] pc_actual, npc_actual;
    wire [8:0] pc_next, npc_next, npc_plus_4;

    assign PC  = pc_actual;
    assign nPC = npc_actual;

    // nPC_next = nPC_actual + 4; PC_next = nPC_actual
    assign npc_plus_4 = npc_actual + 32'd4;             // Implementar en modulos
    assign pc_next    = npc_actual;
    assign npc_next   = npc_plus_4;

    // Load enable (siempre 1 por ahora)
    wire LE_PC  = 1'b1;
    wire LE_nPC = 1'b1;

    // Instancia de PC
    PC_reg PC0 (
        .clk   (clk),
        .reset (reset),
        .LE    (LE_PC),
        .D     (pc_next),
        .Q     (pc_actual)
    );

    // Instancia de nPC
    NPC_reg NPC0 (
        .clk   (clk),
        .reset (reset),
        .LE    (LE_nPC),
        .D     (npc_next),
        .Q     (npc_actual)
    );

    // ---------------- Instruction Memory ----------------
    instruction_memory IMEM (
        .A(pc_actual[8:0]),   // dirección en bytes: PC[8:0]
        .I(instr_IF)
    );

    // ---------------- IF/ID: instrucción hacia la CU ----------------
    IF_ID_reg IF_ID (
        .clk      (clk),
        .reset    (reset),
        .instr_in (instr_IF),
        .instr_out(instr_ID)
    );

    // ---------------- Control Unit (en etapa ID) ----------------
    control_unit CU (
        .I         (instr_ID),
        .control_signals(control_signals)
    );

    // ---------------- Mux de control de la CU ----------------
    wire [31:0] id_ctrl_mux;

    CU_Mux_Control CU_MUX (
        .S           (S),
        .id_ctrl_in  (control_signals),
        .id_ctrl_out (id_ctrl_mux)
    );

    // ---------------- Registros de pipeline de control ----------------
    // ID/EX
    ID_EX_reg ID_EX (
        .clk        (clk),
        .reset      (reset),
        .id_ctrl_in (id_ctrl_mux),
        .ex_ctrl_out(EX_ctrl)
    );

    // EX/MEM
    EX_MEM_reg EX_MEM (
        .clk         (clk),
        .reset       (reset),
        .ex_ctrl_in (EX_ctrl),
        .mem_ctrl_out(MEM_ctrl)
    );

    // MEM/WB
    MEM_WB_reg MEM_WB (
        .clk        (clk),
        .reset      (reset),
        .mem_ctrl_in (MEM_ctrl),
        .wb_ctrl_out(WB_ctrl)
    );

endmodule