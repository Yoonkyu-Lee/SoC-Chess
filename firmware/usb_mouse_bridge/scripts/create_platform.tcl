set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir .. .. ..]]
set workspace_dir [file join $repo_root build vitis]
set xsa_path [file join $repo_root build vivado soc_chess_fpga soc_chess_fpga.xsa]
set platform_name soc_chess_platform

if {![file exists $xsa_path]} {
    error "Missing hardware platform export: $xsa_path"
}

file mkdir $workspace_dir
setws $workspace_dir

platform create -name $platform_name -hw $xsa_path -proc microblaze_0 -os standalone -out $workspace_dir
platform write
platform generate

puts "Created XSCT platform in $workspace_dir"

