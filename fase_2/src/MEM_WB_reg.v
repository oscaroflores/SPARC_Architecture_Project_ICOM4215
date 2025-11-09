`timescale 1ns/1ps
// =======================================
// MEM/WB: registro de señales de control de WB
// =======================================
module MEM_WB_reg (
    input              clk, 
    input              reset, 
    input       [31:0] mem_ctrl_in, 
    output reg  [31:0] wb_ctrl_out
);
    always @(posedge clk) begin
        if (reset)
            wb_ctrl_out <= 32'b0;
        else
            wb_ctrl_out <= mem_ctrl_in;
    end
endmodule