module vga_controller (
    input        pixel_clk,
    input        reset,
    output logic hs,
    output logic vs,
    output logic active_nblank,
    output logic sync,
    output logic [9:0] drawX,
    output logic [9:0] drawY
);

    parameter logic [9:0] hpixels = 10'b1100011111;
    parameter logic [9:0] vlines  = 10'b1000001100;

    logic [9:0] hc;
    logic [9:0] vc;
    logic display;

    assign sync = 1'b0;
    assign drawX = hc;
    assign drawY = vc;
    assign active_nblank = display;

    always_ff @(posedge pixel_clk) begin : counter_proc
        if (reset) begin
            hc <= 10'b0000000000;
            vc <= 10'b0000000000;
        end else if (hc == hpixels) begin
            hc <= 10'b0000000000;
            if (vc == vlines) begin
                vc <= 10'b0000000000;
            end else begin
                vc <= vc + 10'b0000000001;
            end
        end else begin
            hc <= hc + 10'b0000000001;
        end
    end

    always_ff @(posedge pixel_clk) begin : hsync_proc
        if (reset) begin
            hs <= 1'b0;
        end else if (((hc + 10'b0000000001) >= 10'b1010010000) &&
                     ((hc + 10'b0000000001) < 10'b1011110000)) begin
            hs <= 1'b0;
        end else begin
            hs <= 1'b1;
        end
    end

    always_ff @(posedge pixel_clk) begin : vsync_proc
        if (reset) begin
            vs <= 1'b0;
        end else if (((vc + 10'b0000000001) == 10'b0111101010) ||
                     ((vc + 10'b0000000001) == 10'b0111101011)) begin
            vs <= 1'b0;
        end else begin
            vs <= 1'b1;
        end
    end

    always_comb begin
        if ((hc >= 10'b1010000000) || (vc >= 10'b0111100000)) begin
            display = 1'b0;
        end else begin
            display = 1'b1;
        end
    end

endmodule
