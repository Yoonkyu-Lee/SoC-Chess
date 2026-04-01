module soc_chess_top (
    input  logic       Clk,
    input  logic       reset_rtl_0,

    input  logic [0:0] gpio_usb_int_tri_i,
    output logic       gpio_usb_rst_tri_o,
    input  logic       usb_spi_miso,
    output logic       usb_spi_mosi,
    output logic       usb_spi_sclk,
    output logic       usb_spi_ss,

    input  logic       uart_rtl_0_rxd,
    output logic       uart_rtl_0_txd,

    output logic       hdmi_tmds_clk_n,
    output logic       hdmi_tmds_clk_p,
    output logic [2:0] hdmi_tmds_data_n,
    output logic [2:0] hdmi_tmds_data_p,

    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);

    logic [31:0] usb_keycode_channel0;
    logic [31:0] usb_keycode_channel1;
    logic [0:0]  usb_reset_gpio;
    logic [0:0]  usb_spi_ss_bus;

    logic        pixel_clk;
    logic        pixel_clk_5x;
    logic        pixel_clk_locked;
    logic        hsync;
    logic        vsync;
    logic        vde;
    logic [9:0]  draw_x;
    logic [9:0]  draw_y;
    logic [9:0]  cursor_x;
    logic [9:0]  cursor_y;
    logic [9:0]  cursor_size;
    logic [3:0]  red;
    logic [3:0]  green;
    logic [3:0]  blue;

    logic reset;

    assign reset = reset_rtl_0;
    assign gpio_usb_rst_tri_o = usb_reset_gpio[0];
    assign usb_spi_ss = usb_spi_ss_bus[0];

    hex_driver hex_display_a (
        .clk(Clk),
        .reset(reset),
        .in({
            usb_keycode_channel0[31:28],
            usb_keycode_channel0[27:24],
            usb_keycode_channel0[23:20],
            usb_keycode_channel0[19:16]
        }),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );

    hex_driver hex_display_b (
        .clk(Clk),
        .reset(reset),
        .in({
            usb_keycode_channel0[15:12],
            usb_keycode_channel0[11:8],
            usb_keycode_channel0[7:4],
            usb_keycode_channel0[3:0]
        }),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );

    // The block design is recreated by Tcl as `soc_chess_mb`.
    soc_chess_mb usb_soc (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(usb_keycode_channel0),
        .gpio_usb_keycode_1_tri_o(usb_keycode_channel1),
        .gpio_usb_rst_tri_o(usb_reset_gpio),
        .reset_rtl_0(~reset),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss_bus)
    );

    clk_wiz_0 video_clock_gen (
        .clk_out1(pixel_clk),
        .clk_out2(pixel_clk_5x),
        .reset(reset),
        .locked(pixel_clk_locked),
        .clk_in1(Clk)
    );

    vga_controller video_timing (
        .pixel_clk(pixel_clk),
        .reset(reset),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(draw_x),
        .drawY(draw_y)
    );

    hdmi_tx_v1_0 #(
        .C_RED_WIDTH(4),
        .C_GREEN_WIDTH(4),
        .C_BLUE_WIDTH(4)
    ) hdmi_encoder (
        .pix_clk(pixel_clk),
        .pix_clkx5(pixel_clk_5x),
        .pix_clk_locked(pixel_clk_locked),
        .rst(reset),
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        .TMDS_CLK_P(hdmi_tmds_clk_p),
        .TMDS_CLK_N(hdmi_tmds_clk_n),
        .TMDS_DATA_P(hdmi_tmds_data_p),
        .TMDS_DATA_N(hdmi_tmds_data_n)
    );

    mouse_cursor cursor (
        .Reset(reset),
        .frame_clk(vsync),
        .usb_delta_x(usb_keycode_channel0[7:0]),
        .usb_delta_y(usb_keycode_channel0[15:8]),
        .CursorX(cursor_x),
        .CursorY(cursor_y),
        .CursorSize(cursor_size)
    );

    chess_renderer renderer (
        .CursorX(cursor_x),
        .CursorY(cursor_y),
        .Click(usb_keycode_channel0[23:16]),
        .DrawX(draw_x),
        .DrawY(draw_y),
        .CursorSize(cursor_size),
        .reg_clk(Clk),
        .reset(reset),
        .vga_clk(pixel_clk),
        .vde(vde),
        .Red(red),
        .Green(green),
        .Blue(blue)
    );

endmodule
