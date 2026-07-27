`timescale 1ns/1ps

module tb_cpu4_core;
    logic clk;
    logic reset;
    logic enable;
    logic [3:0] output_port;
    logic halted;
    logic [3:0] debug_pc;
    logic [3:0] debug_accumulator;
    logic [7:0] debug_instruction;
    logic [1:0] debug_state;
    logic debug_alu_carry;
    logic debug_alu_zero;

    cpu4_core #(
        .PROGRAM_FILE("demo_cpu4.mem")
    ) dut (
        .clk               (clk),
        .reset             (reset),
        .enable            (enable),
        .output_port       (output_port),
        .halted            (halted),
        .debug_pc          (debug_pc),
        .debug_accumulator (debug_accumulator),
        .debug_instruction (debug_instruction),
        .debug_state       (debug_state),
        .debug_alu_carry   (debug_alu_carry),
        .debug_alu_zero    (debug_alu_zero)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        reset  = 1'b1;
        enable = 1'b0;

        repeat (3) @(posedge clk);
        reset  = 1'b0;
        enable = 1'b1;

        wait (halted == 1'b1);
        @(posedge clk);

        assert (output_port == 4'h8)
            else $fatal(1, "CPU4 FAIL: expected output 0x8, got 0x%0h", output_port);

        assert (debug_accumulator == 4'h8)
            else $fatal(1, "CPU4 FAIL: expected accumulator 0x8, got 0x%0h", debug_accumulator);

        $display("CPU4 PASS: 3 + 5 = %0d", output_port);
        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "CPU4 TIMEOUT");
    end
endmodule