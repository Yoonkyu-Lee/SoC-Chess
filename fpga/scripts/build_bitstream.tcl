set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir .. ..]]
set project_name soc_chess_fpga
set project_dir [file join $repo_root build vivado $project_name]
set xsa_path [file join $project_dir ${project_name}.xsa]

source [file join $script_dir create_project.tcl]

if {[llength [get_files -quiet *.bd]] > 0} {
    generate_target all [get_files *.bd]
}

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

open_run impl_1
report_timing_summary -file [file join $project_dir timing_summary.rpt]
report_utilization -file [file join $project_dir utilization.rpt]
write_hw_platform -fixed -include_bit -force $xsa_path

puts "Bitstream and XSA exported to $project_dir"

