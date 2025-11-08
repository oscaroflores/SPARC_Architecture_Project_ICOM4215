// =======================================
// MEM/WB: registro de señales de control de WB
// - Aquí sólo uso 1 bit (por ejemplo RF_write_enable).
//   Si tienes más, pon [N-1:0].
// =======================================
module reg_mem_wb (input clk, input reset, input wb_ctrl_in, output reg  wb_ctrl_out);
    always @(posedge clk) begin
        if (reset)
            wb_ctrl_out <= 1'b0; // en reset, NOP
        else
            wb_ctrl_out <= wb_ctrl_in;
    end
endmodule