`timescale 1ns / 1ps

module fetch_path #(
    parameter ADDR_WIDTH = 9,
    parameter INST_WIDTH = 32,
    parameter [ADDR_WIDTH-1:0] RESET_PC  = {ADDR_WIDTH{1'b0}},
    parameter [ADDR_WIDTH-1:0] RESET_nPC = 9'd4
)(
    input  wire clk,
    input  wire reset,

    // Enables para stalls
    input  wire LE,

    // Control
    input  wire call,
    input  wire J,
    input  wire jmpl,

    // Entradas desde otras etapas
    input  wire [ADDR_WIDTH-1:0] TA,       // Target Address (branch/call)
    input  wire [ADDR_WIDTH-1:0] ALU_out,  // Resultado de ALU para JMPL

    // Salidas hacia IF/ID
    output wire [INST_WIDTH-1:0] instr_F,
    output wire [ADDR_WIDTH-1:0] B_PC,

    // Debug
    output wire [ADDR_WIDTH-1:0] PC_out,
    output wire [ADDR_WIDTH-1:0] nPC_out
);

    // Registros internos solo como instancias
    wire [ADDR_WIDTH-1:0] PC_reg_out;
    wire [ADDR_WIDTH-1:0] nPC_reg_out;

    // Sumas +4
    wire [ADDR_WIDTH-1:0] TA_plus4;
    wire [ADDR_WIDTH-1:0] nPC_plus4;
    wire [ADDR_WIDTH-1:0] ALUout_plus4;

    // Señales intermedias
    wire branch_or_call;
    wire [ADDR_WIDTH-1:0] mux_TA_nPC_plus4_out;
    wire [ADDR_WIDTH-1:0] mux_TA_nPC_out;
    wire [ADDR_WIDTH-1:0] mux_nPC_next_src;
    wire [ADDR_WIDTH-1:0] mux_PC_next_src;

    // ======================
    // Instancia de registros
    // ======================
    NPC_reg u_npc_reg (
        .clk(clk),
        .reset(reset),
        .LE(LE),
        .I(mux_nPC_next_src),
        .O(nPC_reg_out)
    );

    PC_reg u_pc_reg (
        .clk(clk),
        .reset(reset),
        .LE(LE),
        .I(mux_PC_next_src),
        .O(PC_reg_out)
    );

    // Exponer salidas
    assign PC_out  = PC_reg_out;
    assign nPC_out = nPC_reg_out;
    assign B_PC    = PC_reg_out;

    // ======================
    // Operaciones +4 (usa tus add4 existentes)
    // ======================
    // TA + 4
    add4 #(.WIDTH(ADDR_WIDTH)) u_add_TA (
        .A(TA),
        .R(TA_plus4)
    );

    // nPC + 4
    add4 #(.WIDTH(ADDR_WIDTH)) u_add_nPC (
        .A(nPC_reg_out),
        .R(nPC_plus4)
    );

    // ALU_out + 4 (para jmps que usan ALU_out)
    add4 #(.WIDTH(ADDR_WIDTH)) u_add_ALUout (
        .A(ALU_out),
        .R(ALUout_plus4)
    );

    // OR gate: call OR J
    or2 u_or_branch_jmpl (
        .a(call),
        .b(J),
        .y(branch_or_call)
    );

    // Primer par de muxes (controlados por OR(call, J))
    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_TA_nPC_plus4 (
        .d0(nPC_plus4),
        .d1(TA_plus4),
        .sel(branch_or_call),
        .y(mux_TA_nPC_plus4_out)
    );

    TwoToOneMux #(.WIDTH(ADDR_WIDTH)) u_mux_TA_nPC (
        .d0(nPC_reg_out),
        .d1(TA),
        .sel(branch_or_call),
        .y(mux_TA_nPC_out)
    );

    // Segundo par de muxes (controlados por jmpl)
    mux2 #(.WIDTH(ADDR_WIDTH)) u_mux_nPC_next (
        .d0(mux_TA_nPC_plus4_out),
        .d1(ALUout_plus4),
        .sel(jmpl),
        .y(mux_nPC_next_src)
    );

    mux2 #(.WIDTH(ADDR_WIDTH)) u_mux_PC_next (
        .d0(mux_TA_nPC_out),
        .d1(ALU_out),
        .sel(jmpl),
        .y(mux_PC_next_src)
    );

    // ======================
    // Instruction Memory
    // ======================
    Instruction_Memory u_imem (
        .A(PC_reg_out),
        .I(instr_F)
    );

endmodule