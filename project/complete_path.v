module sparc_top (
    input wire clk,
    input wire reset,

    // outputs visibles para el testbench
    output [8:0]  PC_fetch,
    output [8:0]  nPC_fetch,
    output [31:0] instr_F,

    output [31:0] instr_ID,
    output [8:0]  B_PC_ID,
    output [8:0]  B_PC_EX,

    output [31:0] A_EX,
    output [31:0] B_EX,
    output [31:0] D_EX,
    output [31:0] instr_EX2,
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
    // instr_F, PC_fetch, nPC_fetch ya son puertos de salida (wire implícito)
    wire [8:0]  B_PC_F;

    // ======================================================
    //  Señales IF/ID → DECODING
    // ======================================================
    // instr_ID y B_PC_ID ya son puertos de salida

    // ======================================================
    //  DECODING → ID/EX
    // ======================================================
    // A_EX, B_EX, D_EX, instr_EX, id_ctrl_out, TA ya son puertos
    wire        J;
    wire        carry_flag;
    // 'call' no se usa en este top, así que lo omito

    // ======================================================
    //  ID/EX → EXECUTE
    // ======================================================
    // ex_ctrl_out, D_MEM_tmp, ALU_out_EX, RD_EX_out, CC_EX ya son puertos

    // ======================================================
    //  EXECUTE → EX/MEM → MEMORY
    // ======================================================
    wire [31:0] alu_result_in;
    wire [31:0] mem_ctrl_in;
    wire [31:0] mempipe_ctrl_in;
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
    fetch_stage_path FETCH (
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
        .instr_out(instr_ID),
        .pc_out(B_PC_ID)
    );
 
    // ======================================================
    // ETAPA DECODING
    // ======================================================
    wire [3:1] alu_ICC;
    decoding_stage_path #(
        .ADDR_WIDTH(9),
        .RESET_PC(9'd0),
        .RESET_nPC(9'd4)
    ) ID (
        .clk(clk),
        .reset(reset),
        .B_PC_ID(B_PC_ID),
        .instr_ID(instr_ID),

        // Forwarding inputs
        .ALU_Out_EX(Mux_to_mem),
        .data_mem_mux(data_mux_out),
        .PW_WB(PW_WB), //------------------------------->cambiar a PW_WB
        .RW_WB(RW_WB), //------------------------------->cambiar a RW_WB
        .RF_LE_WB(RF_LE_WB ), //------------------------------------------------>cambiar a RF_LE_WB 

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
        .instr_EX(instr_EX2),
        .TA(TA),
        .J(J),
        .carry_out(carry_flag),
        .id_ctrl_out(id_ctrl_out)

   
    );
 
    

    wire[31:0] instr_EX3;
    wire[31:0] D_EX2;
    wire[31:0] A_EX2;
    wire[31:0] B_EX2;
    // ======================================================
    // REGISTRO ID/EX
    // ======================================================
    ID_EX_reg ID_EX0 (
        .clk(clk),
        .reset(reset),
        .instr_ID(instr_EX2),
        .A_ID(A_EX), 
        .B_ID(B_EX), 
        .D_ID(D_EX), 
        .id_ctrl_in(id_ctrl_out),
        .B_PC_ID(B_PC_ID),

        .instr_EX(instr_EX3),
        .A_EX(A_EX2),
        .B_EX(B_EX2),
        .D_EX(D_EX2),
        .ex_ctrl_out(ex_ctrl_out),
        .B_PC_EX(B_PC_EX)
    );

      // ======================================================
    // ETAPA DE EJECUCIÓN (EX) INLINE
    // ======================================================

    // Decode de la instrucción en EX (viene del ID/EX)
    wire [4:0] RD_EX  = instr_EX3[29:25];
    wire [4:0] RS1_EX = instr_EX3[18:14];
    wire [4:0] RS2_EX = instr_EX3[4:0];

    // Señales de control del EX stage (desde ID/EX_reg → ex_ctrl_out)
    wire [3:0] ALU_OP  = ex_ctrl_out[16:13];
    wire [3:0] SOH_OP  = ex_ctrl_out[12:9];
    wire       CALLbit = ex_ctrl_out[2];

    wire Z_EX, N_EX, C_EX, V_EX;
    // CC y resultado hacia afuera
   
    wire psr_carry = CC_EX[0];
    wire is_addx = (ALU_OP == 4'b0001); // your encoding for ADDX
    wire is_subx = (ALU_OP == 4'b0011); // your encoding for SUBX
    wire use_carry_in = is_addx || is_subx;
    wire Ci_to_ALU = use_carry_in ? psr_carry : 1'b0;
    
    // SOH UNIT
    wire [31:0] SOH_out;

    SOH soh0 (
        .R   (B_EX2),
        .Imm (instr_EX3[21:0]),
        .Is  (SOH_OP),
        .N   (SOH_out)
    );

    // ALU
    wire [31:0] ALU_Out_EX2;
   

    ALU alu0 (
        .Out (ALU_Out_EX2),
        .Z   (Z_EX),
        .N   (N_EX),
        .C   (C_EX),
        .V   (V_EX),
        .A   (A_EX2),
        .B   (SOH_out),
        .Ci  (carry_flag),
        .OP  (ALU_OP)
    );
    
    
     assign CC_EX = {N_EX, Z_EX, V_EX, C_EX};
    
    // MUX RD
    TwoToOneMux #(.WIDTH(5)) RD_mux (
        .in0 (RD_EX),
        .in1 (5'd15),
        .sel (CALLbit),
        .out (RD_EX_out)
    );
    wire [31:0] Mux_to_mem;
    // MUX ALU/PC
    TwoToOneMux #(.WIDTH(32)) ALU_mux (
        .in0 (ALU_Out_EX2),
        .in1 (B_PC_EX),
        .sel (CALLbit),
        .out (Mux_to_mem)
    );

    // Señales directas hacia MEM (igual que antes)
    assign mempipe_ctrl_in = ex_ctrl_out;
    assign D_MEM_tmp       = D_EX2;
/*
  
*/
    // ======================================================
    // REGISTRO EX/MEM
    // ======================================================
    
    EX_MEM_reg EX_MEM0 (
        .clk(clk),
        .reset(reset),

        .ex_alu_out_in(Mux_to_mem), 
        .ex_ctrl_in(mempipe_ctrl_in),
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

        .pw_data_out(PW_WB), //PW_WB
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