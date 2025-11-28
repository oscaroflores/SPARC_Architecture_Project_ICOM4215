module execution_stage_path (
    // Entradas
    input  wire [31:0] A_EX,          // operando A desde RF o forwarding mux
    input  wire [31:0] B_EX,          // operando B desde RF o forwarding mux
    input  wire [31:0] instr_EX,      // instrucción pipelined desde ID a EX
    input  wire [8:0]  EX_ctrl,       // señales de control para EX stage
    input wire        C_EX,         // Carry flag from PSR/WB stage
    input [31:0]      control_signals,
    input CALL,
    // Salidas
    output wire [31:0] ALU_Out_EX,    // resultado de la ALU en EX stage
    output wire [4:0]  RD_EX_out,      // destino del registro para WB stage
    output wire [3:0]  CC_EX,        // condition codes desde EX stage
    output wire [31:0] ALU_MEM_out    // resultado de la ALU en MEM stage
);

    // ==============================================================================
    // ==============================================================================
    // wires para la etapa EX
    wire [31:0] A_src = A_EX; // por ahora, sin forwarding muxes
    // B_src vendrá del SOH

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
