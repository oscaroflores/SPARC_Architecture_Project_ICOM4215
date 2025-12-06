module CH(
    input        BI,
    input  [3:0] cond,
    input  [3:0] ACC,
    output reg   J
);

    reg N, Z, V, C;

always @(*) begin

    if (BI == 1) begin
        N = ACC[3];
        Z = ACC[2];
        V = ACC[1];
        C = ACC[0];

        case (cond)
            4'b0000: J = 1'b0;               // BN
            4'b0001: J = Z;                  // BEQ
            4'b0010: J = Z | (N ^ V);        // BLE
            4'b0011: J = (N ^ V);            // BL
            4'b0100: J = C | Z;              // BLEU
            4'b0101: J = C;                  // BCS
            4'b0110: J = N;                  // BNEG
            4'b0111: J = V;                  // BVS
            4'b1000: J = 1'b1;               // BA
            4'b1001: J = ~Z;                 // BNE
            4'b1010: J = ~(Z | (N ^ V));     // BGT
            4'b1011: J = ~(N ^ V);           // BGE
            4'b1100: J = ~(C | Z);           // BGU
            4'b1101: J = ~C;                 // BCC
            4'b1110: J = ~N;                 // BPOS
            4'b1111: J = ~V;                 // BVC
            default: J = 1'b0;
        endcase

    end else begin
        J = 1'b0;
    end

end

endmodule