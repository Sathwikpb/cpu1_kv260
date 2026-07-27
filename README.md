# CPU-1: Nibble-4 (KV260 Edition)

Nibble-4 is an intentionally small 4-bit accumulator CPU ported to the **AMD Xilinx Kria KV260 Vision AI Starter Kit**.

## Hardware summary

- 4-bit accumulator and ALU
- 4-bit program counter
- 16 x 8-bit instruction ROM
- 16 x 4-bit data RAM
- 8-bit instruction: `opcode[7:4] | operand[3:0]`
- Two controller states: FETCH and EXECUTE
- 4-bit output port

## KV260 I/O Mapping

The KV260 carrier card has a single PMOD header (J2) with 8 signal pins
(HDA11–HDA18). J2 pins 9/11 are GND, pins 10/12 are PMOD_3V3 (gated by
PMOD_PWR_EN). All PMOD I/O is LVCMOS33.

| CPU Signal      | Port      | J2 Pin | Net       | FPGA Pin | Description                          |
|-----------------|-----------|--------|-----------|----------|--------------------------------------|
| led[0]          | pmod_io1  | 1      | HDA11     | H12      | Output bit 0                         |
| led[1]          | pmod_io2  | 2      | HDA15     | B10      | Output bit 1                         |
| led[2]          | pmod_io3  | 3      | HDA12     | E10      | Output bit 2                         |
| clk             | pmod_io4  | 4      | HDA16_CC  | E12      | Clock input (external 100MHz, CC pin)|
| led[3]          | pmod_io5  | 5      | HDA13     | D10      | Output bit 3                         |
| halted (red)    | pmod_io6  | 6      | HDA17     | D11      | HALT indicator (red when halted)     |
| reset_btn       | pmod_io7  | 7      | HDA14     | C11      | Reset button (active high)           |
| running (green) | pmod_io8  | 8      | HDA18     | B11      | RUN indicator (green when running)   |

> **Note:** The KV260 PS (Processing System) can provide clocks to the PL fabric. For a standalone PL-only design, connect an external clock source to pmod_io4 (the clock-capable HDA16_CC pin) or modify the design to use the Zynq PS clock via the block design.

## Demonstration

The included program calculates `3 + 5`, writes `8` to the output port and halts. On the KV260 via the PMOD header, four LEDs display `1000`.

## Rebuild the memory file

```bash
python tools/assembler_cpu4.py programs/demo_cpu4.asm \
  -o programs/demo_cpu4.mem \
  --listing programs/demo_cpu4.lst
```

## Run the emulator

```bash
python tools/emulator_cpu4.py programs/demo_cpu4.mem --trace
```

## Vivado

Open `cpu4_kv260.xpr` in Vivado 2026.1 for the GUI project. To recreate the
project file from the checked-in RTL and constraints, run:

```bash
vivado -mode batch -source vivado/create_project.tcl
vivado -mode batch -source vivado/run_simulation.tcl
vivado -mode batch -source vivado/build_bitstream.tcl
