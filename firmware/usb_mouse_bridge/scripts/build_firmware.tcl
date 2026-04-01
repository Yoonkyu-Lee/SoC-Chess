set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir .. .. ..]]
set workspace_dir [file join $repo_root build vitis]
set platform_name soc_chess_platform
set app_name usb_mouse_bridge
set source_root [file join $repo_root firmware usb_mouse_bridge]

setws $workspace_dir

if {![file exists [file join $workspace_dir $platform_name]]} {
    source [file join $script_dir create_platform.tcl]
}

if {[file exists [file join $workspace_dir $app_name]]} {
    app remove -name $app_name
}

app create -name $app_name -platform $platform_name -proc microblaze_0 -os standalone -lang C -template {Empty Application(C)}
importsources -name $app_name -path $source_root
app build -name $app_name

puts "Built firmware app $app_name in $workspace_dir"

