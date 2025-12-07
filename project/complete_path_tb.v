`timescale 1ns/1ps

module sparc_tb();

    reg clk;
    reg reset;

    // ============================
    // Instancia del DUT
    // ============================
    sparc_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // ============================
    // Generación del reloj (toggle cada 2)
    // ============================
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;
    end

    // ============================
    // Reset: 1 → 0 en t = 3
    // ============================
    initial begin
        reset = 1'b1;
        #3 reset = 1'b0;
    end

    // =============================================================
    // Wires para debug de registros específicos (RF interno)
    // =============================================================
    wire signed [31:0] r5  = DUT.ID.REG_FILE.r5;
    wire signed [31:0] r6  = DUT.ID.REG_FILE.r6;
    wire signed [31:0] r16 = DUT.ID.REG_FILE.r16;
    wire signed [31:0] r17 = DUT.ID.REG_FILE.r17;
    wire signed [31:0] r18 = DUT.ID.REG_FILE.r18;

    // =============================================================
    // Wires para debug de la ALU y el registro EX/MEM
    //  - ALU_Out_EX  : salida directa del ALU dentro de ex_stage_path
    //  - ALU_mux_out : salida del mux (ALU vs B_PC) hacia el registro EX/MEM
    //  - ex_alu_out_in: entrada del registro EX/MEM (mismo valor que ALU_mux_out)
    //  - mem_alu_out : salida del registro EX/MEM hacia la etapa de MEM
    // =============================================================
    wire [31:0] ALU_Out_EX    = DUT.EX.ALU_Out_EX;     // salida "cruda" del ALU
    wire [31:0] ALU_mux_out   = DUT.ALU_out_EX;        // salida mux hacia EX/MEM
    wire [31:0] ex_alu_out_in = DUT.ALU_out_EX;        // entrada ex_alu_out_in del EX/MEM
    wire [31:0] mem_alu_out   = DUT.alu_result_in;     // salida mem_alu_out del EX/MEM

    // =============================================================
    // Wires para debug detallado de la etapa EX
    // =============================================================
    wire [31:0] A_EX2       = DUT.EX.A_EX;
    wire [31:0] B_EX2       = DUT.EX.B_EX;
    wire [31:0] D_EX2       = DUT.EX.D_EX;
    wire [31:0] instr_EX3   = DUT.EX.instr_EX;
    wire [31:0] ex_ctrl_in  = DUT.id_ctrl_out;      // control que entra a ID/EX
    wire        carry_flag  = DUT.carry_flag;
    wire [4:0]  RD_EX_out   = DUT.RD_EX_out;        // puerto de salida
    wire [3:0]  CC_EX       = DUT.CC_EX;            // puerto de salida
    wire [31:0] ex_ctrl_out = DUT.mempipe_ctrl_in;  // control que sale de EX hacia EX/MEM
    wire [31:0] D_MEM_tmp   = DUT.D_MEM_tmp;        // tercer operando hacia memoria

    // =============================================================
    // Wires para debug de las señales de control (id_ctrl_out)
    // =============================================================
    wire [31:0] ctrl_ID         = DUT.id_ctrl_out;
    wire [2:0]  ctrl_ID_SR      = ctrl_ID[20:18];
    wire        ctrl_CC         = ctrl_ID[17];
    wire [3:0]  ctrl_ALU_OP     = ctrl_ID[16:13];
    wire [3:0]  ctrl_SOH_OP     = ctrl_ID[12:9];
    wire [1:0]  ctrl_RAM_Size   = ctrl_ID[8:7];
    wire        ctrl_RAM_RW     = ctrl_ID[6];
    wire        ctrl_RAM_Enable = ctrl_ID[5];
    wire        ctrl_L          = ctrl_ID[4];
    wire        ctrl_RF_LE      = ctrl_ID[3];
    wire        ctrl_CALL       = ctrl_ID[2];
    wire        ctrl_JMPL       = ctrl_ID[1];
    wire        ctrl_B          = ctrl_ID[0];

    // =============================================================
    // Wires para debug de la etapa ID/DECODING
    //  - instr_ID      : instrucción en etapa de decode (desde IF/ID)
    //  - A_dec/B_dec   : operandos A/B saliendo de decode (A_src/B_src)
    //  - D_dec         : tercer operando desde decode (D_src)
    //  - PW_WB_dec     : dato de write-back que llega a decode
    //  - RW_WB_dec     : registro destino de write-back que llega a decode
    //  - RA_rf/RB_rf/RD_rf : direcciones de registros decodificadas
    // =============================================================
    wire [31:0] instr_ID   = DUT.ID.instr_ID;   // instrucción en ID
    wire [31:0] A_dec      = DUT.ID.A_src;       // A_src desde decode
    wire [31:0] B_dec      = DUT.ID.B_src;       // B_src desde decode
    wire [31:0] D_dec      = DUT.ID.D_src;       // D_src desde decode
    wire [31:0] PW_WB_dec  = DUT.ID.PW_WB;      // dato de WB que llega a ID
    wire [4:0]  RW_WB_dec  = DUT.ID.RW_WB;      // registro destino WB que llega a ID

    wire [4:0]  RA_rf      = DUT.ID.RA_rf;   // rs1 decodificado
    wire [4:0]  RB_rf      = DUT.ID.RB_rf;   // rs2 decodificado
    wire [4:0]  RD_rf      = DUT.ID.RD_rf;   // rd decodificado

    // =============================================================
    // Imprimir en cada flanco de subida del reloj
    // =============================================================

    always @(posedge clk) begin
        if (!reset) begin
            $display("================================================================");
            $display("t=%0t | PC_fetch=%0d", $time, DUT.PC_fetch);

            // Snapshot de algunos registros del RF
            $display("RF  : r5=%0d  r6=%0d  r16=%0d  r17=%0d  r18=%0d",
                     r5, r6, r16, r17, r18);

            // ------------------------- ETAPA ID / DECODING -------------
            $display("-- ID (Decoding) ---------------------------------------------");
            $display("  instr_ID     = %b %b %b %b",
                     instr_ID[31:24],  
                     instr_ID[23:16],  
                     instr_ID[15:8], 
                     instr_ID[7:0]);   
            $display("  A_dec (A_src)= %h", A_dec);
            $display("  B_dec (B_src)= %h", B_dec);
            $display("  D_dec (D_src)= %h", D_dec);
            $display("  PW_WB_dec    = %h  (dato WB que llega a ID)", PW_WB_dec);
            $display("  RW_WB_dec    = %0d (reg WB que llega a ID)", RW_WB_dec);
            $display("  RA_rf/RB_rf/RD_rf = %0d %0d %0d", RA_rf, RB_rf, RD_rf);

            // ------------------------- ETAPA EX -------------------------
            $display("-- EX (Execution) ---------------------------------------------");
            $display("  A_EX         = %b", A_EX2);
            $display("  B_EX         = %b", B_EX2);
            $display("  instr_EX     = %b %b %b %b",
                     instr_EX3[31:24], instr_EX3[23:16], instr_EX3[15:8], instr_EX3[7:0]);
            $display("  ex_ctrl_in   = %b", ex_ctrl_in);
            $display("  D_EX         = %h", D_EX2);
            $display("  C_flag       = %b", carry_flag);
            $display("  ALU_Out_EX   = %h", ALU_Out_EX);   // salida directa del ALU
            $display("  ALU_mux_out  = %h", ALU_mux_out);  // salida del mux hacia EX/MEM
            $display("  RD_EX_out    = %0d", RD_EX_out);
            $display("  CC_EX        = %b", CC_EX);
            $display("  ex_ctrl_out  = %b", ex_ctrl_out);
            $display("  D_MEM_tmp    = %h", D_MEM_tmp);

            // ----------------------- REGISTRO EX/MEM ---------------------
            $display("-- EX/MEM register --------------------------------------------");
            $display("  ex_alu_out_in = %h", ex_alu_out_in); // entrada al registro
            $display("  mem_alu_out   = %h", mem_alu_out);   // salida hacia MEM

            // ----------------------- SEÑALES DE CONTROL ------------------
            $display("-- CONTROL UNIT (id_ctrl_out) ---------------------------------");
            $display("  ctrl_ID      = %h", ctrl_ID);
            $display("  ID_SR        = %b", ctrl_ID_SR);
            $display("  CC           = %b", ctrl_CC);
            $display("  ALU_OP       = %b", ctrl_ALU_OP);
            $display("  SOH_OP       = %b", ctrl_SOH_OP);
            $display("  RAM_Size     = %b", ctrl_RAM_Size);
            $display("  RAM_RW       = %b", ctrl_RAM_RW);
            $display("  RAM_Enable   = %b", ctrl_RAM_Enable);
            $display("  L            = %b", ctrl_L);
            $display("  RF_LE        = %b", ctrl_RF_LE);
            $display("  CALL         = %b", ctrl_CALL);
            $display("  JMPL         = %b", ctrl_JMPL);
            $display("  B            = %b", ctrl_B);

            $display("----------------------------------------------------------------");
        end
    end
 
    // =============================================================
    // Leer palabra en DM[56] en t ≈ 76
    // =============================================================
    reg [31:0] word56;


    initial begin
        #76;
        word56 = {
            DUT.MEM.data_memory_inst.Memory[56],
            DUT.MEM.data_memory_inst.Memory[57],
            DUT.MEM.data_memory_inst.Memory[58],
            DUT.MEM.data_memory_inst.Memory[59]
        };

        $display("t=%0t | DM[56] = %b", $time, word56);
    end

    // =============================================================
    // Terminar simulación en t=80
    // =============================================================
    initial begin
        #80;
        $finish;
    end

endmodule
