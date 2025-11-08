//Registros Pipeline

// =======================================
// IF/ID: registro de instrucción
// - Rising edge-triggered
// - Reset sincrónico
// - Sin load enable (siempre carga)
// =======================================
module IF_ID_reg (
    input        clk,
    input        reset,
    input  [31:0] instr_in,    // instrucción que sale de IF (memoria)
    output reg [31:0] instr_out // instrucción latcheada para ID
);
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
module ID_EX_reg (
    input        clk,
    input        reset,
    input  [3:0] ex_ctrl_in,     // control generado en ID para la etapa EX
    output reg [3:0] ex_ctrl_out // control ya latcheado en la etapa EX
);
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
module EX_MEM_reg (
    input        clk,
    input        reset,
    input  [1:0] mem_ctrl_in,      // control generado en EX para MEM
    output reg [1:0] mem_ctrl_out  // control ya latcheado en la etapa MEM
);
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
module MEM_WB_reg (
    input       clk,
    input       reset,
    input       wb_ctrl_in,     // control generado en MEM para WB
    output reg  wb_ctrl_out     // control ya latcheado en la etapa WB
);
    always @(posedge clk) begin
        if (reset)
            wb_ctrl_out <= 1'b0; // en reset, NOP
        else
            wb_ctrl_out <= wb_ctrl_in;
    end
endmodule

// IF: sale de memoria
wire [31:0] instr_IF;
// ID: entra a la unidad de control
wire [31:0] instr_ID;

// Control saliendo de la CU (en ID)
wire [3:0] ex_ctrl_id;
wire [1:0] mem_ctrl_id;
wire       wb_ctrl_id;

// Control después del mux S (para inyectar NOP)
wire [3:0] ex_ctrl_mux  = S ? 4'b0000 : ex_ctrl_id;
wire [1:0] mem_ctrl_mux = S ? 2'b00   : mem_ctrl_id;
wire       wb_ctrl_mux  = S ? 1'b0    : wb_ctrl_id;

// Control "pipelined" por etapa
wire [3:0] EX_ctrl;
wire [1:0] MEM_ctrl;
wire       WB_ctrl;

// IF/ID
IF_ID_reg IF_ID (
    .clk      (clk),
    .reset    (reset),
    .instr_in (instr_IF),
    .instr_out(instr_ID)
);

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
