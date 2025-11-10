`timescale 1ns / 1ps

module control_unit(
    input  [31:0] I,
    output reg [31:0] control_signals
);

    // OPcodes, condtion para branch y bit 13
    wire [1:0] op    = I[31:30];    
    wire [3:0] cond  = I[28:25];    
    wire [2:0] op2   = I[24:22];    
    wire [5:0] op3   = I[24:19];    
    wire       i_bit = I[13];       

    wire is_nop   = (I == 32'b0);  //verificamos que no sea NOP primero

    wire is_add   = (op == 2'b10) && (op3 == 6'b000000);  
    wire is_subcc = (op == 2'b10) && (op3 == 6'b010100);  
    wire is_addcc = (op == 2'b10) && (op3 == 6'b010000);  
    wire is_subx  = (op == 2'b10) && (op3 == 6'b001100);  

    // Format 3 load y store
    wire is_ldub  = (op == 2'b11) && (op3 == 6'b000001);  
    wire is_stb   = (op == 2'b11) && (op3 == 6'b000101);  

    // Format 2 SETHI y branch
    wire is_sethi = (op == 2'b00) && (op2 == 3'b100);     
    wire is_bne   = (op == 2'b00) && (op2 == 3'b010) && (cond == 4'b1001); 

    // Call y jmpl
    wire is_call  = (op == 2'b01);                        
    wire is_jmpl  = (op == 2'b10) && (op3 == 6'b111000);  

   
    reg [3:0] ALU_OP;
    reg [3:0] SOH_OP;
    reg [1:0] RAM_Size;     
    reg       RAM_RW;
    reg       RAM_Enable;    
    reg       L;        
    reg       RF_LE;    
    reg       CALL;     
    reg       JMPL;     
    reg       B;        
    reg       CC;      
    reg       ID_SR;    


    always @(*) begin
        
        ALU_OP = 4'b0000;
        SOH_OP = {I[31], I[30], I[24], I[13]};

        RAM_Size   = 2'b01;  
        RAM_RW     = 1'b1;   
        L      = 1'b0;
        RF_LE  = 1'b0;
        CALL   = 1'b0;
        JMPL   = 1'b0;
        B      = 1'b0;
        CC    = 1'b0;
        ID_SR  = 1'b0;

        if (!is_nop) begin
           // Register File write enable
            RF_LE = (is_add | is_subcc | is_addcc | is_sethi | is_ldub);

            L = is_stb;

            //read/write
            RAM_RW = (is_ldub | is_stb) ? 1'b1 : 1'b0; 

            //Flag de branch y jmpl/call
            B    = is_bne;
            JMPL = is_jmpl;
            CALL = is_call;

            // Condition codes 
            CC  = (is_subcc | is_addcc);

            RAM_Size = (is_ldub | is_stb) ? 2'b00 : 2'b01;

            // Operacion del ALU
            if (is_add) ALU_OP = 4'b0000;  
            else if (is_subcc) ALU_OP = 4'b0011;  
            else if (is_addcc) ALU_OP = 4'b0100;  
            else if (is_subx) ALU_OP = 4'b0011;  
        end

        RAM_Enable = (is_ldub | is_stb);
        
        // metemos todas las señales en un bus llamado control_signals
        control_signals = 32'b0;
        control_signals[18]    = ID_SR;
        control_signals[17]    = CC;
        control_signals[16:13] = ALU_OP;
        control_signals[12:9]  = SOH_OP;
        control_signals[8:7]   = RAM_Size;
        control_signals[6]     = RAM_RW;
        control_signals[5]     = RAM_Enable;
        control_signals[4]     = L;
        control_signals[3]     = RF_LE;
        control_signals[2]     = CALL;
        control_signals[1]     = JMPL;
        control_signals[0]     = B;
    end

endmodule