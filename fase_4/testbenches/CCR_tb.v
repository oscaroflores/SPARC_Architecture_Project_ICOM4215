`timescale 1ns/1ps

module CCR_Mux_CH_and_CCR_tb;

    // Testbench signals
    reg        CC_EN;
    reg  [3:0] ALU_CC;
    reg  [3:0] CCR_CC;
    reg  [3:0] ICC;
    reg        clock;

    wire [3:0] CC_OUT_mux;
    wire [3:0] CC_OUT_ccr;
    wire       carry_out;

    // Instantiate CCR_Mux_CH
    CCR_Mux_CH uut_mux (
        .CC_EN(CC_EN),
        .ALU_CC(ALU_CC),
        .CCR_CC(CCR_CC),
        .CC_OUT(CC_OUT_mux)
    );

    // Instantiate CCR
    CCR uut_ccr (
        .CC_EN(CC_EN),
        .ICC(ICC),
        .clock(clock),
        .CC_OUT(CC_OUT_ccr),
        .carry_out(carry_out)
    );

    // Clock generator
    initial begin
        clock = 0;
        forever #2 clock = ~clock;
    end

    // Test procedure
    initial begin
        $display("=== Starting CCR_Mux_CH + CCR Testbench ===");

        CC_EN  = 0;
        ALU_CC = 4'b1010;
        CCR_CC = 4'b0101;
        ICC    = 4'b0000;
        #10;

        CC_EN = 1;
        ALU_CC = 4'b1111;
        #10;

        CC_EN = 1;
        ICC = 4'b1001;
        #10;

        CC_EN = 1;
        ICC = 4'b0110;
        #10;

        CC_EN = 0;
        ICC = 4'b0000;
        #10;

        // IMPORTANT: end the simulation
        #100;
        $finish;
    end


    // Display changes
    initial begin
        $display(" ");
        $monitor("t=%3dns | CC_EN=%b | ALU_CC=%b | CCR_CC=%b | ICC=%b | MUX_OUT=%b | CCR_OUT=%b | CARRY=%b",
                 $time, CC_EN, ALU_CC, CCR_CC, ICC, CC_OUT_mux, CC_OUT_ccr, carry_out);
        $display(" ");
    end

endmodule