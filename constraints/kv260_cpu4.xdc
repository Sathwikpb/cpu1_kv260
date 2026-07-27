## Constraints for CPU-1 Nibble-4 on AMD Xilinx Kria KV260
## PMOD connector J2 on the KV260 starter kit carrier card (single 12-pin header,
## 8 signal pins; pins 9/11 = GND, pins 10/12 = PMOD_3V3 gated by PMOD_PWR_EN).
##
## J2 Pin Mapping:
##   Pin 1 : pmod_io1 -> led[0]   (HDA11)
##   Pin 2 : pmod_io2 -> led[1]   (HDA15)
##   Pin 3 : pmod_io3 -> led[2]   (HDA12)
##   Pin 4 : pmod_io4 -> clock in (HDA16_CC, clock-capable)
##   Pin 5 : pmod_io5 -> led[3]   (HDA13)
##   Pin 6 : pmod_io6 -> halted   (HDA17, red)
##   Pin 7 : pmod_io7 -> reset    (HDA14, button to VCC = active high)
##   Pin 8 : pmod_io8 -> running  (HDA18, green)
##
## FPGA pins per official Kria K26 carrier-card XDC (XTP686) / SOM240 pinout:
##   HDA11: H12   HDA15: B10   HDA12: E10   HDA16_CC: E12
##   HDA13: D10   HDA17: D11   HDA14: C11   HDA18:    B11

set_property -dict { PACKAGE_PIN H12 IOSTANDARD LVCMOS33 } [get_ports { pmod_io1 }]
set_property -dict { PACKAGE_PIN B10 IOSTANDARD LVCMOS33 } [get_ports { pmod_io2 }]
set_property -dict { PACKAGE_PIN E10 IOSTANDARD LVCMOS33 } [get_ports { pmod_io3 }]

# Clock input (100MHz) on the clock-capable PMOD pin HDA16_CC
set_property -dict { PACKAGE_PIN E12 IOSTANDARD LVCMOS33 } [get_ports { pmod_io4 }]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000} [get_ports { pmod_io4 }]

set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports { pmod_io5 }]
set_property -dict { PACKAGE_PIN D11 IOSTANDARD LVCMOS33 } [get_ports { pmod_io6 }]
set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS33 } [get_ports { pmod_io7 }]
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { pmod_io8 }]
