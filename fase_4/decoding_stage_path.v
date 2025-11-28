`timescale 1ns / 1ps

module decoding_stage_path #(
    parameter ADDR_WIDTH = 9,
    parameter RESET_PC   = 9'd0,
    parameter RESET_nPC  = 9'd4
)(
    input  wire                     clk,
    input  wire                     reset,
    input  wire [31:0]              B_PC_ID,        // desde IF/ID
    input  wire [31:0]              instr_ID,       // desde IF/ID

    // Forwarding / valores de etapas posteriores (necesarios para los muxes)
    input  wire [31:0]              ALU_Out_EX,     // forwarding desde EX stage
    input  wire [31:0]              data_mem_mux,   // forwarding desde MEM/WB
    input  wire [31:0]              PW_WB,          // writeback data from WB stage
    input  wire [4:0]               RW_WB,          // writeback destination reg from WB stage
    input  wire                     RF_LE_WB,       // register file write enable (WB stage)

    // Señales para CCR (vienen normalmente del EX stage / control)
    input  wire                     CC_EN,          // habilita carga del CCR (desde EX / control)
    input  wire [3:0]               ICC_in,         // datos a cargar en CCR (desde EX stage)

    // Salidas hacia la etapa EX (operandos y señales)
    output wire [31:0]              A_src,
    output wire [31:0]              B_src,
    output wire [31:0]              D_src,
    output wire [31:0]              B_PC_EX,
    output wire [31:0]              I_SOH_EX,
    output wire [4:0]               RW_EX,
    output wire [ADDR_WIDTH-1:0]    TA,
    output wire [1:0]               SR,
    output wire                     J,
    output wire                     carry_out,
    output wire                     call
);

    // ------------------------------------------------------------
    // Internal wires / señales auxiliares
    // ------------------------------------------------------------
    // TAG related
    wire [29:0] disp22_ext = { {8{instr_ID[21]}}, instr_ID[21:0] }; // sign-extend 22 -> 30
    wire [29:0] disp30     = instr_ID[29:0];
    wire [29:0] TAG_Offset;

    // Register file ports / decoded register addresses
    wire [4:0] RA_rf;
    wire [4:0] RB_rf;
    wire [4:0] RD_rf;

    // RF read data
    wire [31:0] PA_rf;
    wire [31:0] PB_rf;
    wire [31:0] PD_rf;

    // Forwarding selects (PROVISIONAL — deben venir del control unit)
    wire [1:0] sel_A = 2'b00;
    wire [1:0] sel_B = 2'b00;
    wire [1:0] sel_D = 2'b00;

    // ------------------------------------------------------------
    // Decode register numbers (Format 3 assumed)
    // ------------------------------------------------------------
    assign RA_rf = instr_ID[18:14];   // rs1
    assign RB_rf = instr_ID[4:0];     // rs2
    assign RD_rf = instr_ID[29:25];   // rd
    assign RW_EX = RD_rf;             // pasar rd a EX

    // ------------------------------------------------------------
    // TAG unit (genera TA)
    // ------------------------------------------------------------
    TAG #(
        .PC_WIDTH(ADDR_WIDTH),
        .OFFSET_WIDTH(30)
    ) TAG0 (
        .B_PC   (B_PC_ID[ADDR_WIDTH-1:0]),
        .Offset (TAG_Offset),
        .TA     (TA)
    );

    // Elección offset (22 sign-ext o 30) - provisional: CALL_ID=0 (debe venir del CU)
    TAG_OffsetMux #(.WIDTH(30)) TAGMUX (
        .CALL      (1'b0),
        .offset22  (disp22_ext),
        .offset30  (disp30),
        .OffsetOut (TAG_Offset)
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
    CCR u_CCR (
        .CC_EN(CC_EN),
        .ICC(ICC_in),
        .clock(clk),
        .CC_OUT(CCR_out),
        .carry_out(carry_out)
    );

    // ------------------------------------------------------------
    // CH: condition handler (combinacional) -> produce J (branch taken)
    // CH expects: BI, cond, ACC[3:0] -> J
    // Mapear BI y cond desde instr_ID (ajusta según tu encoding)
    // ------------------------------------------------------------
    wire BI   = instr_ID[30];         // asunción: bit 30 = BI (ajusta si hace falta)
    wire [3:0] cond = instr_ID[28:25]; // asunción típica

    CH u_CH (
        .BI(BI),
        .cond(cond),
        .ACC(CCR_out),
        .J(J)
    );

    // ------------------------------------------------------------
    // Otros outputs por defecto (call, SR). Deben venir del CU: (por ahora 0)
    // ------------------------------------------------------------
    assign call = 1'b0;
    assign SR   = 2'b00; // salida de 2 bits (si la quieres conectar al CU, cambia)

    // ------------------------------------------------------------
    // Passthrough de B_PC e instrucción a EX
    // ------------------------------------------------------------
    assign B_PC_EX  = B_PC_ID;
    assign I_SOH_EX = instr_ID;

endmodule