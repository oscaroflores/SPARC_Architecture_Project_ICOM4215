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
    // Imprimir en cada flanco de subida del reloj
    // =============================================================

    always @(posedge clk) begin
        $display("PC=%0d  r5=%0d  r6=%0d  r16=%0d  r17=%0d  r18=%0d",
                 DUT.PC_fetch,
                 r5, r6, r16, r17, r18);
        $display("------------------------------------------------------------");
        $display("ALU_Out_EX=%0d | ALU_mux_out=%0d | A_EX=%0d | B_EX=%0d | DUT.EX.ex_ctrl_out=%b | data_mux_out=%0d | L_MEM=%b",
                 DUT.ALU_out_EX,
                    DUT.ALU_mux_out,
                    DUT.A_EX,
                    DUT.B_EX,
                    DUT.ex_ctrl_out,
                    DUT.MEM.data_mux_out, 
                    DUT.MEM.L
                 );
        $display("============================================================");
        $display("");

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
