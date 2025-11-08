module NPC_reg (
    input clk,
    input reset,
    input LE,
    input [31:0] D,
    output reg [31:0] Q
);
    always @(posedge clk) begin
        if (reset)
            Q <= 32'd4;
        else if (LE)
            Q <= D;
    end
endmodule