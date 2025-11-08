// =======================================
// EX/MEM: registro de señales de control de MEM
// - Ajusta [1:0] si tu bus MEM_ctrl tiene otro ancho
// =======================================
module EX_MEM_reg (input clk, input reset, input [1:0] mem_ctrl_in, output reg [1:0] mem_ctrl_out);
    always @(posedge clk) begin
        if (reset)
            mem_ctrl_out <= 2'b00; // en reset, NOP
        else
            mem_ctrl_out <= mem_ctrl_in;
    end
endmodule