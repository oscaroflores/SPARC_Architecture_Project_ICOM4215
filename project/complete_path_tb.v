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
    initial begin
        // Fuerza enable de PC/nPC y señales de brinco a algo conocido
        force DUT.LE_DHDU     = 1'b1;
        force DUT.J           = 1'b0;
        force DUT.TA          = 9'd0;

        // Fuerza señales de control de EX que llegan a FETCH
        force DUT.ex_ctrl_out = 32'b0;
        force DUT.ALU_out_EX  = 32'b0;

        // Después de unos ciclos, soltamos y dejamos que el diseño corra normal
        #10;
        release DUT.LE_DHDU;
        release DUT.J;
        release DUT.TA;
        release DUT.ex_ctrl_out;
        release DUT.ALU_out_EX;
    end

    //////////////////////////////
    wire [4:0]  RW_WB_tb    = DUT.RW_WB;
    wire [31:0] PW_WB_tb    = DUT.PW_WB;
    wire        RF_LE_WB_tb = DUT.RF_LE_WB;

    // =============================================================
    // Monitor por cambios en todo el pipeline
    // =============================================================
    initial begin
        $display("========== PIPELINE MONITOR ==========");
        $monitor(
            "t=%0t\n\
            [FETCH]      PC=%0d  nPC=%0d  INSTR_F=%b\n\n\
            [IF/ID]     INSTR_IF_ID=%b\n\n\
            [DECODE]     INSTR_ID=%b  B_PC_ID=%0b TA=%0b J=%0b\n\
                        A_ID=%b  B_ID=%b  D_ID=%b  CARRY_OUT=%b  ID_CTRL=%b\n\n\
            [ID/EX]      INSTR_ID_EX=%b\n\
                        A_EX=%b  B_EX=%b  D_EX=%b\n\
                        ID_CTRL=%b   TA=%0b\n\n\
            [EXECUTE]    ALU=%b  RD_EX=%0d  CC=%b\n\
                        EX_CTRL=%b  D_MEM_tmp=%b\n\n\
            [MEM]        DATA_MUX=%b  MEM_CTRL=%b RD_MEM=%0d\n\n\
            [WRITEBACK]  PW_WB=%b RW_WB=%0d RF_LE=%b\n\
                        WB_CTRL=%b\n\n\
            [DHDU]       A_S=%b B_S=%b D_S=%b  LE=%b  NOP=%b\n\n\
            ------------------------------------------------------\n",
            $time,
            // FETCH
            DUT.PC_fetch, DUT.nPC_fetch, DUT.instr_F,
            // IF/ID
            DUT.instr_IF_ID,
            // DECODE
            DUT.instr_ID_EX, DUT.B_PC_ID, DUT.TA, DUT.J,
            DUT.A_ID, DUT.B_ID, DUT.D_ID, DUT.carry_out, DUT.id_ctrl_out,
            // ID/EX
            DUT.instr_ID_EX,
            DUT.A_EX, DUT.B_EX, DUT.D_EX,
            DUT.id_ctrl_out, DUT.TA,
            // EXECUTE
            DUT.ALU_mux_out, DUT.RD_EX_out, DUT.CC_EX,
            DUT.ex_ctrl_out, DUT.D_MEM_out,DUT.L_EX, DUT.RF_LE_EX,
            // EX/MEM

            // MEM
            DUT.data_mux_out, DUT.mem_ctrl_out, DUT.rd_mem,
            // WB
            DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB,
            DUT.wb_ctrl_out,
            // DHDU
            DUT.A_S, DUT.B_S, DUT.D_S, DUT.LE_DHDU, DUT.NOP
        );
    end
    */

    // =============================================================
    // Wires para debug de registros específicos (RF interno)
    // =============================================================
    wire signed [31:0] r5  = DUT.ID.REG_FILE.r5;
    wire signed [31:0] r6  = DUT.ID.REG_FILE.r6;
    wire signed [31:0] r16 = DUT.ID.REG_FILE.r16;
    wire signed [31:0] r17 = DUT.ID.REG_FILE.r17;
    wire signed [31:0] r18 = DUT.ID.REG_FILE.r18;

    // =============================================================
    // Imprimir en cada flanco de subida del reloj
    // =============================================================
    
    always @(posedge clk) begin
        $display("t=%0t | PC=%0d NPC=%0d INTR_IF=%0b INSTR_ID=%0b INSTR_EX=%0b r5=%0d  r6=%0d  r16=%0d  r17=%0d  r18=%0d A_EX=%0d B_EX=%0d D_EX=%0d CNTRL=%0b",
                 $time,
                 DUT.PC_fetch,
                 DUT.nPC_fetch,
                 DUT.instr_F,
                 DUT.instr_ID,
                 DUT.instr_ID_EX,
                 r5, r6, r16, r17, r18, DUT.A_EX, DUT.B_EX, DUT.D_EX, DUT.id_ctrl_out);
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