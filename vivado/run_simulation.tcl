set script_dir [file dirname [file normalize [info script]]]
source [file join $script_dir create_project.tcl]
launch_simulation
run all
close_sim
puts "CPU4 KV260 simulation completed. Check the Tcl console for CPU4 PASS."