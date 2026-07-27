set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ..]]

if {[info exists ::env(FPGA_PART)]} {
    set fpga_part $::env(FPGA_PART)
} else {
    # Kria KV260 SOM: XCK26-SFVC784-2LV-C
    set fpga_part "xck26-sfvc784-2lv-c"
}

create_project cpu4_kv260 $project_root -part $fpga_part -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

add_files -norecurse [list \
    [file join $project_root rtl cpu4_pkg.sv] \
    [file join $project_root rtl cpu4_alu.sv] \
    [file join $project_root rtl cpu4_program_rom.sv] \
    [file join $project_root rtl cpu4_data_ram.sv] \
    [file join $project_root rtl cpu4_core.sv] \
    [file join $project_root rtl cpu4_top_kv260.sv]]

add_files -fileset sim_1 -norecurse [file join $project_root sim tb_cpu4_core.sv]
add_files -fileset constrs_1 -norecurse [file join $project_root constraints kv260_cpu4.xdc]
add_files -norecurse [file join $project_root programs demo_cpu4.mem]
set_property FILE_TYPE {Memory Initialization Files} [get_files demo_cpu4.mem]

set_property top cpu4_top_kv260 [get_filesets sources_1]
set_property top tb_cpu4_core [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Created CPU4 KV260 project at [file join $project_root cpu4_kv260.xpr]"
puts "Target part: $fpga_part"
