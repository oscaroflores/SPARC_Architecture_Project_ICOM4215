`timescale 1ns / 1ps

module PPU_ControlPath_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg S;
    wire [31:0] PC, nPC, instr_IF, instr_ID;
    wire [3:0]  EX_ctrl;
    wire [1:0]  MEM_ctrl;
    wire        WB_ctrl;

    // Instantiate the DUT (Device Under Test)
    PPU_ControlPath dut (
        .clk(clk),
        .reset(reset),
        .S(S),
        .PC(PC),
        .nPC(nPC),
        .instr_IF(instr_IF),
        .instr_ID(instr_ID),
        .EX_ctrl(EX_ctrl),
        .MEM_ctrl(MEM_ctrl),
        .WB_ctrl(WB_ctrl)
    );

    // Clock generator (10ns period)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("PPU_ControlPath_tb.vcd");
        $dumpvars(0, PPU_ControlPath_tb);

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