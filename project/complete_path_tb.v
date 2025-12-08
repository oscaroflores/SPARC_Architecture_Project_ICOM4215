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
    // Imprimir en cada flanco de subida del reloj
    // =============================================================

    initial begin
    $monitor("t=%0t | PC=%0d  r5=%0d  r6=%0d  r16=%0d  r17=%0d  r18=%0d",
             $time,
             DUT.PC_fetch,
             r5, r6, r16, r17, r18);
end

    wire [1:0] opcode  = DUT.instr_ID[31:30];
    wire [3:0] cond    = DUT.instr_ID[28:25];
    wire [2:0] opcode2 = DUT.instr_ID[24:22];
    wire [5:0] opcode3 = DUT.instr_ID[24:19];

   
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
