#!/usr/bin/env python3
"""Instruction-set emulator for the Nibble-4 teaching CPU (KV260 edition)."""

from __future__ import annotations
import argparse
from pathlib import Path

NAMES = ["NOP", "LDI", "LDA", "STA", "ADD", "SUB", "AND", "OR",
         "XOR", "JMP", "OUT", "INC", "DEC", "SHL", "SHR", "HLT"]


def load_program(path: Path) -> list[int]:
    words = [int(line.strip(), 16) for line in path.read_text().splitlines() if line.strip()]
    return (words + [0] * 16)[:16]


def run(program: list[int], trace: bool = False, limit: int = 100) -> tuple[int, int, int]:
    ram = [0] * 16
    pc = acc = out = 0
    halted = False
    steps = 0

    while not halted and steps < limit:
        ir = program[pc]
        pc = (pc + 1) & 0xF
        op, arg = (ir >> 4) & 0xF, ir & 0xF
        before = acc

        if op == 0x0: pass
        elif op == 0x1: acc = arg
        elif op == 0x2: acc = ram[arg]
        elif op == 0x3: ram[arg] = acc
        elif op == 0x4: acc = (acc + ram[arg]) & 0xF
        elif op == 0x5: acc = (acc - ram[arg]) & 0xF
        elif op == 0x6: acc &= ram[arg]
        elif op == 0x7: acc |= ram[arg]
        elif op == 0x8: acc ^= ram[arg]
        elif op == 0x9: pc = arg
        elif op == 0xA: out = acc
        elif op == 0xB: acc = (acc + 1) & 0xF
        elif op == 0xC: acc = (acc - 1) & 0xF
        elif op == 0xD: acc = (acc << 1) & 0xF
        elif op == 0xE: acc >>= 1
        elif op == 0xF: halted = True

        if trace:
            print(f"step={steps:02d} op={NAMES[op]:3s} arg={arg:X} ACC:{before:X}->{acc:X} PC={pc:X} OUT={out:X}")
        steps += 1

    if not halted:
        raise RuntimeError("execution limit reached before HLT")
    return acc, out, steps


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("program", type=Path)
    parser.add_argument("--trace", action="store_true")
    args = parser.parse_args()
    acc, out, steps = run(load_program(args.program), args.trace)
    print(f"halted after {steps} instructions: ACC=0x{acc:X}, OUT=0x{out:X}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())