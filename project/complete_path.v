module sparc_top (
    input wire clk,
    input wire reset,

    //outputs
    output [8:0] PC_fetch,
    output [8:0] nPC_fetch,
    output [31:0] instr_F,

    output [31:0] instr_ID,
    output [8:0]  B_PC_ID,

    output [31:0] A_EX,
    output [31:0] B_EX,
    output [31:0] D_EX,
    output [31:0] instr_EX,
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
    //  Señales internas entre FETCH → IF/ID
    // ======================================================
    wire [31:0] instr_F;
    wire [8:0]  B_PC_F;
    wire [8:0]  PC_fetch, nPC_fetch;

    // Señales de control del fetch
    wire pc_LE = 1'b1;
    wire npc_LE = 1'b1;

    // ======================================================
    //  Señales IF/ID → DECODING
    // ======================================================
    wire [31:0] instr_ID;
    wire [8:0]  B_PC_ID;

    // ======================================================
    //  DECODING → ID/EX
    // ======================================================
    wire [31:0] A_EX, B_EX, D_EX;
    wire [31:0] instr_EX;
    wire [31:0] id_ctrl_out;
    wire [8:0]  TA;
    wire J, call;

    // ======================================================
    //  ID/EX → EXECUTE
    // ======================================================
    wire [31:0] ex_ctrl_out;
    wire [31:0] D_MEM_tmp;
    wire [31:0] ALU_out_EX;
    wire [4:0]  RD_EX_out;
    wire [3:0]  CC_EX;

    // ======================================================
    //  EXECUTE → EX/MEM → MEMORY
    // ======================================================
    wire [31:0] alu_result_in;
    wire [31:0] mem_ctrl_in;
    wire [4:0]  rd_in;
    wire [31:0] DI;

    wire [31:0] mem_ctrl_out;
    wire [31:0] data_mux_out;
    wire [4:0]  rd_mem;

    // ======================================================
    //  MEM/WB → WRITEBACK
    // ======================================================
    wire [31:0] PW_WB;
    wire [4:0]  RW_WB;
    wire        RF_LE_WB;
    wire [31:0] wb_ctrl_out;

    // ======================================================
    //  ETAPA FETCH
    // ======================================================
    fetch_stage_path FETCH (
        .clk(clk),
        .reset(reset),
        .pc_LE(pc_LE),
        .npc_LE(npc_LE),
        .call(ex_ctrl_in[2]),
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
    //  DHDU: Data Hazard Detection Unit
    // ======================================================
    wire [1:0] A_S;
    wire [1:0] B_S;
    wire [1:0] D_S;
    wire       NOP;
    wire       LE_DHDU;

    // ======================================================
    //  REGISTRO IF/ID
    // ======================================================
    IF_ID_reg IF_ID0 (
        .clk(clk),
        .reset(reset),
        .instr_in(instr_F),
        .pc_in(B_PC_F),
        .LE(LE), // Verificar señal
        .instr_out(instr_ID),
        .pc_out(B_PC_ID)
    );

    // ======================================================
    // ETAPA DECODING
    // ======================================================
    decoding_stage_path #(
        .ADDR_WIDTH(9),
        .RESET_PC(9'd0),
        .RESET_nPC(9'd4)
    ) ID (
        // Inputs
        .clk(clk),
        .reset(reset),
        .B_PC_ID(B_PC_ID),
        .instr_ID(instr_ID),

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
        .A_src(A_EX),
        .B_src(B_EX),
        .D_src(D_EX),
        .instr_EX(instr_EX),
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
        .instr_ID(instr_EX),
        .A_ID(A_EX),
        .B_ID(B_EX),
        .D_ID(D_EX),
        .id_ctrl_in(id_ctrl_out),

        .instr_EX(instr_EX),
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
        .instr_EX(instr_EX),
        .ex_ctrl_in(ex_ctrl_out),
        .D_EX(D_EX),
        .C_flag(carry_flag),

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
        // Inputs
        .EX_L(ex_ctrl_out[4]),  // EX load signal
        .SR(id_ctrl_out[20:18]),     // write enable from ID stage
        .RA(instr_ID[18:14]),
        .RB(instr_ID[4:0]),
        .RD(instr_ID[29:25]),
        .EX_RD(RD_EX_out),
        .MEM_RD(rd_mem),
        .WB_RD(ALU_out_EX[4:0]), // VERIFICAR Que bits del alu out van al RD
        .EX_RF_LE(ex_ctrl_out[3]),
        .MEM_RF_LE(mem_ctrl_out[3]),
        .WB_RF_LE(wb_ctrl_out[3]),

        // Outputs
        .A_S(A_S),
        .B_S(B_S),
        .D_S(D_S),
        .NOP(NOP),
        .LE(LE_DHDU)
    );
endmodule