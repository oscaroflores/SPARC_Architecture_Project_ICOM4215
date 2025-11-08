// Implementacion del PC y nPC ////////////////////////////////////////////////////////////////////////////////////////////PC y nPC
`timescale 1ns/1ps

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////instruction memory



module instruction_memory(input [8:0] A, output reg [31:0] I);

    reg [7:0] Memory [0:511];

    always @(*) begin
        I = {Memory[A], Memory[A+1], Memory[A+2], Memory[A+3]};
    end

    initial begin
        $readmemb("precharge.txt", Memory); //verificar si esto sirve con el txt file ese
    end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////MUX
// =======================================
// Mux de control para la Unidad de Control
// - Si S = 0: pasan las señales originales de la CU
// - Si S = 1: se inyecta un NOP (todo ceros)
// =======================================

module CU_Mux_Control (input S,
    // Entradas desde el Control Unit (en etapa ID)
    input [3:0] ex_ctrl_in,
    input [1:0] mem_ctrl_in,
    input wb_ctrl_in,
    // Salidas hacia los registros de pipeline 
    output [3:0] ex_ctrl_out,
    output [1:0] mem_ctrl_out,
    output wb_ctrl_out
);
    // logica del mux
    assign ex_ctrl_out  = (S) ? 4'b0000 : ex_ctrl_in;
    assign mem_ctrl_out = (S) ? 2'b00   : mem_ctrl_in;
    assign wb_ctrl_out  = (S) ? 1'b0    : wb_ctrl_in;
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////Pipeline Reg
//Registros Pipeline

// =======================================
// IF/ID: registro de instrucción
// - Rising edge-triggered
// - Reset sincrónico
// - Sin load enable (siempre carga)
// =======================================
module IF_ID_reg (input clk, input reset, input [31:0] instr_in, output reg [31:0] instr_out);
    always @(posedge clk) begin
        if (reset)
            instr_out <= 32'd0;    // en reset, NOP (instrucción = 0)
        else
            instr_out <= instr_in; // siempre carga en cada ciclo
    end
endmodule

// =======================================
// ID/EX: registro de señales de control de EX
// - Ajusta [3:0] si tu bus EX_ctrl tiene otro ancho
// =======================================
module ID_EX_reg (input clk, input reset, input [3:0] ex_ctrl_in, output reg [3:0] ex_ctrl_out);
    always @(posedge clk) begin
        if (reset)
            ex_ctrl_out <= 4'b0000; // en reset, NOP (sin control)
        else
            ex_ctrl_out <= ex_ctrl_in;
    end
endmodule

// =======================================
// EX/MEM: registro de señales de control de MEM
// - Ajusta [1:0] si tu bus MEM_ctrl tiene otro ancho
// =======================================
module EX_MEM_reg (input clk, input reset, input [1:0] mem_ctrl_in, output reg [1:0] mem_ctrl_out);
    always @(posedge clk) begin
        if (reset)
            mem_ctrl_out <= 2'b00; // en reset, NOP
        else
            mem_ctrl_out <= mem_ctrl_in;
    end
endmodule

// =======================================
// MEM/WB: registro de señales de control de WB
// - Aquí sólo uso 1 bit (por ejemplo RF_write_enable).
//   Si tienes más, pon [N-1:0].
// =======================================
module MEM_WB_reg (input clk, input reset, input wb_ctrl_in, output reg  wb_ctrl_out);
    always @(posedge clk) begin
        if (reset)
            wb_ctrl_out <= 1'b0; // en reset, NOP
        else
            wb_ctrl_out <= wb_ctrl_in;
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////////Control Unit



// =====================================================
// Control Unit
// - Mapea la instrucción I a:
//   ALU_OP   (4 bits)   → lo usaremos como EX_ctrl
//   RAM_Size (2 bits)   → lo usaremos como MEM_ctrl
//   RAM_RW, RAM_Enable, L, RF_LE (no todos se pipelinean ahora)
// =====================================================
module control_unit(
    input  [31:0] I,
    output reg [3:0] ALU_OP,
    output reg [1:0] RAM_Size,
    output reg       RAM_RW,
    output reg       RAM_Enable,
    output reg       L,
    output reg       RF_LE
);
    wire [1:0] op   = I[31:30];
    wire [2:0] op2  = I[24:22];   // format 2
    wire [5:0] op3  = I[24:19];   // format 3

    always @(*) begin
        // valores por defecto (NOP)
        ALU_OP     = 4'b0000;
        RAM_Size   = 2'b00;
        RAM_RW     = 1'b0;
        RAM_Enable = 1'b0;
        L          = 1'b0;
        RF_LE      = 1'b0;

        case (op)
            2'b01: begin
                // Format 1 → CALL
                // Aquí podrías marcar alguna señal de control específica.
                // Para esta fase, lo dejamos en default.
            end

            2'b00: begin
                // Format 2 (BRANCH / SETHI)
                case (op2)
                    3'b010: begin
                        // BRANCH (bne, etc.) → tu lógica de branch iría aquí
                        // En esta fase solo nos importa que se ve distinto de NOP
                        ALU_OP = 4'b1110; // código arbitrario para "BR"
                    end

                    3'b100: begin
                        // SETHI
                        ALU_OP = 4'b1111; // código arbitrario para "SETHI"
                        RF_LE  = 1'b1;    // escribe registro destino
                    end

                    default: begin
                        // otras op2 de formato 2
                    end
                endcase
            end

            2'b10: begin
                // Format 3; aritmético / lógico / shifts
                case (op3)
                    // arith
                    6'b010000: ALU_OP = 4'b0000; // addcc
                    6'b011000: ALU_OP = 4'b0001; // addxcc
                    6'b010100: ALU_OP = 4'b0010; // subcc
                    6'b011100: ALU_OP = 4'b0011; // subxcc

                    // logic
                    6'b010001: ALU_OP = 4'b0100; // andcc
                    6'b010010: ALU_OP = 4'b0101; // orcc
                    6'b010011: ALU_OP = 4'b0110; // xorcc
                    6'b010111: ALU_OP = 4'b0111; // xnorcc
                    6'b010101: ALU_OP = 4'b1000; // andncc
                    6'b010110: ALU_OP = 4'b1001; // orncc

                    // shifts
                    6'b100101: ALU_OP = 4'b1010; // sll
                    6'b100110: ALU_OP = 4'b1011; // srl
                    6'b100111: ALU_OP = 4'b1100; // sra

                    default: ; // otras op3
                endcase
            end

            2'b11: begin
                // Format 3; load/store
                case (op3)
                    // LOADS (ponemos RAM_Enable y RF_LE)
                    6'b001001: begin // lsb / ldsb
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b001010: begin // ldsh
                        RAM_Size   = 2'b01;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b000000: begin // ld
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b000001: begin // ldub
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b000010: begin // lduh
                        RAM_Size   = 2'b01;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end
                    6'b000011: begin // ldd
                        RAM_Size   = 2'b11;
                        RAM_RW     = 1'b0;
                        RAM_Enable = 1'b1;
                        L          = 1'b1;
                        RF_LE      = 1'b1;
                    end

                    // STORES (no RF_LE, RAM_RW=1)
                    6'b000101: begin // stb
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000110: begin // sth
                        RAM_Size   = 2'b01;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000100: begin // st
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b000111: begin // std
                        RAM_Size   = 2'b11;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b001101: begin // ldstub (simplificado)
                        RAM_Size   = 2'b00;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end
                    6'b001111: begin // swap (simplificado)
                        RAM_Size   = 2'b10;
                        RAM_RW     = 1'b1;
                        RAM_Enable = 1'b1;
                    end

                    default: ; // otros op3
                endcase
            end

            default: ; // op = 2'b?? no usado
        endcase
    end
endmodule

/////////////////////////////////////////////////////////////////////////////////////////Control path
// TOP: PPU_ControlPath
// - Conecta PC, nPC, Instruction Memory, IF/ID, Control Unit,
//   MUX de control y pipeline de señales EX/MEM/WB.

module PPU_ControlPath (
    input        clk,
    input        reset,
    input        S,               // selección del MUX de control

    // Salidas para debugging / testbench
    output [31:0] PC,
    output [31:0] nPC,
    output [31:0] instr_IF,
    output [31:0] instr_ID,
    output [3:0]  EX_ctrl,
    output [1:0]  MEM_ctrl,
    output        WB_ctrl
);

    // ---------------- PC y nPC ----------------
    wire [31:0] pc_actual, npc_actual;
    wire [31:0] pc_next, npc_next, npc_plus_4;

    assign PC  = pc_actual;
    assign nPC = npc_actual;

    // nPC_next = nPC_actual + 4; PC_next = nPC_actual
    assign npc_plus_4 = npc_actual + 32'd4;
    assign pc_next    = npc_actual;
    assign npc_next   = npc_plus_4;

    // Load enable (siempre 1 por ahora)
    wire LE_PC  = 1'b1;
    wire LE_nPC = 1'b1;

    // Instancia de PC
    PC_reg PC0 (
        .clk   (clk),
        .reset (reset),
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

    // ---------------- Instruction Memory ----------------
    instruction_memory IMEM (
        .A(pc_actual[8:0]),   // dirección en bytes: PC[8:0]
        .I(instr_IF)
    );

    // ---------------- IF/ID: instrucción hacia la CU ----------------
    IF_ID_reg IF_ID (
        .clk      (clk),
        .reset    (reset),
        .instr_in (instr_IF),
        .instr_out(instr_ID)
    );

    // ---------------- Control Unit (en etapa ID) ----------------
    wire [3:0] ALU_OP;
    wire [1:0] RAM_Size;
    wire       RAM_RW, RAM_Enable, L, RF_LE;

    control_unit CU (
        .I         (instr_ID),
        .ALU_OP    (ALU_OP),
        .RAM_Size  (RAM_Size),
        .RAM_RW    (RAM_RW),
        .RAM_Enable(RAM_Enable),
        .L         (L),
        .RF_LE     (RF_LE)
    );

    // Para esta fase, mapeamos:
    //  - EX_ctrl_id  = ALU_OP (4 bits)
    //  - MEM_ctrl_id = RAM_Size (2 bits)
    //  - WB_ctrl_id  = RF_LE (1 bit)
    wire [3:0] ex_ctrl_id  = ALU_OP;
    wire [1:0] mem_ctrl_id = RAM_Size;
    wire       wb_ctrl_id  = RF_LE;

    // ---------------- Mux de control de la CU ----------------
    wire [3:0] ex_ctrl_mux;
    wire [1:0] mem_ctrl_mux;
    wire       wb_ctrl_mux;

    CU_Mux_Control CU_MUX (
        .S           (S),
        .ex_ctrl_in  (ex_ctrl_id),
        .mem_ctrl_in (mem_ctrl_id),
        .wb_ctrl_in  (wb_ctrl_id),
        .ex_ctrl_out (ex_ctrl_mux),
        .mem_ctrl_out(mem_ctrl_mux),
        .wb_ctrl_out (wb_ctrl_mux)
    );

    // ---------------- Registros de pipeline de control ----------------
    // ID/EX
    ID_EX_reg ID_EX (
        .clk        (clk),
        .reset      (reset),
        .ex_ctrl_in (ex_ctrl_mux),
        .ex_ctrl_out(EX_ctrl)
    );

    // EX/MEM
    EX_MEM_reg EX_MEM (
        .clk         (clk),
        .reset       (reset),
        .mem_ctrl_in (mem_ctrl_mux),
        .mem_ctrl_out(MEM_ctrl)
    );

    // MEM/WB
    MEM_WB_reg MEM_WB (
        .clk        (clk),
        .reset      (reset),
        .wb_ctrl_in (wb_ctrl_mux),
        .wb_ctrl_out(WB_ctrl)
    );

endmodule