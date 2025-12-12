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

    // =============================================================
    // Wires importantes
    // =============================================================
    wire signed [31:0] r1  = DUT.ID.REG_FILE.r1;
    wire signed [31:0] r2  = DUT.ID.REG_FILE.r2;
    wire signed [31:0] r3 = DUT.ID.REG_FILE.r3;
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

    integer i;

    // ============================================
    // Inicialización de reloj
    // ============================================
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end

    // ====================================
    // Inicialización de reset
    // ====================================
    initial begin
        reset = 1;
        #3 reset = 0;
    end

    // =============================================================
    // SELECCIÓN DE TEST
    // =============================================================

`ifdef debugging
    initial begin
        $monitor(
            { "==== debugging ==== \n",
            "PC=%0d NPC=%0d | Address=%0d PW_WB=%0d RW_WB=%0d RF_LE_WB=%0b\n",
            "r5=%0d r6=%0d r16=%0d r17=%0d r18=%0d\n"
            },
            DUT.PC_fetch, DUT.nPC_fetch,
            DUT.alu_result_in, DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB,
            r5, r6, r16, r17, r18
        );
    end

    initial begin
        #76;
        $display("DM[56-59] = %b %b %b %b",
            DUT.MEM.data_memory_inst.Memory[56],
            DUT.MEM.data_memory_inst.Memory[57],
            DUT.MEM.data_memory_inst.Memory[58],
            DUT.MEM.data_memory_inst.Memory[59]
        );
    end

    initial begin
        #80 $finish;
    end

`elsif sparc1
    initial begin
        $monitor(
            { "==== testcode_sparc1 ====\n",
              "PC=%0d NPC=%0d | Adress=%0d PW_WB=%0d RW_WB=%0d RF_LE_WB=%0b\n",
              "r1=%0d r2=%0d r3=%0d r5=%0d\n"
            },
            DUT.PC_fetch, DUT.nPC_fetch,
            DUT.alu_result_in, DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB,
            r1, r2, r3, r5
        );
    end

    initial begin
        #160;
        $display("DM[44-47] = %b %b %b %b",
            DUT.MEM.data_memory_inst.Memory[44],
            DUT.MEM.data_memory_inst.Memory[45],
            DUT.MEM.data_memory_inst.Memory[46],
            DUT.MEM.data_memory_inst.Memory[47]
        );
    end

    initial begin
        #164 $finish;
    end

`elsif sparc2
    initial begin
        $monitor(
            { "==== sparc2 ====\n",
              "PC=%0d NPC=%0d IF_PC=%0d IF_instr=%0d ALU_OUT=%0d Address=%0d DO=%0d PW_WB=%0d RW_WB=%0d RF_LE_WB=%0b\n",
              "r1=%0d r2=%0d r3=%0d r4=%0d r5=%0d r8=%0d r10=%0d r11=%0d r12=%0d r15=%0d\n"
            },
            DUT.PC_fetch, DUT.nPC_fetch, DUT.IF_ID0.pc_out, DUT.IF_ID0.instr_out,
            DUT.Mux_to_mem, DUT.alu_result_in, DUT.MEM.data_memory_inst.DO, DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB,
            r1, r2, r3, r4, r5, r8, r10, r11, r12, r15
        );

        // $monitor(
        //     {
        //     "==== sparc2 ====\n",
        //     " PC_fetch=%0d  FETCH.jmpl=%b  id_ctrl_out=%b\n",
        //     " intr_IF=%b instr_ID=%b instr_EX=%b\n",
        //     " ALU_A=%0d ALU_B=%0d ALU_OP=%0d ALU_Out(EX)=%0d  B_PC_EX=%0d  Mux_to_mem=%0d\n",
        //     " PC_JMPL_IN=%0d  PC_JMPL_OUT=%0d",
        //     " MEM_ADDR(alu_result_in)=%0d MEM_DO(data_out)=%0d PW_WB=%0d RW_WB=%0d RF_LE_WB=%0b\n\n"
        //     },
        //     DUT.PC_fetch, DUT.FETCH.jmpl, DUT.id_ctrl_out,
        //     DUT.instr_F, DUT.instr_ID, DUT.instr_EX3,
        //     DUT.alu0.A, DUT.alu0.B, DUT.ALU_OP, DUT.ALU_Out_EX2, DUT.B_PC_EX, DUT.Mux_to_mem,
        //     DUT.FETCH.u_mux_PC_next.in1, DUT.FETCH.u_mux_PC_next.out,
        //     DUT.alu_result_in, DUT.MEM.data_memory_inst.DO, DUT.PW_WB, DUT.RW_WB, DUT.RF_LE_WB
        // );

    end

    initial begin
        #240;
        for (i = 224; i < 264; i = i + 4) begin
            $display("D[%0d]= %b, D[%0d]= %b, D[%0d]= %b, D[%0d]= %b",
                i,
                DUT.MEM.data_memory_inst.Memory[i],
                i+1,
                DUT.MEM.data_memory_inst.Memory[i+1],
                i+2,
                DUT.MEM.data_memory_inst.Memory[i+2],
                i+3,
                DUT.MEM.data_memory_inst.Memory[i+3]
            );
        end
    end

    initial begin
        #244 $finish;
    end
`else
    initial begin
        $display("ERROR: use command \"iverilog -Ddebugging\" Define debugging, sparc1 or sparc2");
        $finish;
    end
`endif

endmodule