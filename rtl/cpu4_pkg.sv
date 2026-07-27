package cpu4_pkg;
    typedef enum logic [3:0] {
        OP_NOP = 4'h0,
        OP_LDI = 4'h1,
        OP_LDA = 4'h2,
        OP_STA = 4'h3,
        OP_ADD = 4'h4,
        OP_SUB = 4'h5,
        OP_AND = 4'h6,
        OP_OR  = 4'h7,
        OP_XOR = 4'h8,
        OP_JMP = 4'h9,
        OP_OUT = 4'hA,
        OP_INC = 4'hB,
        OP_DEC = 4'hC,
        OP_SHL = 4'hD,
        OP_SHR = 4'hE,
        OP_HLT = 4'hF
    } cpu4_opcode_t;

    typedef enum logic [1:0] {
        STATE_FETCH   = 2'b00,
        STATE_EXECUTE = 2'b01,
        STATE_HALTED  = 2'b10
    } cpu4_state_t;

    typedef enum logic [3:0] {
        ALU_PASS_A = 4'h0,
        ALU_ADD    = 4'h1,
        ALU_SUB    = 4'h2,
        ALU_AND    = 4'h3,
        ALU_OR     = 4'h4,
        ALU_XOR    = 4'h5,
        ALU_INC    = 4'h6,
        ALU_DEC    = 4'h7,
        ALU_SHL    = 4'h8,
        ALU_SHR    = 4'h9
    } cpu4_alu_op_t;
endpackage