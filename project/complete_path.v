`timescale 1ns / 1ps

module sparc_top (
    input wire clk,
    input wire reset,

    // outputs visibles para el testbench
    output [8:0]  PC_fetch,
    output [8:0]  nPC_fetch,
    output [31:0] instr_F,

    output [31:0] instr_ID,
    output [8:0]  B_PC_ID,

    output [31:0] A_ID,
    output [31:0] B_ID,
    output [31:0] D_ID,
    output [31:0] A_EX,
    output [31:0] B_EX,
    output [31:0] D_EX,
    output [31:0] instr_ID_EX,
    output [31:0] id_ctrl_out,
    output [8:0]  TA,

    output [31:0] ex_ctrl_out,
    output [31:0] D_MEM_tmp,
    output [31:0] ALU_out_EX,
    output [4:0]  RD_EX_out,
    output [3:0]  CC_EX,

    output [31:0] mem_ctrl_out,
    output [31:0] data_mux_out,
    output [4:0]  rd_mem,

    output [31:0] PW_WB,
    output [4:0]  RW_WB,
    output        RF_LE_WB,

    output [31:0] wb_ctrl_out
);
    // ======================================================
    //  Parámetros generales
    // ======================================================
    localparam ADDR_WIDTH = 9;
    localparam INST_WIDTH = 32;

    // ======================================================
    //  Señales internas entre FETCH → IF/ID
    // ======================================================
    // instr_F, PC_fetch, nPC_fetch ya son puertos de salida (wire implícito)
    wire [8:0]  B_PC_F;

    // ======================================================
    //  Señales IF/ID → DECODING
    // ======================================================
    wire [31:0] instr_IF_ID;

    // ======================================================
    //  DECODING → ID/EX
    // ======================================================
    // A_EX, B_EX, D_EX, instr_EX, id_ctrl_out, TA ya son puertos
    wire        J;
    wire        carry_flag;

    // ======================================================
    //  ID/EX → EXECUTE
    // ======================================================
    wire [31:0] instr_ID_EX;

    // ======================================================
    //  EXECUTE → EX/MEM → MEMORY
    // ======================================================
    wire [31:0] alu_result_in;
    wire [31:0] mem_ctrl_in;
    wire [4:0]  rd_in;
    wire [31:0] DI;

    // ======================================================
    //  MEM/WB → WRITEBACK
    // ======================================================
    // PW_WB, RW_WB, RF_LE_WB y wb_ctrl_out ya son puertos
    assign RF_LE_WB = wb_ctrl_out[3];

    // ======================================================
    //  Señales para DHDU
    // ======================================================
    wire [1:0] A_S;
    wire [1:0] B_S;
    wire [1:0] D_S;
    wire       NOP;
    wire       LE_DHDU;

    // ======================================================
    //  ETAPA FETCH
    // ======================================================
    fetch_stage_path #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INST_WIDTH(INST_WIDTH)
    ) FETCH (
        .clk(clk),
        .reset(reset),
        .pc_LE(LE_DHDU),
        .npc_LE(LE_DHDU),
        .call(ex_ctrl_out[2]),
        .jmpl(ex_ctrl_out[1]),
        .LE_DHDU(LE_DHDU),
        .J(J),
        .TA(TA),
        .ALU_out(ALU_out_EX[8:0]),

        .instr_F(instr_F),
        .B_PC(B_PC_F),

        .PC_out(PC_fetch),
        .nPC_out(nPC_fetch)
    );

    // ======================================================
    //  REGISTRO IF/ID
    // ======================================================
    IF_ID_reg IF_ID0 (
        .clk(clk),
        .reset(reset),
        .instr_in(instr_F),
        .pc_in(B_PC_F),
        .LE(LE_DHDU),
        .instr_out(instr_IF_ID),
        .pc_out(B_PC_ID)
    );

    // ======================================================
    // ETAPA DECODING
    // ======================================================
    decoding_stage_path #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) ID (
        .clk(clk),
        .reset(reset),
        .B_PC_ID(B_PC_ID),
        .instr_ID(instr_IF_ID),

        // Forwarding inputs
        .ALU_Out_EX(ALU_out_EX),
        .data_mem_mux(data_mux_out),
        .PW_WB(PW_WB),
        .RW_WB(RW_WB),
        .RF_LE_WB(RF_LE_WB),

        // DHDU hazard control
        .NOP(NOP),
        .LE_DHDU(LE_DHDU),

        // ALU condition codes into the CCR
        .ALU_CC(CC_EX),

        // Control signals from EX
        .ex_ctrl_in(ex_ctrl_out),

        // Selector inputs from DHDU
        .A_S(A_S),
        .B_S(B_S),
        .D_S(D_S),

        // Outputs
        .A_ID(A_ID),
        .B_ID(B_ID),
        .D_ID(D_ID),
        .instr_ID_EX(instr_ID),
        .TA(TA),
        .J(J),
        .carry_out(carry_flag),
        .id_ctrl_out(id_ctrl_out)
    );

    // ======================================================
    // REGISTRO ID/EX
    // ======================================================
    ID_EX_reg ID_EX0 (
        .clk(clk),
        .reset(reset),
        .instr_ID(instr_ID),
        .A_ID(A_ID),
        .B_ID(B_ID),
        .D_ID(D_ID),
        .id_ctrl_in(id_ctrl_out),

        .instr_ID_EX(instr_ID_EX),
        .A_EX(A_EX),
        .B_EX(B_EX),
        .D_EX(D_EX),
        .ex_ctrl_out(ex_ctrl_out)
    );

    // ======================================================
    // ETAPA DE EJECUCIÓN (EX)
    // ======================================================
    execution_stage_path EX (
        .A_EX(A_EX),
        .B_EX(B_EX),
        .D_EX(D_EX),
        .instr_ID_EX(instr_ID_EX),
        .ex_ctrl_in(ex_ctrl_out),
        .C_flag(carry_flag),
        .B_PC_ID(B_PC_ID),

        .ALU_mux_out(ALU_out_EX),
        .RD_EX_out(RD_EX_out),
        .CC_EX(CC_EX),
        .ex_ctrl_out(ex_ctrl_out),
        .D_MEM_out(D_MEM_tmp)
    );

    // ======================================================
    // REGISTRO EX/MEM
    // ======================================================
    EX_MEM_reg EX_MEM0 (
        .clk(clk),
        .reset(reset),

        .ex_alu_out_in(ALU_out_EX),
        .ex_ctrl_in(ex_ctrl_out),
        .ex_rd_in(RD_EX_out),
        .ex_third_op_in(D_MEM_tmp),

        .mem_alu_out(alu_result_in),
        .mem_ctrl_out(mem_ctrl_in),
        .mem_rd_out(rd_in),
        .mem_third_op_out(DI)
    );

    // ======================================================
    // ETAPA DE MEMORIA
    // ======================================================
    memory_stage_path MEM (
        .alu_result_in(alu_result_in),
        .mem_ctrl_in(mem_ctrl_in),
        .rd_in(rd_in),
        .DI(DI),

        .data_mux_out(data_mux_out),
        .mem_ctrl_out(mem_ctrl_out),
        .rd_out(rd_mem)
    );

    // ======================================================
    // REGISTRO MEM/WB
    // ======================================================
    MEM_WB_reg MEM_WB0 (
        .clk(clk),
        .reset(reset),

        .pw_data_in(data_mux_out),
        .rd_in(rd_mem),
        .mem_ctrl_in(mem_ctrl_out),

        .pw_data_out(PW_WB),
        .rd_out(RW_WB),
        .wb_ctrl_out(wb_ctrl_out)
    );

    // ======================================================
    // DHDU: Data Hazard Detection Unit
    // ======================================================
    DHDU DHDU (
        .EX_L(ex_ctrl_out[4]),
        .SR(id_ctrl_out[20:18]),
        .RA(instr_ID[18:14]),
        .RB(instr_ID[4:0]),
        .RD(instr_ID[29:25]),
        .EX_RD(RD_EX_out),
        .MEM_RD(rd_mem),
        .WB_RD(RW_WB),
        .EX_RF_LE(ex_ctrl_out[3]),
        .MEM_RF_LE(mem_ctrl_out[3]),
        .WB_RF_LE(wb_ctrl_out[3]),

        .A_S(A_S),
        .B_S(B_S),
        .D_S(D_S),
        .NOP(NOP),
        .LE(LE_DHDU)
    );
endmodule