`timescale 1ns/1ps
// =======================================
// Generic 4-to-1 forwarding mux
//  - WIDTH can be 32 (normal data) or 9 (TAG-style paths)
//  - sel = 00 -> in0 (RegFile PA/PB/PD)
//  - sel = 01 -> in1 (ALU result, EX stage)
//  - sel = 10 -> in2 (MEM stage value)
//  - sel = 11 -> in3 (WB stage value)
// =======================================
module FourToOneMux #(
    parameter WIDTH = 32
) (
    input  [WIDTH-1:0] in0,   // from 3-port register file (PA / PB / PD)
    input  [WIDTH-1:0] in1,   // from ALU output (EX stage)
    input  [WIDTH-1:0] in2,   // from MEM stage (EX/MEM or MEM result)
    input  [WIDTH-1:0] in3,   // from WB stage (MEM/WB)
    input  [1:0]       sel,   // forwarding select
    output [WIDTH-1:0] out
);

    assign out =
        (sel == 2'b00) ? in0 :
        (sel == 2'b01) ? in1 :
        (sel == 2'b10) ? in2 :
                         in3;   // sel == 2'b11

endmodule