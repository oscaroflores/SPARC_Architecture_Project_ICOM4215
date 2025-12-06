module execution_stage_path (
    // Entradas
    input  wire [31:0] A_EX,          // operando A desde RF
    input  wire [31:0] B_EX,          // operando B desde RF
    input  wire [31:0] instr_ID_EX,      // instrucción en EX
    input  wire [31:0] ex_ctrl_in,    // pasa directo a MEM
    input  wire [31:0] D_EX,          // pasa directo a MEM
    input  wire        C_flag,        // Carry del PSR (cuando aplique)
    input  wire [8:0]  B_PC_ID,      // desde IF/ID

    // Salidas
    output wire [31:0] ALU_mux_out,
    output wire [4:0]  RD_EX_out,
    output wire [3:0]  CC_EX, 
    output wire [31:0] ex_ctrl_out,
    output wire [31:0] D_MEM_out,
    output wire        L_EX,
    output wire        RF_LE_EX
);

    // -----------------------------------------
    // Decode de la instrucción
    // -----------------------------------------
    wire [4:0] RD_EX  = instr_ID_EX[29:25];
    wire [4:0] RS1_EX = instr_ID_EX[18:14];
    wire [4:0] RS2_EX = instr_ID_EX[4:0];

    // -----------------------------------------
    // Señales de control del EX stage
    // -----------------------------------------
    wire [3:0] ALU_OP  = ex_ctrl_in[16:13];
    wire [3:0] SOH_OP  = ex_ctrl_in[12:9];
    wire       CALLbit = ex_ctrl_in[2];

    // -----------------------------------------
    // SOH UNIT
    // -----------------------------------------
    wire [31:0] SOH_out;

    SOH soh0 (
        .R   (B_EX),
        .Imm (instr_ID_EX[21:0]),
        .Is  (SOH_OP),
        .N   (SOH_out)
    );

    // -----------------------------------------
    // ALU
    // -----------------------------------------
    wire [31:0] ALU_Out_EX;
    wire Z_EX, N_EX, C_EX, V_EX;

    ALU alu0 (
        .Out (ALU_Out_EX),
        .Z   (Z_EX),
        .N   (N_EX),
        .C   (C_EX),
        .V   (V_EX),
        .A   (A_EX),
        .B   (SOH_out),
        .Ci  (C_flag),
        .OP  (ALU_OP)
    );

    assign CC_EX = {N_EX, Z_EX, V_EX, C_EX};

    // -----------------------------------------
    // MUX para CALL (rd = 15)
    // -----------------------------------------
    assign RD_EX_out = (CALLbit) ? 5'd15 : RD_EX;

    // -----------------------------------------
    // Sin PC en EX → pasar ALU directamente
    // -----------------------------------------
    assign ALU_mux_out = (CALLbit) ? B_PC_ID : ALU_Out_EX;

    // -----------------------------------------
    // Señales directas hacia MEM
    // -----------------------------------------
    assign ex_ctrl_out = ex_ctrl_in;
    assign D_MEM_out   = D_EX;
    assign L_EX        = ex_ctrl_in[4];
    assign RF_LE_EX    = ex_ctrl_in[3];

endmodule