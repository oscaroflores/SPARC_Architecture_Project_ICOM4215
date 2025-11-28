module CCR(
    input            CC_EN,
    input      [3:0] ICC,
    input            clock,
    output reg [3:0] CC_OUT,
    output reg       carry_out
);

always @(posedge clock) begin
    if (CC_EN) begin
        CC_OUT <= ICC;
        carry_out <= ICC[0];
    end
end
endmodule