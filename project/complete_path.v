module sparc_top (
    input wire clk,
    input wire reset,

    // outputs visibles para el testbench
    output [8:0]  PC_fetch,
    output [8:0]  nPC_fetch,
    output [31:0] instr_F,

    output [31:0] instr_ID,
    output [8:0]  B_PC_ID,

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
    wire [8:0]  B_PC_ID;
    wire [8:0]  B_PC_EX;

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
    /*
    always @(posedge clk) begin
        if (!reset) begin
            $display("IF/ID @t=%0t | instr_F=%h instr_ID=%h",
                     $time,
                    instr_F,
                    instr_ID);       
        end
    end
*/
    // ======================================================
    // ETAPA DECODING
    // ======================================================
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
        .ALU_Out_EX(ALU_out_EX),
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
        
    
/*    
// =====================
// DEBUG DISPLAY FOR DECODING
// =====================
always @(posedge clk) begin
    if (!reset) begin
        $display("==== DECODING @t=%0t ====", $time);
        $display("  B_PC_ID     = %h", B_PC_ID);
        $display("  instr_ID    = %h", instr_ID);

        // Forwarding-related inputs
        $display("  ALU_out_EX  = %h", ALU_out_EX);
        $display("  data_mem_mux= %h", data_mux_out);
        $display("  PW_WB       = %h", PW_WB);
        $display("  RW_WB       = %0d", RW_WB);
        $display("  RF_LE_WB    = %b", RF_LE_WB);

        // DHDU & control
        $display("  NOP         = %b", NOP);
        $display("  LE_DHDU     = %b", LE_DHDU);
        $display("  ALU_CC      = %b", CC_EX);
        $display("  ex_ctrl_in  = %h", ex_ctrl_out);
        $display("  A_S         = %b", A_S);
        $display("  B_S         = %b", B_S);
        $display("  D_S         = %b", D_S);

        // Outputs towards EX
        $display("  A_EX (A_src)= %h", A_EX);
        $display("  B_EX (B_src)= %h", B_EX);
        $display("  D_EX (D_src)= %h", D_EX);
        $display("  instr_EX2   = %h", instr_EX2);
        $display("  TA          = %h", TA);
        $display("  J           = %b", J);
        $display("  carry_flag  = %b", carry_flag);
        $display("  id_ctrl_out = %h", id_ctrl_out);
        $display("========================\n");
    end
end

*/
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

        .B_PC_EX(B_PC_EX),
        .instr_EX(instr_EX3),
        .A_EX(A_EX2),
        .B_EX(B_EX2),
        .D_EX(D_EX2),
        .ex_ctrl_out(ex_ctrl_out)
    );
/*
    always @(posedge clk) begin
        if (!reset) begin
            $display("ID/EX @t=%0t | id_ctrl_out=%h ex_ctrl_out=%h",
                     $time,
                    id_ctrl_out,
                    ex_ctrl_out);       
        end
    end
    */
    // ======================================================
    // ETAPA DE EJECUCIÓN (EX)
    // ======================================================
    execution_stage_path EX (
        .A_EX(A_EX2),
        .B_EX(B_EX2),
        .instr_EX(instr_EX3),
        .ex_ctrl_in(id_ctrl_out),
        .D_EX(D_EX2),
        .C_flag(carry_flag),
        .B_PC_EX(B_PC_EX),

        .ALU_mux_out(ALU_out_EX),
        .RD_EX_out(RD_EX_out),
        .CC_EX(CC_EX),
        .ex_ctrl_out(mempipe_ctrl_in),
        .D_MEM_out(D_MEM_tmp)
    );

  always @(posedge clk) begin
    if (!reset) begin
        $display("EX @ t=%0t", $time);
        $display("  A_EX          = %b", A_EX2);
        $display("  B_EX          = %b", B_EX2);
        $display("  instr_EX      = %b", instr_EX3);
        $display("  ex_ctrl_in    = %b", id_ctrl_out);
        $display("  D_EX          = %b", D_EX2);
        $display("  C_flag        = %b", carry_flag);
        $display("  ALU_mux_out   = %b", ALU_out_EX);
        $display("  RD_EX_out     = %0d", RD_EX_out);
        $display("  CC_EX         = %b", CC_EX);
        $display("  ex_ctrl_out   = %b", mempipe_ctrl_in);
        $display("  D_MEM_out     = %b", D_MEM_tmp);
        $display("");  // blank line for readability
    end
end

    // ======================================================
    // REGISTRO EX/MEM
    // ======================================================
    EX_MEM_reg EX_MEM0 (
        .clk(clk),
        .reset(reset),

        .ex_alu_out_in(ALU_out_EX),
        .ex_ctrl_in(mempipe_ctrl_in),
        .ex_rd_in(RD_EX_out),
        .ex_third_op_in(D_MEM_tmp),

        .mem_alu_out(alu_result_in),
        .mem_ctrl_out(mem_ctrl_in),
        .mem_rd_out(rd_in),
        .mem_third_op_out(DI)
    );
    /*
  always @(posedge clk) begin
    if (!reset) begin
        $display("EX/MEM @ t=%0t", $time);
        $display("  ex_alu_out_in   = %h", ALU_out_EX);
        $display("  ex_ctrl_in      = %h", mempipe_ctrl_in);
        $display("  ex_rd_in        = %0d", RD_EX_out);
        $display("  ex_third_op_in  = %h", D_MEM_tmp);
        $display("  mem_alu_out     = %h", alu_result_in);
        $display("  mem_ctrl_out    = %h", mem_ctrl_in);
        $display("  mem_rd_out      = %0d", rd_in);
        $display("  mem_third_op_out= %h", DI);
        $display("");  // blank line for readability
    end
end
*/
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

    // always @(posedge clk) begin
    //     if (!reset) begin
    //         $display("Memory stage @t=%0t | alu in=%b data mux out=%b memcontrolIN=%b",
    //                  $time,
    //                 alu_result_in,
    //                data_mux_out,
    //                 mem_ctrl_in);       
    //     end
    // end
    /*
    always @(posedge clk) begin
    if (!reset) begin
        $display("MEM @t=%0t | alu_result_in=%h mem_ctrl_in=%h rd_in=%0d DI=%h | data_mux_out=%h mem_ctrl_out=%h rd_mem=%0d",
                 $time,
                 alu_result_in,
                 mem_ctrl_in,
                 rd_in,
                 DI,
                 data_mux_out,
                 mem_ctrl_out,
                 rd_mem);
    end
end
    */
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
   
  
    always @(posedge clk) begin
        if (!reset) begin
            $display("ID/EX @t=%0t |  PW_WB=%h RW_WB=%0d",
                     $time,
                    PW_WB,
                    RW_WB);       
        end
    end


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