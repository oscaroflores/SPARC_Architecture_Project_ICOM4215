`timescale 1ns/1ps

module PPU_ControlPath (
    input        clk,
    input        reset,

    // Salidas para debugging / testbench
    output [8:0] PC,
    output [8:0] nPC,
    output [31:0] instr_IF,
    output [31:0] instr_ID,
    output [31:0] instr_EX,
    output [31:0] instr_MEM,
    output [31:0] instr_WB,
    output [31:0] EX_ctrl,
    output [31:0] MEM_ctrl,
    output [31:0] WB_ctrl,
    output [31:0] control_signals

);

    // ==============================================================================
    // ==============================================================================
    // Fetch Stage
    // ==============================================================================
    // ==============================================================================

    // ---------------- PC y nPC ----------------
    wire [8:0] pc_actual, npc_actual;
    wire [8:0] pc_next, npc_next;

    assign PC  = pc_actual;
    assign nPC = npc_actual;
    assign pc_next  = npc_actual;
    assign npc_next = npc_actual;

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

    instruction_memory IMEM (
        .A(pc_actual[8:0]),   // dirección en bytes: PC[8:0]
        .I(instr_IF)
    );


    // ==============================================================================
    // ==============================================================================
    wire [8:0] B_PC_ID;
    
    IF_ID_reg IF_ID (
        .clk      (clk),
        .reset    (reset),
        .instr_in (instr_IF),
        .pc_in    (pc_actual),   // añade este puerto al módulo IF_ID_reg
        .instr_out(instr_ID),
        .pc_out   (B_PC_ID)
    );
    // ==============================================================================
    // ==============================================================================
    
    // ==============================================================================
    // ==============================================================================
    // Decode Stage
    // ==============================================================================
    // ==============================================================================
    
    // ---------------- TAG ----------------
    // Sign extend a 30 bits:
    wire [29:0] disp22_ext = { {8{instr_ID[21]}}, instr_ID[21:0] };
    wire [29:0] disp30 = instr_ID[29:0];
    wire [29:0] TAG_Offset;
    wire [8:0] TA;   // en el diagrama aparece “/9” a la salida de TA
    wire CALL_ID = id_ctrl_mux[2];

    TAG #(
        .PC_WIDTH(9),
        .OFFSET_WIDTH(30)
    ) TAG0 (
        .B_PC   (B_PC_ID),
        .Offset (TAG_Offset),
        .TA     (TA)
    );

    // Mux para offset del TAG
    TAG_OffsetMux #(.WIDTH(30)) TAGMUX (
        .CALL      (CALL_ID),        // viene de la control_unit
        .offset22  (disp22_ext),
        .offset30  (disp30),
        .OffsetOut (TAG_Offset)
    );

    // Load enable (siempre 1 por ahora)
    wire LE_PC  = 1'b1;
    wire LE_nPC = 1'b1;

    // ---------------- Reg File ----------------
    wire [31:0] PA_rf, PB_rf, PD_rf;   // three read buses out of RF

    // =============== Decode register numbers from instr_ID (Format 3) ===============
    wire [4:0] RA_rf;
    wire [4:0] RB_rf;
    wire [4:0] RD_rf;
    wire [4:0] RW_rf;
    assign RA_rf = instr_ID[18:14];   // rs1
    assign RB_rf = instr_ID[4:0];     // rs2 (when i = 0, load/store/arithmetic reg form)
    assign RD_rf = instr_ID[29:25];   // rd (used as 3rd source for stores, etc.)    wire [4:0]  RW_rf;                 // write address from WB stage (destination reg)

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


    // Operandos después de los muxes de forwarding (entrada a ID/EX)
    wire [31:0] A_src;
    wire [31:0] B_src;
    wire [31:0] D_src;
    
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

    wire [1:0] sel_A, sel_B, sel_D;
    assign sel_A = 2'b00;
    assign sel_B = 2'b00;
    assign sel_D = 2'b00;

    FourToOneMux #(.WIDTH(32)) mux_A (
        .in0 (PA_rf),
        .in1 (ALU_Out_EX),
        .in2 (WB_Data),
        .in3 (PW_WB),
        .sel (sel_A), // change
        .out (A_src)
    );

    FourToOneMux #(.WIDTH(32)) mux_B (
        .in0 (PB_rf),
        .in1 (ALU_Out_EX),
        .in2 (WB_Data),
        .in3 (PW_WB),
        .sel (sel_B), // change
        .out (B_src)
    );

    FourToOneMux #(.WIDTH(32)) mux_D (
        .in0 (PD_rf),
        .in1 (ALU_Out_EX),
        .in2 (WB_Data),
        .in3 (PW_WB),
        .sel (sel_D), // change
        .out (D_src)
    );
    
    // ==============================================================================
    // ==============================================================================
    wire [31:0] A_EX, B_EX, D_EX;

    ID_EX_reg ID_EX (
        .clk        (clk),
        .reset      (reset),

        // control
        .id_ctrl_in (id_ctrl_mux),
        .ex_ctrl_out(EX_ctrl),

        // instrucción
        .instr_ID   (instr_ID),   // o instr_ID, si así llamas al bus en ID
        .instr_EX   (instr_EX),

        // datos
        .A_ID       (A_src),
        .B_ID       (B_src),
        .D_ID       (D_src),
        .A_EX       (A_EX),
        .B_EX       (B_EX),
        .D_EX       (D_EX)
    );
    // ==============================================================================
    // ==============================================================================
    

    // Ahora puedes “cherry pick” los campos desde instr_EX
    wire [4:0] RD_EX = instr_EX[29:25]; // rd
    wire [4:0] RS1_EX = instr_EX[18:14];
    wire [4:0] RS2_EX = instr_EX[4:0];
    wire       i_EX   = instr_EX[13];

    // ---------------- SOH ----------------
    wire [31:0] SOH_out;

    SOH soh0 (
        .R   (B_EX),          // register operand
        .Imm (instr_EX[21:0]), // immediate field (disp/simm/etc. per spec)
        .Is  (EX_ctrl[12:9]),  // SOH_OP from EX-stage control
        .N   (SOH_out)         // output second operand when using immediates
    );

    // ---------------- ALU ----------------
    wire [31:0] ALU_Out_EX;
    wire Ci_EX = 1'b0; // For now, no carry-in from PSR; tie to 0. Later you can replace this with the C flag from PSR/WB.

    ALU alu0 (
        .Out (ALU_Out_EX),
        .Z   (Z_EX),
        .N   (N_EX),
        .C   (C_EX),
        .V   (V_EX),
        .A   (A_src),          // from RF or forwarding mux (stub now)
        .B   (SOH_out),          // from B_src or SOH_out
        .Ci  (Ci_EX),
        .OP  (EX_ctrl[16:13])  // ALU_OP
    );

    // ---------------- MUX at ALU's output ----------------
    wire [31:0] mux_out;
    wire [8:0] B_PC_EX;   // PC value pipelined from ID to EX
    wire [31:0] B_PC_EX_ext = {23'b0, B_PC_EX};

    TwoToOneMux #(.WIDTH(32)) ALU_out_mux (
        .in0 (ALU_Out_EX),
        .in1 (B_PC_EX_ext),
        .sel (EX_ctrl[2]),
        .out (mux_out)
    );

    // ---------------- MUX that sends R15 address when CALL=1 ----------------
    wire [4:0] RD_EX_muxed;  // this will be the output of the mux

    TwoToOneMux #(.WIDTH(5)) CALL_RD_MUX (
        .in0 (RD_EX),
        .in1 (5'd15),
        .sel (EX_ctrl[2]),   // CALL bit
        .out (RD_EX_muxed)
    );

    // ==============================================================================
    // ==============================================================================
    // wires para la etapa MEM
    wire [31:0] D_MEM_out;
    wire [4:0]  RD_MEM_out;
    // Ahora ALU_MEM_out vendrá del EX/MEM_reg
    wire [31:0] ALU_MEM_out;

    // EX/MEM
    EX_MEM_reg EX_MEM (
        .clk            (clk),
        .reset          (reset),

        // control
        .ex_ctrl_in     (EX_ctrl),
        .mem_ctrl_out   (MEM_ctrl),

        // datos
        .ex_third_op_in (D_EX),        // dato del 3er operando (para stores)
        .ex_alu_out_in  (mux_out),     // resultado del ALU en EX
        .ex_rd_in       (RD_EX_muxed),       // número de registro destino

        // salidas hacia MEM
        .mem_third_op_out (D_MEM_out),
        .mem_alu_out      (ALU_MEM_out),
        .mem_rd_out       (RD_MEM_out)
    );
    // ==============================================================================
    // ==============================================================================

    data_memory data_mem0 (
        .DI   (D_MEM_out),          // o directamente D_MEM_out
        .A    (ALU_MEM_out[8:0]),   // aquí deberías usar solo los 9 bits bajos
        .Size (MEM_ctrl[8:7]),
        .RW   (MEM_ctrl[6]),
        .E    (MEM_ctrl[5]),
        .DO   (D_MEM_out)
    );

    // Resultado seleccionado en MEM (ALU vs Data Memory)
    wire [31:0] WB_Data;

    TwoToOneMux #(.WIDTH(32)) MEM_stage_mux (
        .in0 (ALU_MEM_out),
        .in1 (D_MEM_out),   // <- this is the real 32-bit memory output
        .sel (MEM_ctrl[4]),
        .out (WB_Data)
    );

    // ==============================================================================
    // ==============================================================================
    // Write-back stage wires
    wire [31:0] PW_WB;    // data to write to RF
    wire [4:0]  RD_WB;    // destination register in WB

    MEM_WB_reg MEM_WB (
        .clk         (clk),
        .reset       (reset),

        .mem_ctrl_in (MEM_ctrl),
        .wb_ctrl_out (WB_ctrl),

        .pw_data_in  (WB_Data),      // from MEM_stage_mux
        .pw_data_out (PW_WB),

        .rd_in       (RD_MEM_out),   // this should come from RD_EX_muxed pipelined through EX/MEM
        .rd_out      (RD_WB)
    );
    // ==============================================================================
    // ==============================================================================


    // ==============================================================================
    // ==============================================================================
    // DHDU MODULE:
    // ==============================================================================
    // ==============================================================================

    DHDU dhdu0 (
        .A_S      (A_S_ID),
        .D_S      (D_S_ID),
        .EX_L     (EX_L_ID),
        .B_S      (B_S_ID),
        .SR       (SR_ID),
        .NOP      (NOP_ID),
        .LE       (RF_LE_ID),

        // fuentes en ID
        .RA       (RA_rf),       // rs1 de instr_ID
        .RB       (RB_rf),       // rs2 de instr_ID (cuando I=0)
        .RD       (RD_rf),       // rd de instr_ID (3er operando p.ej. en stores)

        // destinos reales en cada etapa
        .EX_RD    (RD_EX_muxed), // rd en EX (incluye CALL -> r15)
        .MEM_RD   (RD_MEM_out),  // rd en MEM (desde EX/MEM_reg)
        .WB_RD    (RD_WB),       // rd en WB (desde MEM/WB_reg)

        .EX_RF_LE (EX_RF_LE),
        .MEM_RF_LE(MEM_RF_LE),
        .WB_RF_LE (WB_RF_LE)
    );

endmodule