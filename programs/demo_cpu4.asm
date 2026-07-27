; Nibble-4 demonstration program
; Calculate 3 + 5, send 8 to the output port, then halt.

        LDI 3       ; ACC = 3
        STA 0xE     ; RAM[0xE] = 3
        LDI 5       ; ACC = 5
        ADD 0xE     ; ACC = 5 + RAM[0xE] = 8
        OUT         ; output_port = 8
        HLT