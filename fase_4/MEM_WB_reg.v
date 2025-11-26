module MEM_WB_reg (
    input        clk,
    input        reset,

    // Control that flows from MEM to WB
    input  [31:0] mem_ctrl_in,
    output reg [31:0] wb_ctrl_out,

    // Data that will be written back to the register file (PW)
    input  [31:0] pw_data_in,
    output reg [31:0] pw_data_out,

    // Destination register (e.g., rd_ex_muxed, can be r15 on CALL)
    input  [4:0]  rd_in,
    output reg [4:0]  rd_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_ctrl_out  <= 32'b0;
            pw_data_out  <= 32'b0;
            rd_out       <= 5'b0;
        end else begin
            wb_ctrl_out  <= mem_ctrl_in;
            pw_data_out  <= pw_data_in;
            rd_out       <= rd_in;
        end
    end

endmodule