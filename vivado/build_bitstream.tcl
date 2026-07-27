set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ..]]
source [file join $script_dir create_project.tcl]

launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "CPU4 KV260 synthesis failed: [get_property STATUS [get_runs synth_1]]"
}

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    error "CPU4 KV260 implementation failed: [get_property STATUS [get_runs impl_1]]"
}

set output_dir [file join $project_root generated]
file mkdir $output_dir
set run_dir [get_property DIRECTORY [get_runs impl_1]]
set bitstreams [glob -nocomplain [file join $run_dir *.bit]]
if {[llength $bitstreams] != 1} {
    error "Expected exactly one bitstream in $run_dir, found [llength $bitstreams]"
}
file copy -force [lindex $bitstreams 0] [file join $output_dir cpu4_kv260.bit]
puts "CPU4 KV260 bitstream copied to [file join $output_dir cpu4_kv260.bit]"