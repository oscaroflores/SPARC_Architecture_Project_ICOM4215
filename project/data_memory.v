`timescale 1ns/1ps

module data_memory(
    input   [31:0]  DI,
    input   [8:0]   A,
    input   [1:0]   Size,
    input           RW,
    input           E,
    output reg [31:0] DO
);

    reg [7:0] Memory[0:511]; // 256 localizaciones de 8 bits

    always @(*) begin
        DO = 32'b0;
        // read
        if (!RW) begin
            case (Size)
                2'b00: DO = {24'b0, Memory[A]};
                2'b01: DO = {16'b0, Memory[A], Memory[A+1]};
                2'b10: DO = {Memory[A], Memory[A+1], Memory[A+2], Memory[A+3]};
                default: DO = 32'b0;
            endcase
        end
        // write
        else if (RW && E) begin
            case (Size)
                2'b00: begin
                    Memory[A] = DI[7:0];
                end
                2'b01: begin
                    Memory[A] = DI[15:8];
                    Memory[A+1] = DI[7:0];
                end
                2'b10: begin
                    Memory[A] = DI[31:24];
                    Memory[A + 1] = DI[23:16];
                    Memory[A + 2] = DI[15:8];
                    Memory[A + 3] = DI[7:0];
                end
                default: DO = 32'b0;           //----------------------> se debe incluir el txt file aqui ya no esta.
            endcase
        end
    end

endmodule