`timescale 1ns / 1ps

module decoding_stage_path(
    input  wire                     clk,
    input  wire                     reset,
    input  wire [8:0]               B_PC_ID,         // desde IF/ID
    input  wire [31:0]              instr_ID,       // desde IF/ID
    

    // Forwarding / valores de etapas posteriores (necesarios para los muxes)
    input  wire [31:0]              ALU_Out_EX,     // forwarding desde EX stage
    input  wire [31:0]              data_mem_mux,   // forwarding desde MEM/WB
    input  wire [31:0]              PW_WB,          // writeback data from WB stage        // forwarding desde MEM/WB
    input  wire [4:0]               RW_WB,          // writeback destination reg from WB stage
    input  wire                     RF_LE_WB,       // register file write enable (WB stage)
    input  wire                     NOP,           // desde DHDU
    input  wire                     LE_DHDU,            // desde DHDU      // desde control signals de writeback stage
    // Señales para CCR (vienen normalmente del EX stage / control)
    input  wire [3:0]               ALU_CC,        // datos a cargar en CCR (desde EX stage)
    input  wire [31:0]              ex_ctrl_in,    // señales de control

    // DHDU
    input  wire [1:0]               A_S,
    input  wire [1:0]               B_S,
    input  wire [1:0]               D_S,
    // Salidas hacia la etapa EX (operandos y señales)
    output wire [31:0]              A_src,
    output wire [31:0]              B_src,
    output wire [31:0]              D_src,
    output wire [31:0]              instr_EX,
    output wire [8:0]    TA,
    output wire                     J,            // Va para la etapa de fetch
    output wire                     carry_out,    // Va para el alu en EX stage
    output wire [31:0]              id_ctrl_out,
    output wire                     reset_handler_signal,
    output wire [2:0]               ID_SR
);
    

    // ------------------------------------------------------------
    // Internal wires / señales auxiliares
    // ------------------------------------------------------------
    // TAG related
    wire [29:0] disp22_ext = { {8{instr_ID[21]}}, instr_ID[21:0] }; // sign-extend 22 -> 30

    // Register file ports / decoded register addresses
    wire [4:0] RA_rf;
    wire [4:0] RB_rf;
    wire [4:0] RD_rf;

    // RF read data
    wire [31:0] PA_rf;
    wire [31:0] PB_rf;
    wire [31:0] PD_rf;

    // Forwarding selects (PROVISIONAL — deben venir del control unit)
    wire [1:0] sel_A = A_S;
    wire [1:0] sel_B = B_S;
    wire [1:0] sel_D = D_S;

    // ------------------------------------------------------------
    // Decode register numbers
    // ------------------------------------------------------------
    assign RA_rf = instr_ID[18:14];   // rs1
    assign RB_rf = instr_ID[4:0];     // rs2
    assign RD_rf = instr_ID[29:25];   // rd

    // ------------------------------------------------------------
    // TAG unit (genera TA)
    // ------------------------------------------------------------

    TAG TAG0 (
        .B_PC   (B_PC_ID[8:0]), // maybe cambiar
        .Offset ({instr_ID[29:0]}),
        .CALL   (ex_ctrl_in[2]),          // asunción: bit 24 = CALL (ajustar si hace falta)
        .TA     (TA)
    );

    // ------------------------------------------------------------
    // Register File (3-port)
    // ------------------------------------------------------------
    threePortRegisterFile_32x32 REG_FILE (
        .PA (PA_rf),
        .PB (PB_rf),
        .PD (PD_rf),

        .RA (RA_rf),
        .RB (RB_rf),
        .RD (RD_rf),
        .RW (RW_WB),

        .PW (PW_WB),
        .LE (RF_LE_WB),
        .Clk(clk)
    );

    // ------------------------------------------------------------
    // Forwarding Muxes -> salida A_src, B_src, D_src
    // ------------------------------------------------------------
    FourToOneMux #(.WIDTH(32)) mux_A (
        .in0 (PA_rf),
        .in1 (ALU_Out_EX),
        .in2 (data_mem_mux),
        .in3 (PW_WB),
        .sel (sel_A),
        .out (A_src)
    );

    FourToOneMux #(.WIDTH(32)) mux_B (
        .in0 (PB_rf),
        .in1 (ALU_Out_EX),
        .in2 (data_mem_mux),
        .in3 (PW_WB),
        .sel (sel_B),
        .out (B_src)
    );

    FourToOneMux #(.WIDTH(32)) mux_D (
        .in0 (PD_rf),
        .in1 (ALU_Out_EX),
        .in2 (data_mem_mux),
        .in3 (PW_WB),
        .sel (sel_D),
        .out (D_src)
    );

    // ------------------------------------------------------------
    // CCR: registro de flags global (instancio aquí; opcionalmente puede residir fuera)
    // CCR interface (esperada): (CC_EN, ICC, clock, CC_OUT, carry_out)
    // ------------------------------------------------------------
    wire [3:0] CCR_out;
    wire [3:0] CCR_out_muxed;
    CCR u_CCR (
        .CC_EN(ex_ctrl_in[17]),
        .ICC(ALU_CC),
        .clock(clk),
        .rst(reset),
        .CC_OUT(CCR_out),
        .carry_out(carry_out)
    );

    TwoToOneMux #(.WIDTH(4)) ccr_mux (
        .in0 (CCR_out),
        .in1 (ALU_CC),
        .sel (ex_ctrl_in[17]),
        .out (CCR_out_muxed)
    );

    // ------------------------------------------------------------
    // CH: condition handler (combinacional) -> produce J (branch taken)
    // CH expects: BI, cond, ACC[3:0] -> J
    // Mapear BI y cond desde instr_ID (ajusta según tu encoding)
    // ------------------------------------------------------------
    wire BI   = id_ctrl_out[0];
    wire [3:0] cond = instr_ID[28:25];
    wire [31:0] control_signals;
    CH u_CH (
        .BI(BI),
        .cond(cond),
        .ACC(CCR_out_muxed),
        .J(J)
    );

    control_unit CU (
        .I(instr_ID),
        .control_signals(control_signals)
    );

    TwoToOneMux #(.WIDTH(32)) NOP_mux_CU (
        .in0 (control_signals),
        .in1 (32'd0),
        .sel (NOP),
        .out (id_ctrl_out)
    );

    reset_handler RESET_HANDLER (
        .jmpl_EX(ex_ctrl_in[1]),
        .call_ID(id_ctrl_out[2]),
        .J_ID(J),
        .BI_ID(BI),
        .I_29_ID(instr_ID[29]),
        .global_reset(reset),
        .reset_out(reset_handler_signal)
    );

    // ------------------------------------------------------------
    // Passthrough de B_PC e instrucción a EX
    // ------------------------------------------------------------
    assign instr_EX = instr_ID;
    assign ID_SR = control_signals[20:18];

endmodule