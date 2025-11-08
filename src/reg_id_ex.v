// =======================================
// ID/EX: registro de señales de control de EX
// - Ajusta [3:0] si tu bus EX_ctrl tiene otro ancho
// =======================================
module reg_id_ex (input clk, input reset, input [3:0] ex_ctrl_in, output reg [3:0] ex_ctrl_out);
    always @(posedge clk) begin
        if (reset)
            ex_ctrl_out <= 4'b0000; // en reset, NOP (sin control)
        else
            ex_ctrl_out <= ex_ctrl_in;
    end
endmodule