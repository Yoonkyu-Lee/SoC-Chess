set script_dir [file dirname [file normalize [info script]]]
set repo_root [file normalize [file join $script_dir .. ..]]
set build_root [file join $repo_root build vivado]
set project_name soc_chess_fpga
set project_dir [file join $build_root $project_name]
set project_part xc7s50csga324-1

proc vivado_path {path} {
    return [string map {\\ /} [file normalize $path]]
}

proc add_if_exists {path} {
    if {![file exists $path]} {
        error "Expected file does not exist: $path"
    }
    add_files -norecurse [list [vivado_path $path]]
}

proc add_globbed_files {pattern} {
    foreach path [lsort [glob -nocomplain $pattern]] {
        add_files -norecurse [list [vivado_path $path]]
    }
}

proc create_sprite_rom {module_name coe_path depth} {
    if {![file exists $coe_path]} {
        error "Missing COE file for $module_name: $coe_path"
    }

    create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name $module_name
    set_property -dict [list \
        CONFIG.Memory_Type {Single_Port_ROM} \
        CONFIG.Enable_A {Always_Enabled} \
        CONFIG.Load_Init_File {true} \
        CONFIG.Coe_File [vivado_path $coe_path] \
        CONFIG.Write_Width_A {3} \
        CONFIG.Read_Width_A {3} \
        CONFIG.Write_Depth_A $depth \
        CONFIG.Register_PortA_Output_of_Memory_Primitives {true} \
    ] [get_ips $module_name]
}

file mkdir $build_root
create_project $project_name $project_dir -part $project_part -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

add_if_exists [file join $repo_root fpga rtl top soc_chess_top.sv]
add_if_exists [file join $repo_root fpga rtl game chess_game_logic.sv]
add_if_exists [file join $repo_root fpga rtl video chess_renderer.sv]
add_if_exists [file join $repo_root fpga rtl video mouse_cursor.sv]
add_if_exists [file join $repo_root fpga rtl common vga_controller.sv]
add_if_exists [file join $repo_root fpga rtl common hex_driver.sv]

add_globbed_files [file join $repo_root fpga rtl sprites *_example.sv]
add_globbed_files [file join $repo_root fpga rtl sprites *_palette.sv]
add_globbed_files [file join $repo_root fpga rtl vendor hdmi_tx *.v]

add_if_exists [file join $repo_root fpga constraints soc_chess_top.xdc]

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
    CONFIG.PRIM_IN_FREQ {100.000} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25.000} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125.000} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {true} \
] [get_ips clk_wiz_0]

create_sprite_rom b_bishop_rom       [file join $repo_root assets chess coe b_bishop.COE]       3600
create_sprite_rom b_king_rom         [file join $repo_root assets chess coe b_king.COE]         3600
create_sprite_rom b_knight_rom       [file join $repo_root assets chess coe b_knight.COE]       3600
create_sprite_rom b_pawn_rom         [file join $repo_root assets chess coe b_pawn.COE]         3600
create_sprite_rom b_queen_rom        [file join $repo_root assets chess coe b_queen.COE]        3600
create_sprite_rom b_rook_rom         [file join $repo_root assets chess coe b_rook.COE]         3600
create_sprite_rom chessboard_rom     [file join $repo_root assets chess coe chessboard.COE]     230400
create_sprite_rom selected_border_rom [file join $repo_root assets chess coe selected_border.COE] 3600
create_sprite_rom w_bishop_rom       [file join $repo_root assets chess coe w_bishop.COE]       3600
create_sprite_rom w_king_rom         [file join $repo_root assets chess coe w_king.COE]         3600
create_sprite_rom w_knight_rom       [file join $repo_root assets chess coe w_knight.COE]       3600
create_sprite_rom w_pawn_rom         [file join $repo_root assets chess coe w_pawn.COE]         3600
create_sprite_rom w_queen_rom        [file join $repo_root assets chess coe w_queen.COE]        3600
create_sprite_rom w_rook_rom         [file join $repo_root assets chess coe w_rook.COE]         3600

generate_target all [get_ips]

source [file join $script_dir create_bd.tcl]
create_soc_chess_bd soc_chess_mb

set_property top soc_chess_top [current_fileset]
update_compile_order -fileset sources_1
save_project

puts "Created Vivado project at $project_dir"
