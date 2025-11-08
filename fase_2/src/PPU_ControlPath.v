/////////////////////////////////////////////////////////////////////////////////////////Control path
// TOP: PPU_ControlPath
// - Conecta PC, nPC, Instruction Memory, IF/ID, Control Unit,
//   MUX de control y pipeline de señales EX/MEM/WB.

module PPU_ControlPath (
    input        clk,
    input        reset,
    input        S,               // selección del MUX de control

    // Salidas para debugging / testbench
    output [31:0] PC,
    output [31:0] nPC,
    output [31:0] instr_IF,
    output [31:0] instr_ID,
    output [3:0]  EX_ctrl,
    output [1:0]  MEM_ctrl,
    output        WB_ctrl
);

    // ---------------- PC y nPC ----------------
    wire [31:0] pc_actual, npc_actual;
    wire [31:0] pc_next, npc_next, npc_plus_4;

    assign PC  = pc_actual;
    assign nPC = npc_actual;

    // nPC_next = nPC_actual + 4; PC_next = nPC_actual
    assign npc_plus_4 = npc_actual + 32'd4;
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
    wire [3:0] ALU_OP;
    wire [1:0] RAM_Size;
    wire       RAM_RW, RAM_Enable, L, RF_LE;

    control_unit CU (
        .I         (instr_ID),
        .ALU_OP    (ALU_OP),
        .RAM_Size  (RAM_Size),
        .RAM_RW    (RAM_RW),
        .RAM_Enable(RAM_Enable),
        .L         (L),
        .RF_LE     (RF_LE)
    );

    // Para esta fase, mapeamos:
    //  - EX_ctrl_id  = ALU_OP (4 bits)
    //  - MEM_ctrl_id = RAM_Size (2 bits)
    //  - WB_ctrl_id  = RF_LE (1 bit)
    wire [3:0] ex_ctrl_id  = ALU_OP;
    wire [1:0] mem_ctrl_id = RAM_Size;
    wire       wb_ctrl_id  = RF_LE;

    // ---------------- Mux de control de la CU ----------------
    wire [3:0] ex_ctrl_mux;
    wire [1:0] mem_ctrl_mux;
    wire       wb_ctrl_mux;

    CU_Mux_Control CU_MUX (
        .S           (S),
        .ex_ctrl_in  (ex_ctrl_id),
        .mem_ctrl_in (mem_ctrl_id),
        .wb_ctrl_in  (wb_ctrl_id),
        .ex_ctrl_out (ex_ctrl_mux),
        .mem_ctrl_out(mem_ctrl_mux),
        .wb_ctrl_out (wb_ctrl_mux)
    );

    // ---------------- Registros de pipeline de control ----------------
    // ID/EX
    ID_EX_reg ID_EX (
        .clk        (clk),
        .reset      (reset),
        .ex_ctrl_in (ex_ctrl_mux),
        .ex_ctrl_out(EX_ctrl)
    );

    // EX/MEM
    EX_MEM_reg EX_MEM (
        .clk         (clk),
        .reset       (reset),
        .mem_ctrl_in (mem_ctrl_mux),
        .mem_ctrl_out(MEM_ctrl)
    );

    // MEM/WB
    MEM_WB_reg MEM_WB (
        .clk        (clk),
        .reset      (reset),
        .wb_ctrl_in (wb_ctrl_mux),
        .wb_ctrl_out(WB_ctrl)
    );

endmodule