`timescale 1ns / 1ps
// =======================================
// Testbench para PPU_ControlPath
// =======================================
module PPU_ControlPath_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg S;
    wire [31:0]instr_IF, instr_ID, EX_ctrl, MEM_ctrl, WB_ctrl, control_signals;
    wire [8:0] PC, nPC;

    // Instantiate the DUT (Device Under Test)
    PPU_ControlPath dut (
        .clk(clk),
        .reset(reset),
        .S(S),
        .PC(PC),
        .nPC(nPC),
        .instr_IF(instr_IF),
        .instr_ID(instr_ID),
        .EX_ctrl(EX_ctrl),
        .MEM_ctrl(MEM_ctrl),
        .WB_ctrl(WB_ctrl),
        .control_signals(control_signals)
    );

    // Clock generator: toggles every 2ns for a period of 4ns
    initial begin
        clk = 0;
        forever #2 clk = ~clk;
    end

    // Test sequence according to spec
    initial begin
        $dumpfile("PPU_ControlPath_tb.vcd");
        $dumpvars(0, PPU_ControlPath_tb);

        // Inicialización de señales
        reset = 1;
        S = 0;

        // Reset va a 0 en t=3 ns
        #3 reset = 0;

        // S cambia a 1 en t=40 ns
        #37 S = 1;

        // Finaliza en t=48 ns
        #8;
        $display("=== SIMULACION FINALIZADA ===");
        $finish;
    end

    // Variables para decodificación de instrucciones
    reg [7:0] opcode;
    reg [2:0]  opcode2;
    reg [5:0]  opcode3;
    reg [3:0] cond;
    reg [31:0] instr_word;

    // Cada rising edge del clk, decodificar y mostrar información
    always @(posedge clk) begin
        instr_word = instr_ID;
        opcode = instr_word[31:30];
        opcode3 = instr_word[24:19];
        opcode2 = instr_word[24:22];
        cond = instr_word[28:25];
        $display("------------------------------------------------");
        $write("t=%0t ns | ", $time);
        // Handle NOP instruction
        if(instr_word == 32'b0) begin
            $write("Instr=NOP ");
        end else begin
            case (opcode)
                2'b00: begin 
                    case (opcode2)
                        3'b100: begin $write("Instr=SETHI "); end
                        default: begin
                            case (cond)
                                4'b1000: $write("Instr=BA ");
                                4'b0000: $write("Instr=BN ");
                                4'b1001: $write("Instr=BNE ");
                                4'b0001: $write("Instr=BE ");
                                4'b1010: $write("Instr=BG ");
                                4'b0010: $write("Instr=BLE ");
                                4'b1011: $write("Instr=BGE ");
                                4'b0011: $write("Instr=BL ");
                                4'b1100: $write("Instr=BGU ");
                                4'b0100: $write("Instr=BLEU ");
                                4'b1101: $write("Instr=BCC ");
                                4'b0101: $write("Instr=BCS ");
                                4'b1110: $write("Instr=BPOS ");
                                4'b0110: $write("Instr=BNEG "); 
                                4'b1111: $write("Instr=BVC ");
                                4'b0111: $write("Instr=BVS ");
                                default:   $write("Instr=UNKNOWN COND ");
                            endcase
                        end
                    endcase
                end
                
                2'b01: $write("Instr=CALL ");

                2'b10: begin
                    case (opcode3)
                        // Basic Arithmetic Instructions
                        6'b000000: $write("Instr=ADD ");
                        6'b010000: $write("Instr=ADDCC ");
                        6'b001000: $write("Instr=ADDX ");
                        6'b011000: $write("Instr=ADDXCC ");
                        6'b000100: $write("Instr=SUB ");
                        6'b010100: $write("Instr=SUBCC ");
                        6'b001100: $write("Instr=SUBX ");
                        6'b011100: $write("Instr=SUBXCC ");

                        // Tagged Arithmetic Instructions
                        6'b100000: $write("Instr=TADDCC ");
                        6'b100010: $write("Instr=TADDCCTV ");
                        6'b100001: $write("Instr=TSUBCC ");
                        6'b100011: $write("Instr=TSUBCCTV ");

                        // Other Arithmetic Instructions
                        6'b100101: $write("Instr=MULSCC ");
                        6'b001010: $write("Instr=UMUL ");
                        6'b011010: $write("Instr=UMULCC ");
                        6'b001001: $write("Instr=SMUL ");
                        6'b011001: $write("Instr=SMULCC ");
                        6'b001110: $write("Instr=UDIV ");
                        6'b011110: $write("Instr=UDIVCC ");
                        6'b001111: $write("Instr=SDIV ");
                        6'b011111: $write("Instr=SDIVCC ");

                        // Logical Instructions
                        6'b000001: $write("Instr=AND ");
                        6'b010001: $write("Instr=ANDCC ");
                        6'b000101: $write("Instr=ANDN ");
                        6'b010101: $write("Instr=ANDNCC ");
                        6'b000010: $write("Instr=OR ");
                        6'b010010: $write("Instr=ORCC ");
                        6'b000110: $write("Instr=ORN ");
                        6'b010110: $write("Instr=ORNCC ");
                        6'b000011: $write("Instr=XOR ");
                        6'b010011: $write("Instr=XORCC ");
                        6'b000111: $write("Instr=XNOR ");
                        6'b010111: $write("Instr=XNORCC ");

                        // Shift Instructions
                        6'b100101: $write("Instr=SLL ");
                        6'b100110: $write("Instr=SRL ");
                        6'b100111: $write("Instr=SRA ");

                        // Save and Restore Instruction Format
                        6'b111100: $write("Instr=SAVE ");
                        6'b111101: $write("Instr=RESTORE ");

                        // jumpl Instruction
                        6'b111000: $write("Instr=JMPL ");

                        // Trap on Integer Condition Codes
                        6'b111010: $write("Instr=TRAP "); // These expand even more, slide 54 of CA SPARC Architecture
                        
                        // Return from Trap Instruction - RETT
                        6'b111001: $write("Instr=RETT ");

                        // Read State Register Instructions
                        6'b101001: $write("Instr=RDPSR ");
                        6'b101010: $write("Instr=RDWIM ");
                        6'b101011: $write("Instr=RDTBR ");

                        // Write State Register Instructions
                        6'b110001: $write("Instr=WRPSR ");
                        6'b110010: $write("Instr=WRWIM ");
                        6'b110011: $write("Instr=WRTBR ");

                        default:   $write("Instr=UNKNOWN (op3=%b)", opcode3);
                    endcase
                end

                2'b11: begin
                    case (opcode3)
                        6'b001001: $write("Instr=LSB ");
                        6'b001010: $write("Instr=LDSH ");
                        6'b000000: $write("Instr=LD ");
                        6'b000001: $write("Instr=LDUB ");
                        6'b000010: $write("Instr=LDUH ");
                        6'b000011: $write("Instr=LDD ");
                        6'b000101: $write("Instr=STB ");
                        6'b000110: $write("Instr=STH ");
                        6'b000100: $write("Instr=ST ");
                        6'b000111: $write("Instr=STD ");
                        6'b001101: $write("Instr=LDSTUB ");
                        6'b001111: $write("Instr=SWAP ");
                        default:   $write("Instr=LOAD/STORE OTHER ");
                    endcase
                end

                default: $write("Instr=UNKNOWN OP ");
            endcase
        end

        // Mostrar NPC y PC
        $display("| PC=%0d | nPC=%0d", PC, nPC);
        $display(" ");
        // Mostrar señales de control
        $display("Control Signals=%b", control_signals);
        // $display("control_signals=%b", control_signals);
        $display("ALU_OP=%b", control_signals[16:13]);
        $display("SOH_OP=%b", control_signals[12:9]);
        $display("RAM_Size=%b", control_signals[8:7]);
        $display("RAM_RW=%b", control_signals[6]);
        $display("RAM_Enable=%b", control_signals[5]);
        $display("L=%b", control_signals[4]);
        $display("RF_LE=%b", control_signals[3]);
        $display("call=%b", control_signals[2]);
        $display("jmpl=%b", control_signals[1]);
        $display("B=%b", control_signals[0]);
        $display("CC=%b", control_signals[17]);
        $display("ID_SR=%b", control_signals[18]);
        $display(" ");

        // Mostrar señales de control de la etapa EX, MEM y WB
        $display("EX_ctrl=%b", EX_ctrl);
        $display("ALU_OP=%b", EX_ctrl[16:13]);
        $display("SOH_OP=%b", EX_ctrl[12:9]);
        $display("L=%b", EX_ctrl[4]);
        $display("call=%b", EX_ctrl[2]);
        $display("jmpl=%b", EX_ctrl[1]);
        $display("CC=%b", EX_ctrl[17]);
        $display(" ");
        /////////////////////////////////////////////////
        $display("MEM_ctrl=%b", MEM_ctrl);
        $display("RAM_Size=%b", MEM_ctrl[8:7]);
        $display("RAM_RW=%b", MEM_ctrl[6]);
        $display("RAM_Enable=%b", MEM_ctrl[5]);
        $display("L=%b", MEM_ctrl[4]);
        $display("RF_LE=%b", MEM_ctrl[3]);
        $display(" ");;
        /////////////////////////////////////////////////
        $display("WB_ctrl=%b", WB_ctrl);
        $display("RF_LE=%b", WB_ctrl[3]);
        $display("------------------------------------------------");
    end
endmodule