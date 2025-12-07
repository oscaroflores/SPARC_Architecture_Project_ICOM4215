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
    wire signed [31:0] r1  = DUT.ID.REG_FILE.r1;
    wire signed [31:0] r2  = DUT.ID.REG_FILE.r2;
    wire signed [31:0] r3  = DUT.ID.REG_FILE.r3;
    wire signed [31:0] r4  = DUT.ID.REG_FILE.r4;
    wire signed [31:0] r5  = DUT.ID.REG_FILE.r5;
    wire signed [31:0] r6  = DUT.ID.REG_FILE.r6;
    wire signed [31:0] r8  = DUT.ID.REG_FILE.r8;
    wire signed [31:0] r10 = DUT.ID.REG_FILE.r10;
    wire signed [31:0] r11 = DUT.ID.REG_FILE.r11;
    wire signed [31:0] r12 = DUT.ID.REG_FILE.r12;
    wire signed [31:0] r15 = DUT.ID.REG_FILE.r15;
    wire signed [31:0] r16 = DUT.ID.REG_FILE.r16;
    wire signed [31:0] r17 = DUT.ID.REG_FILE.r17;
    wire signed [31:0] r18 = DUT.ID.REG_FILE.r18;

    
    // =============================================================
    // Imprimir
    // =============================================================

    initial begin
        $monitor(
            "PC=%0d  NPC=%0d | PW_WB=%0d  RW_WB=%0d  RF_LE_WB=%0b\n\
            r1=%0d   r2=%0d   r3=%0d\n\
            r4=%0d   r5=%0d   r6=%0d\n\
            r8=%0d   r10=%0d  r11=%0d\n\
            r12=%0d  r15=%0d  r16=%0d\n\
            r17=%0d  r18=%0d\n\
            -------------------------------------------------------------",
            
            // PC + WB control
            DUT.PC_fetch, DUT.nPC_fetch,
            DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB,

            // Registers
            r1,  r2,  r3,  
            r4,  r5,  r6,
            r8,  r10, r11, 
            r12, r15, r16,
            r17, r18
        );
    end


    // always @(posedge clk) begin
    //     $display("PC=%0d NPC=%0d  
    //     r5=%0d  
    //     r6=%0d  
    //     r16=%0d 
    //     r17=%0d  
    //     r18=%0d, 
    //     DUT.PW_WB=%0d, DUT.RW_WB=%0d, DUT.RF_LE_WB=%0b",
    //              DUT.PC_fetch,
    //              DUT.nPC_fetch,
    //              r5, r6, r16, r17, r18,
    //              DUT.PW_WB,
    //              DUT.RW_WB,
    //              DUT.RF_LE_WB);
    //     $display("------------------------------------------------------------");
    //     // $display("ALU_Out_EX=%0d | ALU_mux_out=%0d | A_EX=%0d | B_EX=%0d | DUT.EX.ex_ctrl_out=%b | data_mux_out=%0d | L_MEM=%b",
    //     //          DUT.ALU_out_EX,
    //     //             DUT.ALU_mux_out,
    //     //             DUT.A_EX,
    //     //             DUT.B_EX,
    //     //             DUT.ex_ctrl_out,
    //     //             DUT.MEM.data_mux_out, 
    //     //             DUT.MEM.L
    //     //          );
    //     // $display("============================================================");
        
    //     $display("");
    // end
 
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

        // $display("t=%0t | DM[56] = %b", $time, word56);
    end

    // =============================================================
    // Terminar simulación en t=80
    // =============================================================
    initial begin
        #80;
        $finish;
    end

endmodule
