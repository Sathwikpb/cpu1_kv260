#!/usr/bin/env python3
"""Two-pass assembler for the Nibble-4 teaching CPU ported to KV260."""

from __future__ import annotations
import argparse
from pathlib import Path
import re
import sys

OPCODES = {
    "NOP": 0x0, "LDI": 0x1, "LDA": 0x2, "STA": 0x3,
    "ADD": 0x4, "SUB": 0x5, "AND": 0x6, "OR":  0x7,
    "XOR": 0x8, "JMP": 0x9, "OUT": 0xA, "INC": 0xB,
    "DEC": 0xC, "SHL": 0xD, "SHR": 0xE, "HLT": 0xF,
}
NO_OPERAND = {"NOP", "OUT", "INC", "DEC", "SHL", "SHR", "HLT"}


def clean_line(line: str) -> str:
    return re.split(r"[;#]", line, maxsplit=1)[0].strip()


def parse_number(token: str, labels: dict[str, int]) -> int:
    token = token.strip()
    if token in labels:
        return labels[token]
    if token.lower().endswith("h"):
        return int(token[:-1], 16)
    return int(token, 0)


def assemble(source: str) -> tuple[list[int], list[str]]:
    raw_lines = source.splitlines()
    labels: dict[str, int] = {}
    pc = 0

    # Pass 1: collect labels.
    for line_no, raw in enumerate(raw_lines, 1):
        line = clean_line(raw)
        if not line:
            continue
        while ":" in line:
            label, line = line.split(":", 1)
            label = label.strip()
            if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", label):
                raise ValueError(f"line {line_no}: invalid label {label!r}")
            if label in labels:
                raise ValueError(f"line {line_no}: duplicate label {label}")
            labels[label] = pc
            line = line.strip()
            if not line:
                break
        if not line:
            continue
        head = line.split()[0].upper()
        if head == ".ORG":
            pc = parse_number(line.split(maxsplit=1)[1], labels)
        else:
            pc += 1
        if not 0 <= pc <= 16:
            raise ValueError(f"line {line_no}: program exceeds 16 words")

    memory = [0x00] * 16
    listing: list[str] = []
    pc = 0

    # Pass 2: encode.
    for line_no, raw in enumerate(raw_lines, 1):
        original = raw.rstrip()
        line = clean_line(raw)
        if not line:
            continue
        while ":" in line:
            _, line = line.split(":", 1)
            line = line.strip()
            if not line:
                break
        if not line:
            continue

        parts = line.replace(",", " ").split()
        mnemonic = parts[0].upper()
        if mnemonic == ".ORG":
            if len(parts) != 2:
                raise ValueError(f"line {line_no}: .ORG requires one address")
            pc = parse_number(parts[1], labels)
            continue
        if mnemonic == ".WORD":
            if len(parts) != 2:
                raise ValueError(f"line {line_no}: .WORD requires one value")
            word = parse_number(parts[1], labels)
            if not 0 <= word <= 0xFF:
                raise ValueError(f"line {line_no}: word must fit in 8 bits")
        else:
            if mnemonic not in OPCODES:
                raise ValueError(f"line {line_no}: unknown mnemonic {mnemonic}")
            if mnemonic in NO_OPERAND:
                if len(parts) != 1:
                    raise ValueError(f"line {line_no}: {mnemonic} takes no operand")
                operand = 0
            else:
                if len(parts) != 2:
                    raise ValueError(f"line {line_no}: {mnemonic} requires one operand")
                operand = parse_number(parts[1], labels)
                if not 0 <= operand <= 0xF:
                    raise ValueError(f"line {line_no}: operand must fit in 4 bits")
            word = (OPCODES[mnemonic] << 4) | operand

        if not 0 <= pc < 16:
            raise ValueError(f"line {line_no}: address 0x{pc:X} is outside program ROM")
        memory[pc] = word
        listing.append(f"{pc:01X}: {word:02X}    {original}")
        pc += 1

    return memory, listing


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("-o", "--output", type=Path, required=True)
    parser.add_argument("--listing", type=Path)
    args = parser.parse_args()

    try:
        memory, listing = assemble(args.source.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        print(f"assembler error: {exc}", file=sys.stderr)
        return 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(f"{word:02X}" for word in memory) + "\n", encoding="ascii")
    if args.listing:
        args.listing.write_text("\n".join(listing) + "\n", encoding="utf-8")

    print(f"Wrote {args.output} ({len(memory)} words)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())