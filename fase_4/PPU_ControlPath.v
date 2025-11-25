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
    wire [8:0] pc_next, npc_next;

    assign PC  = pc_actual;
    assign nPC = npc_actual;
    assign pc_next  = npc_actual;
    assign npc_next = npc_actual;


    // Load enable (siempre 1 por ahora)
    wire LE_PC  = 1'b1;
    wire LE_nPC = 1'b1;

    // ---------------- Reg File ----------------
    wire [31:0] PA_rf, PB_rf, PD_rf;   // three read buses out of RF
    wire [4:0]  RA_rf, RB_rf, RD_rf;   // read addresses from IF/ID (rs1, rs2, rd/rsd)
    wire [4:0]  RW_rf;                 // write address from WB stage (destination reg)
    wire [31:0] PW_rf;                 // write data from WB mux (ALU/MEM/PC, etc.)
    wire        RF_LE;                 // register-file load enable (from CU in WB)

    // Instance of the 3-port register file
    threePortRegisterFile_32x32 REG_FILE (
        .PA (PA_rf),   // -> goes to ID/EX as operand A for ALU
        .PB (PB_rf),   // -> goes to ID/EX as operand B (before SOH)
        .PD (PD_rf),   // -> goes to ID/EX as store-data operand (for ST instructions)

        .RA (RA_rf),   // <- rs1 field from IF/ID register
        .RB (RB_rf),   // <- rs2 field from IF/ID register
        .RD (RD_rf),   // <- third source (e.g. rd for stores / specials) from IF/ID
        .RW (RW_rf),   // <- destination reg number from MEM/WB stage

        .PW (PW_rf),   // <- value to write back (WB mux output)
        .LE (RF_LE),   // <- RF load enable from control (propagated to WB)
        .Clk(clk)      // <- system clock
    );

    // ======= Operand sources (no forwarding yet – stub) =======
    // For now, since EX/MEM/WB datapath and hazard unit are not implemented,
    // just use the raw register file outputs as the operand sources.
    // Later, you can replace these with ForwardMux instances once
    // ALU_Out_EX, Result_MEM, Result_WB, sel_A/sel_B/sel_D, etc. exist.

    wire [31:0] A_src;
    wire [31:0] B_src;
    wire [31:0] D_src;

    assign A_src = PA_rf;
    assign B_src = PB_rf;
    assign D_src = PD_rf;

    /*
    // Example of how forwarding will look once the rest of the datapath exists:

    // Example MEM stage composite result (always 32 bits):
    // wire [8:0]  TA_mem;
    // wire [31:0] TA_mem_ext = {{23{TA_mem[8]}}, TA_mem};
    // wire [31:0] ALU_MEM_out;
    // wire [31:0] LoadData_MEM;
    // wire        is_branch_mem, is_load_mem;
    // wire [31:0] Result_MEM = is_branch_mem ? TA_mem_ext :
    //                          is_load_mem   ? LoadData_MEM :
    //                                          ALU_MEM_out;

    // Example WB stage composite result (always 32 bits):
    // wire [8:0]  TA_wb;
    // wire [31:0] TA_wb_ext = {{23{TA_wb[8]}}, TA_wb};
    // wire [31:0] ALU_WB_out, LoadData_WB;
    // wire        is_branch_wb, is_load_wb;
    // wire [31:0] Result_WB = is_branch_wb ? TA_wb_ext :
    //                         is_load_wb   ? LoadData_WB :
    //                                        ALU_WB_out;

    // wire [1:0] sel_A, sel_B, sel_D;

    // ForwardMux #(.WIDTH(32)) mux_A (
    //     .in0 (PA_rf),
    //     .in1 (ALU_Out_EX),
    //     .in2 (Result_MEM),
    //     .in3 (Result_WB),
    //     .sel (sel_A),
    //     .out (A_src)
    // );

    // ForwardMux #(.WIDTH(32)) mux_B (
    //     .in0 (PB_rf),
    //     .in1 (ALU_Out_EX),
    //     .in2 (Result_MEM),
    //     .in3 (Result_WB),
    //     .sel (sel_B),
    //     .out (B_src)
    // );

    // ForwardMux #(.WIDTH(32)) mux_D (
    //     .in0 (PD_rf),
    //     .in1 (ALU_Out_EX),
    //     .in2 (Result_MEM),
    //     .in3 (Result_WB),
    //     .sel (sel_D),
    //     .out (D_src)
    // );
    */

    // disp22 = instr_ID[21:0]
    // Sign extend a 30 bits:
    wire [29:0] disp22_ext = { {8{instr_ID[21]}}, instr_ID[21:0] };
    wire [29:0] disp30 = instr_ID[29:0];
    wire [29:0] TAG_Offset;
    wire [8:0] B_PC;
    wire [8:0] TA;   // en el diagrama aparece “/9” a la salida de TA
    wire CALL = id_ctrl_mux[2];

    TAG #(
        .PC_WIDTH(9),
        .OFFSET_WIDTH(30)
    ) TAG0 (
        .B_PC   (B_PC),
        .Offset (TAG_Offset),
        .TA     (TA)
    );

    // Mux para offset del TAG
    TAG_OffsetMux #(.WIDTH(30)) TAGMUX (
        .CALL      (CALL),        // viene de la control_unit
        .offset22  (disp22_ext),
        .offset30  (disp30),
        .OffsetOut (TAG_Offset)
    );

    
    // Instancia de PC
    PC_reg PC0 (
        .clk   (clk),
        .reset (reset),
        .LE    (LE_PC),
        .I     (pc_next),
        .O     (pc_actual)
    );

    // Instancia de nPC
    NPC_reg NPC0 (
        .clk   (clk),
        .reset (reset),
        .LE    (LE_nPC),
        .I     (npc_next),
        .O     (npc_actual)
    );

    // ---------------- Instruction Memory ----------------
    instruction_memory IMEM (
        .A(pc_actual[8:0]),   // dirección en bytes: PC[8:0]
        .I(instr_IF)
    );

    // ---------------- IF/ID: instrucción hacia la CU ----------------
    wire [8:0] B_PC_ID;

    IF_ID_reg IF_ID (
        .clk      (clk),
        .reset    (reset),
        .instr_in (instr_IF),
        .pc_in    (pc_actual),   // añade este puerto al módulo IF_ID_reg
        .instr_out(instr_ID),
        .pc_out   (B_PC_ID)
    );

    assign B_PC = B_PC_ID;

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