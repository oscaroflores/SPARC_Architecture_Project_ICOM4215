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
    // INICIALIZAR REGISTER FILE: r1–r31 = 0 al inicio
    // (para evitar propagación de X desde FFs sin reset explícito)
    // =============================================================
    /*
    initial begin
        // Forzamos cada registro individual a 0
        force DUT.ID.REG_FILE.r1  = 32'd0;
        force DUT.ID.REG_FILE.r2  = 32'd0;
        force DUT.ID.REG_FILE.r3  = 32'd0;
        force DUT.ID.REG_FILE.r4  = 32'd0;
        force DUT.ID.REG_FILE.r5  = 32'd0;
        force DUT.ID.REG_FILE.r6  = 32'd0;
        force DUT.ID.REG_FILE.r7  = 32'd0;
        force DUT.ID.REG_FILE.r8  = 32'd0;
        force DUT.ID.REG_FILE.r9  = 32'd0;
        force DUT.ID.REG_FILE.r10 = 32'd0;
        force DUT.ID.REG_FILE.r11 = 32'd0;
        force DUT.ID.REG_FILE.r12 = 32'd0;
        force DUT.ID.REG_FILE.r13 = 32'd0;
        force DUT.ID.REG_FILE.r14 = 32'd0;
        force DUT.ID.REG_FILE.r15 = 32'd0;
        force DUT.ID.REG_FILE.r16 = 32'd0;
        force DUT.ID.REG_FILE.r17 = 32'd0;
        force DUT.ID.REG_FILE.r18 = 32'd0;
        force DUT.ID.REG_FILE.r19 = 32'd0;
        force DUT.ID.REG_FILE.r20 = 32'd0;
        force DUT.ID.REG_FILE.r21 = 32'd0;
        force DUT.ID.REG_FILE.r22 = 32'd0;
        force DUT.ID.REG_FILE.r23 = 32'd0;
        force DUT.ID.REG_FILE.r24 = 32'd0;
        force DUT.ID.REG_FILE.r25 = 32'd0;
        force DUT.ID.REG_FILE.r26 = 32'd0;
        force DUT.ID.REG_FILE.r27 = 32'd0;
        force DUT.ID.REG_FILE.r28 = 32'd0;
        force DUT.ID.REG_FILE.r29 = 32'd0;
        force DUT.ID.REG_FILE.r30 = 32'd0;
        force DUT.ID.REG_FILE.r31 = 32'd0;

        // Dejamos que el diseño se estabilice con esos valores
        #20;

        // Luego soltamos para que WriteBack pueda escribir normalmente
        release DUT.ID.REG_FILE.r1;
        release DUT.ID.REG_FILE.r2;
        release DUT.ID.REG_FILE.r3;
        release DUT.ID.REG_FILE.r4;
        release DUT.ID.REG_FILE.r5;
        release DUT.ID.REG_FILE.r6;
        release DUT.ID.REG_FILE.r7;
        release DUT.ID.REG_FILE.r8;
        release DUT.ID.REG_FILE.r9;
        release DUT.ID.REG_FILE.r10;
        release DUT.ID.REG_FILE.r11;
        release DUT.ID.REG_FILE.r12;
        release DUT.ID.REG_FILE.r13;
        release DUT.ID.REG_FILE.r14;
        release DUT.ID.REG_FILE.r15;
        release DUT.ID.REG_FILE.r16;
        release DUT.ID.REG_FILE.r17;
        release DUT.ID.REG_FILE.r18;
        release DUT.ID.REG_FILE.r19;
        release DUT.ID.REG_FILE.r20;
        release DUT.ID.REG_FILE.r21;
        release DUT.ID.REG_FILE.r22;
        release DUT.ID.REG_FILE.r23;
        release DUT.ID.REG_FILE.r24;
        release DUT.ID.REG_FILE.r25;
        release DUT.ID.REG_FILE.r26;
        release DUT.ID.REG_FILE.r27;
        release DUT.ID.REG_FILE.r28;
        release DUT.ID.REG_FILE.r29;
        release DUT.ID.REG_FILE.r30;
        release DUT.ID.REG_FILE.r31;
    end
    */
    //////////////////////////////

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
        $display("t=%0t | PC=%0d  r5=%0d  r6=%0d  r16=%0d  r17=%0d  r18=%0d",
                 $time,
                 DUT.PC_fetch,
                 r5, r6, r16, r17, r18);
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
