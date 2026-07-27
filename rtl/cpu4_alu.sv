module cpu4_alu (
    input  logic [3:0]              a,
    input  logic [3:0]              b,
    input  cpu4_pkg::cpu4_alu_op_t operation,
    output logic [3:0]              result,
    output logic                    carry,
    output logic                    zero
);
    import cpu4_pkg::*;

    logic [4:0] wide_result;

    always_comb begin
        result      = a;
        carry       = 1'b0;
        wide_result = 5'b0;

        unique case (operation)
            ALU_PASS_A: result = a;

            ALU_ADD: begin
                wide_result = {1'b0, a} + {1'b0, b};
                result       = wide_result[3:0];
                carry        = wide_result[4];
            end

            ALU_SUB: begin
                result = a - b;
                carry  = (a >= b); // Carry=1 means no unsigned borrow.
            end

            ALU_AND: result = a & b;
            ALU_OR : result = a | b;
            ALU_XOR: result = a ^ b;

            ALU_INC: begin
                wide_result = {1'b0, a} + 5'd1;
                result       = wide_result[3:0];
                carry        = wide_result[4];
            end

            ALU_DEC: begin
                result = a - 4'd1;
                carry  = (a >= 4'd1);
            end

            ALU_SHL: begin
                result = {a[2:0], 1'b0};
                carry  = a[3];
            end

            ALU_SHR: begin
                result = {1'b0, a[3:1]};
                carry  = a[0];
            end

            default: begin
                result = a;
                carry  = 1'b0;
            end
        endcase
    end

    assign zero = (result == 4'h0);
endmodule