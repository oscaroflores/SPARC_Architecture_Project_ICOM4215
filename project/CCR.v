module CCR (
    input        CC_EN,
    input  [3:0] ICC,
    input        clock,
    input        rst,      // <-- add
    output reg [3:0] CC_OUT,
    output reg       carry_out
);
    always @(posedge clock or posedge rst) begin
        if (rst) begin
            CC_OUT    <= 4'b0000;
            carry_out <= 1'b0;
        end else if (CC_EN) begin
            CC_OUT    <= ICC;
            carry_out <= ICC[0]; 
        end
    end
endmodule
