`timescale 1ns/1ps

module sparc_tb_all();

    reg clk;
    reg reset;

    // Instantiate DUT
    sparc_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // ----------------------------
    // Clock: toggle every 2 time units
    // ----------------------------
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end

    // ----------------------------
    // Helper: small task to load memories
    // ----------------------------
    task load_memories;
        input [256*8-1:0] instr_file; // pass string literal
        input [256*8-1:0] data_file;
    begin
        // instruction memory (instruction_memory u_imem inside FETCH)
        $readmemb(instr_file, DUT.FETCH.u_imem.Memory);
        
        // data memory (data_memory data_memory_inst inside MEM)
        $readmemb(data_file, DUT.MEM.data_memory_inst.Memory);
    end
    endtask

    // ------------------------------------------------------------------
    // Phase 1: Validation program
    // - Load validation_program.txt / validation_data.txt
    // - Reset: 1 at t=0, 0 at t=3
    // - Monitor: PC, r5, r6, r16, r17, r18 (decimal)
    // - At t=76: print word at address 56 (bytes 56..59) in binary
    // - End phase at t=80
    // ------------------------------------------------------------------
    initial begin : PHASES
        integer idx;
        reg [256*8-1:0] instr_file;
        reg [256*8-1:0] data_file;

        // -------------------------
        // PHASE 1: Validation
        // -------------------------
        $display("\n--- PHASE 1: Validation program start ---");
        instr_file = "testcode_sparc1.txt";
        data_file = "testcode_sparc2.txt";
        load_memories(instr_file, data_file);

        // initial reset for this phase
        reset = 1;
        #3 reset = 0;

        // Monitor required signals (decimal)
        $display("time\tPC\tr5\tr6\tr16\tr17\tr18");
        // Set monitor for phase1. $monitor will replace previous monitor when called again.
        $monitor("%0t\t%d\t%d\t%d\t%d\t%d\t%d",
            $time,
            DUT.PC_fetch,
            DUT.ID.REG_FILE.r5,
            DUT.ID.REG_FILE.r6,
            DUT.ID.REG_FILE.r16,
            DUT.ID.REG_FILE.r17,
            DUT.ID.REG_FILE.r18
);

        // At t=76 print word in location 56 (bytes 56..59) in binary
        #76; // Wait until time 76
        // Print the 4 bytes (binary)
        $display("\n@%0t Word at memory[56..59] (binary):", $time);
        $display("%b %b %b %b",
            DUT.MEM.data_memory_inst.Memory[56],
            DUT.MEM.data_memory_inst.Memory[57],
            DUT.MEM.data_memory_inst.Memory[58],
            DUT.MEM.data_memory_inst.Memory[59]
        );

        // Wait until t=80 then proceed to next phase
        #4;
        $display("\n--- PHASE 1 complete at time %0t ---\n", $time);

        // -------------------------
        // PHASE 2: Test Program #1
        // - Load test1_program.txt / test1_data.txt
        // - Reset: 1 at current time, go 0 after 3 units
        // - Monitor: PC, memory address seen by MEM stage, r1,r2,r3,r5 (decimal)
        // - At t = 160 (absolute): print word at memory location 44 (binary)
        // - End simulation for this phase at t = 164 (absolute)
        // -------------------------
        $display("\n--- PHASE 2: Test Program #1 start ---");

        // reload memories for test1
        instr_file = "test1_program.txt";
        data_file = "test1_data.txt";
        load_memories(instr_file, data_file);

        // assert reset for this run (reset high now), then low after 3 time units
        reset = 1;
        #3 reset = 0;

        // Replace monitor: show PC, memory address (alu_result_in), r1,r2,r3,r5
        $display("time\tPC\tmem_addr\tr1\tr2\tr3\tr5");
        $monitor("%0t\t%d\t%d\t%d\t%d\t%d\t%d",
            $time,
            DUT.PC_fetch,
            DUT.MEM.alu_result_in,
            DUT.ID.REG_FILE.r1,
            DUT.ID.REG_FILE.r2,
            DUT.ID.REG_FILE.r3,
            DUT.ID.REG_FILE.r5
);


        // Wait until absolute time 160
        #(160 - $time);

        // Print word at memory location 44 (bytes 44..47) in binary
        $display("\n@%0t Word at memory[44..47] (binary):", $time);
        $display("%b %b %b %b",
            DUT.MEM.data_memory_inst.Memory[44],
            DUT.MEM.data_memory_inst.Memory[45],
            DUT.MEM.data_memory_inst.Memory[46],
            DUT.MEM.data_memory_inst.Memory[47]
        );

        // Wait until t=164 to end phase 2
        #4;
        $display("\n--- PHASE 2 complete at time %0t ---\n", $time);

        // -------------------------
        // PHASE 3: Test Program #2
        // - Load test2_program.txt / test2_data.txt
        // - Reset: 1 at current time, go 0 after 3 units
        // - Monitor: PC, memory address, r1,r2,r3,r4,r5,r8,r10,r11,r12,r15 (decimal)
        // - At t = 240 print memory locations 224..263 in binary (bytes, 4 per line)
        // - End simulation at t = 244
        // -------------------------
        $display("\n--- PHASE 3: Test Program #2 start ---");

        instr_file = "test2_program.txt";
        data_file = "test2_data.txt";
        load_memories(instr_file, data_file);

        // reset sequence for phase 3
        reset = 1;
        #3 reset = 0;

        // Replace monitor for phase3
        $display("time\tPC\tmem_addr\tr1\tr2\tr3\tr4\tr5\tr8\tr10\tr11\tr12\tr15");
        $monitor("%0t\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",
            $time,
            DUT.PC_fetch,
            DUT.MEM.alu_result_in,
            DUT.ID.REG_FILE.r1,
            DUT.ID.REG_FILE.r2,
            DUT.ID.REG_FILE.r3,
            DUT.ID.REG_FILE.r4,
            DUT.ID.REG_FILE.r5,
            DUT.ID.REG_FILE.r8,
            DUT.ID.REG_FILE.r10,
            DUT.ID.REG_FILE.r11,
            DUT.ID.REG_FILE.r12,
            DUT.ID.REG_FILE.r15
);

        // Wait until absolute time 240
        #(240 - $time);

        // Print memory 224..263 in binary, bytes separated by spaces, 4 bytes per line
        $display("\n@%0t Memory locations 224..263 (bytes) :", $time);
        for (idx = 224; idx <= 263; idx = idx + 4) begin
            $display("%b %b %b %b",
                DUT.MEM.data_memory_inst.Memory[idx],
                DUT.MEM.data_memory_inst.Memory[idx+1],
                DUT.MEM.data_memory_inst.Memory[idx+2],
                DUT.MEM.data_memory_inst.Memory[idx+3]
            );
        end

        // Wait until t=244 then finish
        #4;
        $display("\n--- PHASE 3 complete at time %0t ---", $time);
        $display("\nAll phases complete. Finishing simulation.\n");
        $finish;
    end

endmodule