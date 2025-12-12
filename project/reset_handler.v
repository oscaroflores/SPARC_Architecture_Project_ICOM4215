`timescale 1ns / 1ps

module reset_handler(
    input jmpl_EX,
    input call_ID,
    input BI_ID,
    input J_ID,
    input I_29_ID,
    input global_reset,
    output reg reset_out
);

    always @(*) begin
        if(~J_ID & BI_ID & I_29_ID) begin
            reset_out = 1'b1;
        end else
        if (global_reset) begin
            reset_out = 1'b1;
        end else begin
            reset_out = 1'b0;
        end
    end

endmodule