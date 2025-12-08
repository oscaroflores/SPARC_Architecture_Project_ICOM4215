`timescale 1ns/1ps

module CCR (
    input        CC_EN,
    input  [3:0] ICC,
    input        clock,
    input        rst,      // <-- add
    output reg [3:0] CC_OUT,
    output reg       carry_out
);
    always @(posedge clock or posedge rst) begin
        if (rst) begin
            CC_OUT    <= 4'b0000;
            carry_out <= 1'b0;
            /*
            // DEBUG display
            $display("t=%0t | CCR RESET -> CC_OUT=0000 carry=0", $time);
        end else if (CC_EN) begin
            CC_OUT    <= ICC;
            carry_out <= ICC[0]; 
               // DEBUG display
            $display("t=%0t | CCR UPDATE | ICC=%b (N Z V C) | CC_OUT=%b | carry=%b",
                     $time, ICC, ICC, ICC[0]);
                     */
        end
    end
endmodule