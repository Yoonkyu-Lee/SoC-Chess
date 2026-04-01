proc create_soc_chess_bd {design_name} {
    if {[llength [get_bd_designs -quiet $design_name]]} {
        close_bd_design [get_bd_designs $design_name]
    }

    create_bd_design $design_name
    current_bd_design $design_name

    set clk_100MHz [create_bd_port -dir I -type clk clk_100MHz]
    set_property -dict [list CONFIG.FREQ_HZ {100000000}] $clk_100MHz

    set reset_rtl_0 [create_bd_port -dir I -type rst reset_rtl_0]
    set_property -dict [list CONFIG.POLARITY {ACTIVE_LOW}] $reset_rtl_0

    set usb_spi_miso [create_bd_port -dir I usb_spi_miso]
    set usb_spi_mosi [create_bd_port -dir O usb_spi_mosi]
    set usb_spi_sclk [create_bd_port -dir O usb_spi_sclk]
    set usb_spi_ss   [create_bd_port -dir O -from 0 -to 0 usb_spi_ss]

    set uart_rxd [create_bd_port -dir I uart_rtl_0_rxd]
    set uart_txd [create_bd_port -dir O uart_rtl_0_txd]
    set usb_int  [create_bd_port -dir I -from 0 -to 0 gpio_usb_int_tri_i]
    set usb_rst  [create_bd_port -dir O -from 0 -to 0 gpio_usb_rst_tri_o]
    set usb_keycode_0 [create_bd_port -dir O -from 31 -to 0 gpio_usb_keycode_0_tri_o]
    set usb_keycode_1 [create_bd_port -dir O -from 31 -to 0 gpio_usb_keycode_1_tri_o]

    create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
    set_property -dict [list \
        CONFIG.C_DEBUG_ENABLED {1} \
        CONFIG.C_D_AXI {1} \
        CONFIG.C_D_LMB {1} \
        CONFIG.C_I_LMB {1} \
    ] [get_bd_cells microblaze_0]

    # This automation-driven recreation is a clean substitute for the original
    # hand-edited course workspace. Verify and refine after reinstalling Vivado.
    apply_bd_automation -rule xilinx.com:bd_rule:microblaze [get_bd_cells microblaze_0]

    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 system_clock
    set_property -dict [list CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin}] [get_bd_cells system_clock]

    create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 system_reset
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 debug_uart
    set_property -dict [list CONFIG.C_BAUDRATE {115200}] [get_bd_cells debug_uart]

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 usb_reset_gpio
    set_property -dict [list CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {1}] [get_bd_cells usb_reset_gpio]

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 usb_interrupt_gpio
    set_property -dict [list CONFIG.C_ALL_INPUTS {1} CONFIG.C_GPIO_WIDTH {1} CONFIG.C_INTERRUPT_PRESENT {1}] [get_bd_cells usb_interrupt_gpio]

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 usb_keycode_gpio
    set_property -dict [list \
        CONFIG.C_ALL_OUTPUTS {1} \
        CONFIG.C_ALL_OUTPUTS_2 {1} \
        CONFIG.C_IS_DUAL {1} \
    ] [get_bd_cells usb_keycode_gpio]

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 usb_timer
    set_property -dict [list CONFIG.enable_timer2 {0}] [get_bd_cells usb_timer]

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 usb_spi
    set_property -dict [list CONFIG.C_SCK_RATIO {4} CONFIG.C_USE_STARTUP {0}] [get_bd_cells usb_spi]

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_interrupt_controller
    set_property -dict [list CONFIG.C_HAS_FAST {1}] [get_bd_cells axi_interrupt_controller]

    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 interrupt_concat
    set_property -dict [list CONFIG.NUM_PORTS {4}] [get_bd_cells interrupt_concat]

    connect_bd_net $clk_100MHz [get_bd_pins system_clock/clk_in1]
    connect_bd_net [get_bd_pins system_clock/clk_out1] [get_bd_pins microblaze_0/Clk]
    connect_bd_net [get_bd_pins system_clock/clk_out1] [get_bd_pins system_reset/slowest_sync_clk]
    connect_bd_net [get_bd_pins system_clock/locked] [get_bd_pins system_reset/dcm_locked]
    connect_bd_net $reset_rtl_0 [get_bd_pins system_reset/ext_reset_in]

    connect_bd_net [get_bd_pins system_reset/mb_reset] [get_bd_pins microblaze_0/Reset]
    connect_bd_net [get_bd_pins axi_interrupt_controller/interrupt] [get_bd_pins microblaze_0/INTERRUPT]
    connect_bd_net [get_bd_pins interrupt_concat/dout] [get_bd_pins axi_interrupt_controller/intr]

    connect_bd_net [get_bd_pins debug_uart/interrupt] [get_bd_pins interrupt_concat/In0]
    connect_bd_net [get_bd_pins usb_interrupt_gpio/ip2intc_irpt] [get_bd_pins interrupt_concat/In1]
    connect_bd_net [get_bd_pins usb_timer/interrupt] [get_bd_pins interrupt_concat/In2]
    connect_bd_net [get_bd_pins usb_spi/ip2intc_irpt] [get_bd_pins interrupt_concat/In3]

    connect_bd_net $uart_rxd [get_bd_pins debug_uart/rx]
    connect_bd_net $uart_txd [get_bd_pins debug_uart/tx]

    connect_bd_net $usb_int [get_bd_pins usb_interrupt_gpio/gpio_io_i]
    connect_bd_net $usb_rst [get_bd_pins usb_reset_gpio/gpio_io_o]
    connect_bd_net $usb_keycode_0 [get_bd_pins usb_keycode_gpio/gpio_io_o]
    connect_bd_net $usb_keycode_1 [get_bd_pins usb_keycode_gpio/gpio2_io_o]

    connect_bd_net $usb_spi_miso [get_bd_pins usb_spi/io1_i]
    connect_bd_net $usb_spi_mosi [get_bd_pins usb_spi/io0_o]
    connect_bd_net $usb_spi_sclk [get_bd_pins usb_spi/sck_o]
    connect_bd_net $usb_spi_ss [get_bd_pins usb_spi/ss_o]
    connect_bd_net [get_bd_pins system_clock/clk_out1] [get_bd_pins usb_spi/ext_spi_clk]

    # AXI interconnect and address map are intentionally recreated via automation.
    # These commands should be validated once Vivado is available again.
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 [get_bd_intf_pins axi_interrupt_controller/S_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 [get_bd_intf_pins debug_uart/S_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 [get_bd_intf_pins usb_interrupt_gpio/S_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 [get_bd_intf_pins usb_keycode_gpio/S_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 [get_bd_intf_pins usb_reset_gpio/S_AXI]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 [get_bd_intf_pins usb_spi/AXI_LITE]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 [get_bd_intf_pins usb_timer/S_AXI]

    assign_bd_address
    validate_bd_design
    save_bd_design
}

