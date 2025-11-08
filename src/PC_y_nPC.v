// Implementacion del PC y nPC

//wires 32 bits 
wire [31:0] pc_actual, npc_actual;
wire [31:0] pc_next, npc_next, npc_plus_4;

assign PC  = pc_actual;
assign nPC = npc_actual;

assign npc_plus_4 = npc_actual + 32'd4; //se le suman 4 a nPC
assign pc_next = npc_actual;          //PC coje el valor de nPC 
assign npc_next = npc_plus_4;          //nPC coje el valor de nPC+4

// PC con reset a 0
module PC_reg (input clk, input reset, input LE, input [31:0] D, output reg [31:0] Q);
    always @(posedge clk) begin
        if (reset)
            Q <= 32'd0;       
        else if (LE)
            Q <= D;           
    end
endmodule

//nPC con reset a 4
module NPC_reg (input clk, input reset, input LE, input [31:0] D, output reg [31:0] Q);
    always @(posedge clk) begin
        if (reset)
            Q <= 32'd4;       // nPC = 4 en reset
        else if (LE)
            Q <= D;           
    end
endmodule

// Señales de load enable
wire LE_PC  = 1'b1;
wire LE_nPC = 1'b1;

// Instancia de PC
PC_reg PC0 (
    .clk   (clk),       // 
    .reset (reset),     // 
    .LE    (LE_PC),
    .D     (pc_next),
    .Q     (pc_actual)
);

// Instancia de nPC
NPC_reg NPC0 (
    .clk   (clk),
    .reset (reset),
    .LE    (LE_nPC),
    .D     (npc_next),
    .Q     (npc_actual)
);