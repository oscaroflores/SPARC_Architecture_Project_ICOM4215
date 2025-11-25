`timescale 1ns/1ps
// =======================================
// EX/MEM: registro de señales de control de MEM
// =======================================
module EX_MEM_reg (
    input              clk, 
    input              reset, 
    input       [31:0] ex_ctrl_in, 
    output reg  [31:0] mem_ctrl_out
);

    always @(posedge clk) begin
        if (reset)
            mem_ctrl_out <= 32'b0; // en reset, NOP
        else
            mem_ctrl_out <= ex_ctrl_in;
    end
endmodule