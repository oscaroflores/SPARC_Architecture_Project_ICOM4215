`timescale 1ns / 1ps

// =====================
//  FETCH PATH (IF stage)
// =====================
module fetch_stage_path (
    input  wire clk,
    input  wire reset,
    input  wire LE_DHDU, // VERIFICAR: señal de enable desde DHDU

    // Señales de control
    input  wire call,   // control de instrucción JMPL
    input  wire J,      // condición de branch tomada (condition handler)
    input  wire jmpl,   // control de instrucción JMPL
    // Entradas desde otras etapas
    // TA y ALU_out vendrán luego del TA generator y del EX stage
    input  wire [8:0] TA,       // Target Address (branch/call)
    input  wire [8:0] ALU_out,  // Resultado de ALU para JMPL

    // Salidas hacia el pipeline IF/ID
    output wire [31:0] instr_F,  // instrucción leída (a IF/ID)

    // (Opcional) para debug/monitoreo
    output wire [8:0] PC_out,
    output wire [8:0] nPC_out
);

    // ======================
    //  Registros PC y nPC
    // ======================
    reg [8:0] PC_reg;
    reg [8:0] nPC_reg;

    localparam ADDR_WIDTH = 9;
    // ======================
    //  Wires internos
    // ======================

    // Resultados de los ALU +4
    wire [8:0] TA_plus4;
    wire [8:0] nPC_plus4;
    wire [8:0] ALUout_plus4;

    // Salida del OR (call OR J)
    wire branch_or_call;

    // Salidas de los muxes
    wire [8:0] mux_TA_nPC_plus4_out; // escoge entre nPC+4 y TA+4
    wire [8:0] mux_TA_nPC_out;       // escoge entre nPC y TA
    wire [8:0] mux_nPC_next_src;     // entrada final de nPC
    wire [8:0] mux_PC_next_src;      // entrada final de PC

    // ======================
    //  Lógica combinacional
    // ======================

    // OR gate: call OR J
    or2 u_or_branch_call (
        .a(call),
        .b(J),
        .y(branch_or_call)
    );

    // ALU: TA + 4
    add4 #(.WIDTH(ADDR_WIDTH)) u_add4_TA (
        .A(TA),
        .R(TA_plus4)
    );

    // ALU: nPC + 4
    add4 #(.WIDTH(ADDR_WIDTH)) u_add4_nPC (
        .A(nPC_reg),
        .R(nPC_plus4)
    );

    // ALU: ALU_out + 4 (para JMPL)
    add4 #(.WIDTH(ADDR_WIDTH)) u_add4_ALUout (
        .A(ALU_out),
        .R(ALUout_plus4)
    );

    // Primer par de muxes (controlados por OR(CALL, J))
    // Mux 1: escoge entre nPC+4 (secuencial) y TA+4 (brinco)
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_TA_nPC_plus4 (
        .in0(nPC_plus4),       // camino normal: nPC + 4
        .in1(TA_plus4),        // camino de salto: TA + 4
        .sel(branch_or_call),
        .out(mux_TA_nPC_plus4_out)
    );

    // Mux 2: escoge entre nPC y TA para el PC
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_TA_nPC (
        .in0(nPC_reg),         // camino normal: PC <- nPC
        .in1(TA),              // camino de salto: PC <- TA
        .sel(branch_or_call),
        .out(mux_TA_nPC_out)
    );

    // Segundo par de muxes (controlados directamente por jumpl)

    // Mux 3: entrada final del registro nPC
    // Entradas: (TA+4 / nPC+4) vs (ALU_out + 4)
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_nPC_next (
        .in0(mux_TA_nPC_plus4_out), // normal / branch
        .in1(ALUout_plus4),
        .sel(jmpl),
        .out(mux_nPC_next_src)
    );

    // Mux 4: entrada final del registro PC
    // Entradas: (TA / nPC) vs ALU_out directo
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_PC_next (
        .in0(mux_TA_nPC_out),   // normal / branch
        .in1(ALU_out),          // JMPL
        .sel(jmpl),
        .out(mux_PC_next_src)
    );

    // ======================
    //  Registros PC y nPC
    // ======================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_reg  <= 9'd0;
            nPC_reg <= 9'd4;
        end else begin
            if (LE_DHDU)
                PC_reg <= mux_PC_next_src;
            if (LE_DHDU)
                nPC_reg <= mux_nPC_next_src;
        end
    end

    // ======================
    //  Instruction Memory
    // ======================
    instruction_memory u_imem (
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