`timescale 1ns/1ps


module memory_stage_path (
    input  wire [31:0]  alu_result_in,
    input  wire [31:0]  mem_ctrl_in,
    input  wire [4:0]   rd_in,
    input  wire [31:0]  DI,

    output wire [31:0]  data_mux_out,
    output wire [31:0]  mem_ctrl_out,
    output wire [4:0]   rd_out
);

// Señales internas
wire [1:0] Size;
wire       RW;
wire       E;
wire       L;

wire [31:0] data_out;
wire SIGN_EXTEND;
// Señales de control
assign Size = mem_ctrl_in[8:7];
assign RW   = mem_ctrl_in[6];
assign E    = mem_ctrl_in[5];
assign L    = mem_ctrl_in[4];
assign SIGN_EXTEND = mem_ctrl_in[21];

data_memory data_memory_inst (
    .DI   (DI),
    .A    (alu_result_in[8:0]),
    .Size (Size),
    .RW   (RW),
    .E    (E),
    .SIGN_EXT (SIGN_EXTEND),
    .DO   (data_out)
);

assign data_mux_out = (L) ? data_out : alu_result_in;
assign mem_ctrl_out = mem_ctrl_in;
assign rd_out       = rd_in;

endmodule