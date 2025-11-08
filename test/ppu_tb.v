`timescale 1ns / 1ps

module ppu_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg S;
    wire [31:0] PC, nPC, instr_IF, instr_ID;
    wire [3:0]  EX_ctrl;
    wire [1:0]  MEM_ctrl;
    wire        WB_ctrl;
    wire        CALL;
    wire        JMPL;
    wire        B;
    wire [3:0]  SOH_OP;

    // Instantiate the DUT (Device Under Test)
    ppu dut (
        .clk(clk),
        .reset(reset),
        .S(S),
        .PC(PC),
        .nPC(nPC),
        .instr_IF(instr_IF),
        .instr_ID(instr_ID),
        .EX_ctrl(EX_ctrl),
        .MEM_ctrl(MEM_ctrl),
        .WB_ctrl(WB_ctrl),
        .CALL(CALL),
        .JMPL(JMPL),
        .B(B),
        .SOH_OP(SOH_OP)
    );

    // Clock generator (10ns period)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("ppu_tb.vcd");
        $dumpvars(0, ppu_tb.v);

        clk = 0;
        reset = 1;
        S = 0;

        #10;  // hold reset
        reset = 0;

        // Let the system run for a few cycles
        repeat (10) @(posedge clk);

        // Toggle S to test the MUX behavior
        S = 1;
        repeat (5) @(posedge clk);
        S = 0;

        $display("Simulation complete. PC=%d, nPC=%d", PC, nPC);
        $finish;
    end
endmodule