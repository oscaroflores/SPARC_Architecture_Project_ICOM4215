`timescale 1ns / 1ps

// =====================
//  FETCH PATH (IF stage)
// =====================
module fetch_path #(
    parameter ADDR_WIDTH = 9,
    parameter INST_WIDTH = 32,
    // Puedes ajustar estos valores de reset si el profesor quiere algo distinto
    parameter [ADDR_WIDTH-1:0] RESET_PC  = {ADDR_WIDTH{1'b0}},
    parameter [ADDR_WIDTH-1:0] RESET_nPC = 9'd4      // PC=0, nPC=4 (byte addresses)
)(
    input  wire clk,
    input  wire reset,

    // Enables para poder hacer stalls más adelante
    input  wire pc_LE,
    input  wire npc_LE,

    // Señales de control
    input  wire jmpl,   // control de instrucción JMPL
    input  wire J,      // condición de branch tomada (condition handler)

    // Entradas desde otras etapas
    // TA y ALU_out vendrán luego del TA generator y del EX stage
    input  wire [ADDR_WIDTH-1:0] TA,       // Target Address (branch/call)
    input  wire [ADDR_WIDTH-1:0] ALU_out,  // Resultado de ALU para JMPL

    // Salidas hacia el pipeline IF/ID
    output wire [INST_WIDTH-1:0] instr_F,  // instrucción leída (a IF/ID)
    output wire [ADDR_WIDTH-1:0] B_PC,     // PC para el TA generator en ID (B_PC)

    // (Opcional) para debug/monitoreo
    output wire [ADDR_WIDTH-1:0] PC_out,
    output wire [ADDR_WIDTH-1:0] nPC_out
);

    // ======================
    //  Registros PC y nPC
    // ======================
    reg [ADDR_WIDTH-1:0] PC_reg;
    reg [ADDR_WIDTH-1:0] nPC_reg;

    // ======================
    //  Wires internos
    // ======================

    // Resultados de los ALU +4
    wire [ADDR_WIDTH-1:0] TA_plus4;
    wire [ADDR_WIDTH-1:0] nPC_plus4;
    wire [ADDR_WIDTH-1:0] ALUout_plus4;

    // Salida del OR (jumpl OR J)
    wire branch_or_jmpl;

    // Salidas de los muxes
    wire [ADDR_WIDTH-1:0] mux_TA_nPC_plus4_out; // escoge entre nPC+4 y TA+4
    wire [ADDR_WIDTH-1:0] mux_TA_nPC_out;       // escoge entre nPC y TA
    wire [ADDR_WIDTH-1:0] mux_nPC_next_src;     // entrada final de nPC
    wire [ADDR_WIDTH-1:0] mux_PC_next_src;      // entrada final de PC

    // ======================
    //  Lógica combinacional
    // ======================

    // OR gate: jumpl OR J
    or2 u_or_branch_jmpl (
        .a(jmpl),
        .b(J),
        .y(branch_or_jmpl)
    );

    // ALU: TA + 4
    alu_add4 #(.WIDTH(ADDR_WIDTH)) u_add4_TA (
        .A(TA),
        .R(TA_plus4)
    );

    // ALU: nPC + 4
    alu_add4 #(.WIDTH(ADDR_WIDTH)) u_add4_nPC (
        .A(nPC_reg),
        .R(nPC_plus4)
    );

    // ALU: ALU_out + 4 (para JMPL)
    alu_add4 #(.WIDTH(ADDR_WIDTH)) u_add4_ALUout (
        .A(ALU_out),
        .R(ALUout_plus4)
    );

    // Primer par de muxes (controlados por OR(jmpl, J))
    // Mux 1: escoge entre nPC+4 (secuencial) y TA+4 (brinco)
    mux2 #(.WIDTH(ADDR_WIDTH)) u_mux_TA_nPC_plus4 (
        .d0(nPC_plus4),       // camino normal: nPC + 4
        .d1(TA_plus4),        // camino de salto: TA + 4
        .sel(branch_or_jmpl),
        .y(mux_TA_nPC_plus4_out)
    );

    // Mux 2: escoge entre nPC y TA para el PC
    mux2 #(.WIDTH(ADDR_WIDTH)) u_mux_TA_nPC (
        .d0(nPC_reg),         // camino normal: PC <- nPC
        .d1(TA),              // camino de salto: PC <- TA
        .sel(branch_or_jmpl),
        .y(mux_TA_nPC_out)
    );

    // Segundo par de muxes (controlados directamente por jumpl)

    // Mux 3: entrada final del registro nPC
    // Entradas: (TA+4 / nPC+4) vs (ALU_out + 4)
    mux2 #(.WIDTH(ADDR_WIDTH)) u_mux_nPC_next (
        .d0(mux_TA_nPC_plus4_out), // normal / branch
        .d1(ALUout_plus4),         // JMPL
        .sel(jmpl),
        .y(mux_nPC_next_src)
    );

    // Mux 4: entrada final del registro PC
    // Entradas: (TA / nPC) vs ALU_out directo
    mux2 #(.WIDTH(ADDR_WIDTH)) u_mux_PC_next (
        .d0(mux_TA_nPC_out),   // normal / branch
        .d1(ALU_out),          // JMPL
        .sel(jmpl),
        .y(mux_PC_next_src)
    );

    // ======================
    //  Registros PC y nPC
    // ======================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_reg  <= RESET_PC;
            nPC_reg <= RESET_nPC;
        end else begin
            if (pc_LE)
                PC_reg <= mux_PC_next_src;
            if (npc_LE)
                nPC_reg <= mux_nPC_next_src;
        end
    end

    // ======================
    //  Instruction Memory
    // ======================
    // OJO: usa el nombre real de tu módulo de memoria de instrucciones
    Instruction_Memory u_imem (
        .A(PC_reg),     // dirección = PC de 9 bits
        .I(instr_F)     // instrucción de 32 bits hacia IF/ID
    );

    // ======================
    //  Salidas hacia IF/ID
    // ======================
    assign B_PC    = PC_reg;   // PC que se mandará al registro IF/ID (para TA generator)
    assign PC_out  = PC_reg;   // opcionales, por si los quieres ver en testbench
    assign nPC_out = nPC_reg;

endmodule
