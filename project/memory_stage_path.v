module memory_stage_path (
    input  wire [31:0]  alu_result_in,
    input  wire [31:0]  mem_ctrl_in,
    input  wire [31:0]  DI,

    output wire [31:0]  data_mux_out
);

// Señales internas
wire [1:0] Size;
wire       RW;
wire       E;
wire       L;

wire [31:0] data_out;

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

TwoToOneMux #(
    .WIDTH(32)
) data_mux (
    .in0(alu_result_in),
    .in1(data_out),
    .sel(L),
    .out(data_mux_out)
);

endmodule