`timescale 1ns/1ps

module fetch_path_tb;

    // Clock and reset
    reg clk;
    reg reset;

    // Enables for PC and nPC
    reg pc_LE;
    reg npc_LE;

    // Control signals from later stages
    reg call;         // CALL control
    reg J;            // branch taken (from condition handler)
    reg jmpl;         // JMPL control

    // Target addresses coming back from later stages
    reg  [8:0] TA;        // Target Address (branch / call)
    reg  [8:0] ALU_out;   // JMPL target (ALU result[8:0])

    // Outputs from fetch_path
    wire [31:0] instr_F;  // instruction read from instruction_memory
    wire [8:0]  B_PC;     // PC forwarded to IF/ID
    wire [8:0]  PC_out;   // PC register (for debug)
    wire [8:0]  nPC_out;  // nPC register (for debug)

    // ===========================
    //  DUT: fetch stage pipeline
    // ===========================
    fetch_path dut (
        .clk      (clk),
        .reset    (reset),

        .pc_LE    (pc_LE),
        .npc_LE   (npc_LE),

        .call     (call),
        .J        (J),
        .jmpl     (jmpl),

        .TA       (TA),
        .ALU_out  (ALU_out),

        .instr_F  (instr_F),
        .B_PC     (B_PC),
        .PC_out   (PC_out),
        .nPC_out  (nPC_out)
    );

    initial begin
        // ruta relativa desde donde corres vvp/iverilog
        $readmemb("precharge_validation_program.txt", 
                dut.u_imem.Memory);
    end

    // ===========================
    //  Clock generation
    // ===========================
    initial begin
        clk = 1'b0;
        forever #2 clk = ~clk;   // period = 4 time units
    end

    // ===========================
    //  Stimulus
    // ===========================
    initial begin
        // Default: sequential fetch, no branches or calls yet
        pc_LE   = 1'b1;
        npc_LE  = 1'b1;
        call    = 1'b0;
        J       = 1'b0;
        jmpl    = 1'b0;
        TA      = 9'd0;
        ALU_out = 9'd0;

        // Reset as specified: 1 at t=0, 0 at t=3
        reset = 1'b1;
        #3 reset = 1'b0;

        // Run long enough to see several instructions
        #80 $finish;
    end

    // ===========================
    //  Monitoring
    // ===========================
    initial begin
        $display(" time | PC  nPC  B_PC | instruction");
        $display("-----------------------------------------------");
        $monitor("%8b %8b %8b %8b", instr_F[31:24], instr_F[23:16], instr_F[15:8], instr_F[7:0]);
    end

endmodule