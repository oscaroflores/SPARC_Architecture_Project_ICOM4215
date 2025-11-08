`timescale 1ns/1ps

module control_unit_tb;

    // Instrucción de entrada a la unidad de control
    reg  [31:0] I;

    // Señales de salida de la CU (ajusta nombres/tamaños a tu módulo real)
    wire [3:0] ALU_OP;
    wire [3:0] SOH_OP;
    wire [1:0] RAM_Size;
    wire       RAM_RW;
    wire       RAM_Enable;
    wire       L;
    wire       RF_LE;
    wire       B;
    wire       CALL;
    wire       JMPL;

    // DUT: ahora instanciamos control_unit directamente
    control_unit dut (
        .I          (I),
        .ALU_OP     (ALU_OP),
        .SOH_OP     (SOH_OP),
        .RAM_Size   (RAM_Size),
        .RAM_RW     (RAM_RW),
        .RAM_Enable (RAM_Enable),
        .L          (L),
        .RF_LE      (RF_LE),
        .B          (B),
        .CALL       (CALL),
        .JMPL       (JMPL)
    );

    // Estímulos
    initial begin
        $dumpfile("control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        // Ejemplo 1: ADD (formato 3, op=10, op3=010000, i=0)
        I = 32'b10_00000_010000_00001_0_0000000000000;  // ajusta campos si quieres algo más real
        #5 $display("ADD:   ALU_OP=%b SOH_OP=%b RAM_Size=%b RW=%b L=%b RF_LE=%b B=%b CALL=%b JMPL=%b",
                     ALU_OP, SOH_OP, RAM_Size, RAM_RW, L, RF_LE, B, CALL, JMPL);

        // Ejemplo 2: ADD immediate (i=1)
        I[13] = 1'b1;
        #5 $display("ADDcc imm: ALU_OP=%b SOH_OP=%b ...", ALU_OP, SOH_OP);

        // Ejemplo 3: LOAD (op=11, op3=000000, i=1)
        I = 32'b11_00000_000000_00001_1_0000000000000;
        #5 $display("LD:    RAM_Size=%b RW=%b L=%b RF_LE=%b", RAM_Size, RAM_RW, L, RF_LE);

        // Ejemplo 4: STORE (op=11, op3=000100, i=1)
        I = 32'b11_00000_000100_00001_1_0000000000000;
        #5 $display("ST:    RAM_Size=%b RW=%b RAM_Enable=%b", RAM_Size, RAM_RW, RAM_Enable);

        // Ejemplo 5: SETHI (op=00, op2=100)
        I = 32'b00_00001_100_00000000000000000000;
        #5 $display("SETHI: ALU_OP=%b SOH_OP=%b RF_LE=%b", ALU_OP, SOH_OP, RF_LE);

        // Ejemplo 6: BRANCH ALWAYS (ba)
        I = 32'b00_0_1000_010_0000000000000000000000;
        #5 $display("BRANCH: B=%b JMPL=%b", B, JMPL);

        #10 $finish;
    end

endmodule