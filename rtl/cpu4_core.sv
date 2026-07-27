module cpu4_core #(
    parameter string PROGRAM_FILE = "demo_cpu4.mem"
) (
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,

    output logic [3:0] output_port,
    output logic       halted,

    output logic [3:0] debug_pc,
    output logic [3:0] debug_accumulator,
    output logic [7:0] debug_instruction,
    output logic [1:0] debug_state,
    output logic       debug_alu_carry,
    output logic       debug_alu_zero
);
    import cpu4_pkg::*;

    logic [3:0] program_counter;
    logic [7:0] instruction_register;
    logic [3:0] accumulator;
    cpu4_state_t state;

    logic [7:0] rom_instruction;
    cpu4_opcode_t opcode;
    logic [3:0] operand;

    logic       ram_write_enable;
    logic [3:0] ram_read_data;

    cpu4_alu_op_t alu_operation;
    logic [3:0]   alu_result;
    logic         alu_carry;
    logic         alu_zero;

    cpu4_program_rom #(
        .PROGRAM_FILE(PROGRAM_FILE)
    ) u_program_rom (
        .address     (program_counter),
        .instruction (rom_instruction)
    );

    cpu4_data_ram u_data_ram (
        .clk          (clk),
        .write_enable (ram_write_enable),
        .address      (operand),
        .write_data   (accumulator),
        .read_data    (ram_read_data)
    );

    assign opcode  = cpu4_opcode_t'(instruction_register[7:4]);
    assign operand = instruction_register[3:0];

    always_comb begin
        alu_operation = ALU_PASS_A;

        unique case (opcode)
            OP_ADD: alu_operation = ALU_ADD;
            OP_SUB: alu_operation = ALU_SUB;
            OP_AND: alu_operation = ALU_AND;
            OP_OR : alu_operation = ALU_OR;
            OP_XOR: alu_operation = ALU_XOR;
            OP_INC: alu_operation = ALU_INC;
            OP_DEC: alu_operation = ALU_DEC;
            OP_SHL: alu_operation = ALU_SHL;
            OP_SHR: alu_operation = ALU_SHR;
            default: alu_operation = ALU_PASS_A;
        endcase
    end

    cpu4_alu u_alu (
        .a         (accumulator),
        .b         (ram_read_data),
        .operation (alu_operation),
        .result    (alu_result),
        .carry     (alu_carry),
        .zero      (alu_zero)
    );

    assign ram_write_enable = enable &&
                              (state == STATE_EXECUTE) &&
                              (opcode == OP_STA);

    always_ff @(posedge clk) begin
        if (reset) begin
            program_counter     <= 4'h0;
            instruction_register <= 8'h00;
            accumulator         <= 4'h0;
            output_port         <= 4'h0;
            state               <= STATE_FETCH;
        end else if (enable) begin
            unique case (state)
                STATE_FETCH: begin
                    instruction_register <= rom_instruction;
                    program_counter      <= program_counter + 4'd1;
                    state                <= STATE_EXECUTE;
                end

                STATE_EXECUTE: begin
                    unique case (opcode)
                        OP_NOP: ;
                        OP_LDI: accumulator <= operand;
                        OP_LDA: accumulator <= ram_read_data;
                        OP_STA: ; // RAM write occurs through ram_write_enable.

                        OP_ADD,
                        OP_SUB,
                        OP_AND,
                        OP_OR,
                        OP_XOR,
                        OP_INC,
                        OP_DEC,
                        OP_SHL,
                        OP_SHR: accumulator <= alu_result;

                        OP_JMP: program_counter <= operand;
                        OP_OUT: output_port <= accumulator;
                        OP_HLT: state <= STATE_HALTED;
                        default: ;
                    endcase

                    if (opcode != OP_HLT) begin
                        state <= STATE_FETCH;
                    end
                end

                STATE_HALTED: begin
                    state <= STATE_HALTED;
                end

                default: state <= STATE_FETCH;
            endcase
        end
    end

    assign halted            = (state == STATE_HALTED);
    assign debug_pc          = program_counter;
    assign debug_accumulator = accumulator;
    assign debug_instruction = instruction_register;
    assign debug_state       = state;
    assign debug_alu_carry   = alu_carry;
    assign debug_alu_zero    = alu_zero;
endmodule