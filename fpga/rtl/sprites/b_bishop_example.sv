module b_bishop_example (
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY,
	input logic blank,
	output logic [3:0] red, green, blue
);

logic [11:0] rom_address;
logic [2:0] rom_q;

logic [3:0] palette_red, palette_green, palette_blue;
logic [5:0] sprite_x;
logic [5:0] sprite_y;
logic [11:0] row_offset;

logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// Scale the screen coordinates into the 60x60 sprite space with shift/add math.
assign sprite_x = ((DrawX << 1) + DrawX) >> 5; // floor(DrawX * 60 / 640)
assign sprite_y = DrawY[9:3];          // floor(DrawY * 60 / 480)
assign row_offset = ({sprite_y, 6'b0}) - ({sprite_y, 2'b0}); // sprite_y * 60
assign rom_address = row_offset + sprite_x;

always_ff @ (posedge vga_clk) begin
	red <= 4'h0;
	green <= 4'h0;
	blue <= 4'h0;

	if (blank) begin
		red <= palette_red;
		green <= palette_green;
		blue <= palette_blue;
	end
end

b_bishop_rom b_bishop_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address),
	.douta       (rom_q)
);

b_bishop_palette b_bishop_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

endmodule
