// CPU-1 Nibble-4 Top Module for AMD Xilinx Kria KV260
// Uses the single PMOD connector (J2 on the KV260 carrier card, 8 signal pins):
//   pmod_io1 (J2 pin 1, HDA11,    H12): led[0]
//   pmod_io2 (J2 pin 2, HDA15,    B10): led[1]
//   pmod_io3 (J2 pin 3, HDA12,    E10): led[2]
//   pmod_io4 (J2 pin 4, HDA16_CC, E12): external clock input (100MHz, clock-capable)
//   pmod_io5 (J2 pin 5, HDA13,    D10): led[3]
//   pmod_io6 (J2 pin 6, HDA17,    D11): halted indicator (red)
//   pmod_io7 (J2 pin 7, HDA14,    C11): reset button (active high)
//   pmod_io8 (J2 pin 8, HDA18,    B11): running indicator (green)
//
// J2 pins 9/11 are GND, pins 10/12 are PMOD_3V3 (gated by PMOD_PWR_EN).
//
// Alternatively, the KV260 PS can provide a clock via the Zynq block design.
// For a PL-only standalone build, provide a 100MHz clock on pmod_io4.

module cpu4_top_kv260 #(
    parameter integer CLOCK_ENABLE_COUNTER_BITS = 24,
    parameter string  PROGRAM_FILE = "demo_cpu4.mem"
) (
    // PMOD connections (J2 on KV260 carrier card)
    output logic       pmod_io1,   // led[0]
    output logic       pmod_io2,   // led[1]
    output logic       pmod_io3,   // led[2]
    input  logic       pmod_io4,   // clock input (100MHz, HDA16_CC)
    output logic       pmod_io5,   // led[3]
    output logic       pmod_io6,   // halted (red LED)
    input  logic       pmod_io7,   // reset button (active high)
    output logic       pmod_io8    // running (green LED)
);

    logic [CLOCK_ENABLE_COUNTER_BITS-1:0] clock_enable_counter;
    logic cpu_enable;
    logic [3:0] cpu_output;
    logic halted;

    // Clock divider: generates a slow enable pulse for visible LED blinking
    always_ff @(posedge pmod_io4) begin
        if (pmod_io7) begin
            clock_enable_counter <= '0;
            cpu_enable           <= 1'b0;
        end else begin
            clock_enable_counter <= clock_enable_counter + 1'b1;
            cpu_enable           <= &clock_enable_counter;
        end
    end

    cpu4_core #(
        .PROGRAM_FILE(PROGRAM_FILE)
    ) u_cpu (
        .clk               (pmod_io4),
        .reset             (pmod_io7),
        .enable            (cpu_enable),
        .output_port       (cpu_output),
        .halted            (halted),
        .debug_pc          (),
        .debug_accumulator (),
        .debug_instruction (),
        .debug_state       (),
        .debug_alu_carry   (),
        .debug_alu_zero    ()
    );

    assign pmod_io1 = cpu_output[0];
    assign pmod_io2 = cpu_output[1];
    assign pmod_io3 = cpu_output[2];
    assign pmod_io5 = cpu_output[3];
    assign pmod_io6 = halted;       // red when halted
    assign pmod_io8 = ~halted;      // green when running
endmodule
