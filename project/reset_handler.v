`timescale 1ns / 1ps

module reset_handler(
    input jumpl,
    input call,
    input J,
    input I_29,
    input global_reset,
    output reg reset_out
);

    always @(*) begin
        if(~J && I_29) begin // Detalle arquitectural 3
            reset_out = 1'b1;
        end else
        if (jumpl || call || J || global_reset) begin
            reset_out = 1'b1;
        end else begin
            reset_out = 1'b0;
        end
    end

endmodule