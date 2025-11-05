`timescale 1ns/1ps

module instruction_memory_tb;

    reg  [8:0]  A;   // 0..511
    wire [31:0] I;

    instruction_memory dut (.A(A), .I(I));

    task rd;
        input [8:0] a;
        begin
            A = a; #1;
            $display("A=%0d I=0x%08h", A, I);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();

        A = 9'd0; #1; // settle

        // Demostración requerida: A = 0, 4, 8, 12
        rd(9'd0);
        rd(9'd4);
        rd(9'd8);
        rd(9'd12);

        #10; $dumpflush; $finish;
    end

endmodule