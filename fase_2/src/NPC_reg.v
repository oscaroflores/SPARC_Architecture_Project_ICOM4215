// =======================================
// NPC_reg: registro del Next Program Counter (NPC)
// - Rising edge-triggered
// - Reset sincrónico (inicializa a 4)
// - Load Enable (LE)
// =======================================
module NPC_reg (
    input clk,
    input reset,
    input LE,
    input [8:0] D,
    output reg [8:0] Q
);
    always @(posedge clk) begin
        if (reset)
            Q <= 8'd4;
        else if (LE)
            Q <= D;
    end
endmodule