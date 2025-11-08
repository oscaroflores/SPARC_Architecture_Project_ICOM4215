// =======================================
// ID/EX: registro de señales de control de EX
// =======================================
module ID_EX_reg (
    input clk,
    input reset,
    input [31:0] id_ctrl_in,
    output reg [31:0] ex_ctrl_out
);

    always @(posedge clk) begin
        if (reset)
            ex_ctrl_out <= 32'b0; // en reset, NOP
        else
            ex_ctrl_out <= id_ctrl_in;
    end
endmodule