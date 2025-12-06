`timescale 1ns/1ps

module DHDU_tb;

    // Inputs
    reg        EX_L;
    reg [2:0]  SR;
    reg [4:0]  RA, RB, RD;
    reg [4:0]  EX_RD, MEM_RD, WB_RD;
    reg        EX_RF_LE, MEM_RF_LE, WB_RF_LE;

    // Outputs
    wire [1:0] A_S;
    wire [1:0] B_S;
    wire [1:0] D_S;
    wire       NOP;
    wire       LE;

    // Instantiate DUT
    DHDU dut (
        .EX_L(EX_L),
        .SR(SR),
        .RA(RA),
        .RB(RB),
        .RD(RD),
        .EX_RD(EX_RD),
        .MEM_RD(MEM_RD),
        .WB_RD(WB_RD),
        .EX_RF_LE(EX_RF_LE),
        .MEM_RF_LE(MEM_RF_LE),
        .WB_RF_LE(WB_RF_LE),
        .A_S(A_S),
        .B_S(B_S),
        .D_S(D_S),
        .NOP(NOP),
        .LE(LE)
    );

    // Nice formatted output
    task print_status;
    begin
        $display(" t=%0t | EX_L=%b SR=%b | RA=%d RB=%d RD=%d | EX_RD=%d MEM_RD=%d WB_RD=%d",
                  $time, EX_L, SR, RA, RB, RD, EX_RD, MEM_RD, WB_RD);
        $display("        LE=%b NOP=%b | A_S=%b B_S=%b D_S=%b\n",
                  LE, NOP, A_S, B_S, D_S);
    end
    endtask

    initial begin
        $dumpfile("dhdu.vcd");
        $dumpvars(0, DHDU_tb);

        // Default values (NO CHAINED ASSIGNMENTS)
        EX_L = 0;
        SR   = 3'b111;

        RA = 0;
        RB = 0;
        RD = 0;

        EX_RD  = 0;
        MEM_RD = 0;
        WB_RD  = 0;

        EX_RF_LE  = 0;
        MEM_RF_LE = 0;
        WB_RF_LE  = 0;

        #10;
        $display("===== Test 1: No Hazards =====");
        RA = 5; RB = 6; RD = 7;
        EX_RD = 10; MEM_RD = 11; WB_RD = 12;
        #1 print_status();

        #10;
        $display("===== Test 2: LOAD USE Hazard =====");
        EX_L = 1;
        EX_RD = 5;
        RA = 5;
        #1 print_status();

        #10;
        $display("===== Test 3: EX Forwarding (A_S=01) =====");
        EX_L = 0;
        EX_RF_LE = 1;
        RA = 8;
        EX_RD = 8;
        #1 print_status();

        #10;
        $display("===== Test 4: MEM Forwarding (A_S=10) =====");
        EX_RF_LE = 0;
        MEM_RF_LE = 1;
        RA = 9;
        MEM_RD = 9;
        #1 print_status();

        #10;
        $display("===== Test 5: WB Forwarding (A_S=11) =====");
        MEM_RF_LE = 0;
        WB_RF_LE = 1;
        RA = 3;
        WB_RD = 3;
        #1 print_status();

        #10;
        $display("===== Test 6: Store Data Forwarding (D_S) =====");
        WB_RF_LE = 0;
        MEM_RF_LE = 1;
        RD = 20;
        MEM_RD = 20;
        #1 print_status();

        #10;
        $display("===== End of Simulation =====");
        $finish;
    end

endmodule
