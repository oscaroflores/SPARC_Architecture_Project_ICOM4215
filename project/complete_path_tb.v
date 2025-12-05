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
    // FIX PARA JDOODLE: evitar X en señales de control críticas
    // (para que FETCH no se contamine al inicio)
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

    // =============================================================
    // INICIALIZAR REGISTER FILE: r1–r31 = 0 al inicio
    // (para evitar propagación de X desde FFs sin reset explícito)
    // =============================================================
    initial begin
        // Dejamos que el diseño se estabilice con esos valores
        #20;

        // Luego soltamos para que WriteBack pueda escribir normalmente

    end
    
    //////////////////////////////
    wire [4:0]  RW_WB_tb   = DUT.RW_WB;
    wire [31:0] PW_WB_tb   = DUT.PW_WB;
    wire        RF_LE_WB_tb = DUT.RF_LE_WB;

    /*
    always @(posedge clk) begin
        $display("t=%0t | PC=%0d | RF_LE_WB=%b RW_WB=%0d PW_WB=%0d",
            $time, DUT.PC_fetch, RF_LE_WB_tb, RW_WB_tb, PW_WB_tb);
        $display(" ");
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