module sparc_top (
    input wire clk,
    input wire reset
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
    wire [8:0]  B_PC_EX;
    wire [4:0]  RW_EX;
    wire [8:0]  TA;
    wire J, call;
    wire carry_flag;

    // ======================================================
    //  ID/EX → EXECUTE
    // ======================================================
    wire [31:0] ex_ctrl_out;
    wire [31:0] D_MEM_tmp;
    wire [31:0] ALU_out_EX;
    wire [4:0]  RD_EX_out;
    wire [3:0]  CC_EX;
    wire L_EX, RF_LE_EX;

    // ======================================================
    //  EXECUTE → EX/MEM → MEMORY
    // ======================================================
    wire [31:0] mem_ctrl_out;
    wire [31:0] data_mux_out;
    wire [4:0]  rd_mem;

    // ======================================================
    //  MEM/WB → WRITEBACK
    // ======================================================
    wire [31:0] PW_WB;
    wire [4:0]  RW_WB;
    wire        RF_LE_WB;

    // ======================================================
    //  ETAPA FETCH
    // ======================================================
    fetch_path FETCH (
        .clk(clk),
        .reset(reset),
        .pc_LE(pc_LE),
        .npc_LE(npc_LE),
        .jmpl(call),
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
        .LE(1'b1),
        .instr_out(instr_ID),
        .pc_out(B_PC_ID)
    );

    // ======================================================
    // ETAPA DECODING
    // ======================================================
    decoding_stage_path ID (
        .clk(clk),
        .reset(reset),
        .B_PC_ID(B_PC_ID),
        .instr_ID(instr_ID),

        // Forwarding desde EX y MEM y WB
        .ALU_Out_EX(ALU_out_EX),
        .data_mem_mux(data_mux_out),
        .PW_WB(PW_WB),
        .RW_WB(RW_WB),
        .RF_LE_WB(RF_LE_WB),

        .id_ctrl_in(32'd0),

        .CC_EN(1'b1),
        .ICC_in(CC_EX),

        .A_src(A_EX),
        .B_src(B_EX),
        .D_src(D_EX),
        .B_PC_EX(B_PC_EX),
        .I(instr_EX),
        .RW_EX(RW_EX),
        .TA(TA),
        .SR(),
        .J(J),
        .carry_out(carry_flag),
        .call(call),
        .id_ctrl_out(id_ctrl_out)
    );

    // ======================================================
    // REGISTRO ID/EX
    // ======================================================
    ID_EX_reg ID_EX0 (
        .clk(clk),
        .reset(reset),
        .instr_in(instr_EX),
        .A_in(A_EX),
        .B_in(B_EX),
        .D_in(D_EX),
        .ctrl_in(id_ctrl_out),

        .instr_out(instr_EX),
        .A_out(A_EX),
        .B_out(B_EX),
        .D_out(D_EX),
        .ctrl_out(ex_ctrl_out)
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
        .D_MEM_out(D_MEM_tmp),
        .L_EX(L_EX),
        .RF_LE_EX(RF_LE_EX)
    );

    // ======================================================
    // REGISTRO EX/MEM
    // ======================================================
    EX_MEM_reg EX_MEM0 (
        .clk(clk),
        .reset(reset),

        .ALU_in(ALU_out_EX),
        .ctrl_in(ex_ctrl_out),
        .rd_in(RD_EX_out),
        .D_in(D_MEM_tmp),

        .ALU_out(alu_result_in),
        .ctrl_out(mem_ctrl_in),
        .rd_out(rd_in),
        .D_out(DI)
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
        .data_in(data_mux_out),
        .rd_in(rd_mem),
        .ctrl_in(mem_ctrl_out),

        .data_out(PW_WB),
        .rd_out(RW_WB),
        .ctrl_out(RF_LE_WB)
    );

endmodule