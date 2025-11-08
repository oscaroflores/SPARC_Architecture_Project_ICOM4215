// =======================================
// PC_reg: registro del Program Counter (PC)
// - Rising edge-triggered
// - Reset sincrónico (inicializa a 0)
// - Load Enable (LE)
// =======================================
module PC_reg (
    input clk,
    input reset,
    input LE,
    input [8:0] D,
    output reg [8:0] Q
);
    always @(posedge clk) begin
        if (reset)
            Q <= 8'd0;
        else if (LE)
            Q <= D;
    end
endmodule