open_checkpoint build/vivado/soc_chess_fpga/soc_chess_fpga.runs/impl_1/soc_chess_top_routed.dcp
report_timing \
    -from [get_clocks clk_100] \
    -to [get_clocks clk_out1_clk_wiz_0] \
    -max_paths 20 \
    -file build/vivado/clk100_to_pixel_timing.rpt
exit
