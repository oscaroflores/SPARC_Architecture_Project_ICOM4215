module CCR_Mux_CH(
    input             CC_EN,
    input      [3:0]  ALU_CC,
    input      [3:0]  CCR_CC,
    output reg [3:0]  CC_OUT
);

always @(*) begin
    if (CC_EN) begin
        CC_OUT = ALU_CC;
    end else begin
        CC_OUT = CCR_CC;
    end
end
endmodule