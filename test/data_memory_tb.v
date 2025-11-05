`timescale 1ns/1ps

module data_memory_tb;

    reg  [31:0] DI;
    reg  [8:0]  A;
    reg  [1:0]  Size;
    reg         RW;
    reg         E;
    wire [31:0] DO;

    data_memory dut (.DI(DI), .A(A), .Size(Size), .RW(RW), .E(E), .DO(DO));

    task rd; input [8:0] a; input [1:0] s; begin
        A=a; Size=s; RW=1'b0; E=1'b0; #1;
        $display("A=%0d DO=0x%08h Size=%b RW=%b E=%b", A, DO, Size, RW, E);
    end endtask

    task wrb; input [8:0] a; input [7:0] v; begin
        A=a; Size=2'b00; DI={24'h0,v}; RW=1'b1; E=1'b1; #1; E=1'b0; RW=1'b0; #1;
    end endtask

    task wrh; input [8:0] a; input [15:0] v; begin
        A=a; Size=2'b01; DI={16'h0,v}; RW=1'b1; E=1'b1; #1; E=1'b0; RW=1'b0; #1;
    end endtask

    task wrw; input [8:0] a; input [31:0] v; begin
        A=a; Size=2'b10; DI=v; RW=1'b1; E=1'b1; #1; E=1'b0; RW=1'b0; #1;
    end endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
        DI=0; A=0; Size=0; RW=0; E=0;

        // Leer word en 0, 4, 8 y 12
        rd(9'd0,  2'b10);
        rd(9'd4,  2'b10);
        rd(9'd8,  2'b10);
        rd(9'd12, 2'b10);

        // Leer byte en 0 y 3; halfword en 4 y 6
        rd(9'd0,  2'b00);
        rd(9'd3,  2'b00);
        rd(9'd4,  2'b01);
        rd(9'd6,  2'b01);

        // Escribir: 0xA6@0, 0xDD@2, 0xABCD@4, 0xEF01@6, 0x33445566@12
        wrb(9'd0,  8'hA6);
        wrb(9'd2,  8'hDD);
        wrh(9'd4,  16'hABCD);
        wrh(9'd6,  16'hEF01);
        wrw(9'd12, 32'h33445566);

        // Leer word en 0, 4 y 12
        rd(9'd0,  2'b10);
        rd(9'd4,  2'b10);
        rd(9'd12, 2'b10);

        #10; $dumpflush; $finish;
    end

endmodule