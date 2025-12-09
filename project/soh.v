`timescale 1ns/1ps
module SOH(
    input  [31:0] R,
  	input  [21:0] Imm,
  	input  [3:0]  Is,
    output reg [31:0] N
);

always @(*) begin
  case (Is)
        4'b0000: N = {Imm, 10'b0};
        4'b0001: N = {Imm, 10'b0};
        4'b0010: N = {Imm, 10'b0};
        4'b0011: N = {Imm, 10'b0};
        4'b0100: N = {{10{Imm[21]}}, Imm};
        4'b0101: N = {{10{Imm[21]}}, Imm};
        4'b0110: N = {{10{Imm[21]}}, Imm};
        4'b0111: N = {{10{Imm[21]}}, Imm};
        4'b1000: N = R;
    	4'b1001: N = {{19{Imm[12]}}, Imm[12:0]};
   	4'b1010: N = {27'b0, R[4:0]};
    	4'b1011: N = {27'b0, Imm[4:0]};
        4'b1100: N = R;
    	4'b1101: N = {{19{Imm[12]}}, Imm[12:0]};
        4'b1110: N = R;
    	4'b1111: N = {{19{Imm[12]}}, Imm[12:0]};
        default: N = 32'b0;
    endcase

end

endmodule