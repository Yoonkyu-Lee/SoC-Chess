module chessboard_example (
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY,
	input logic blank,
	output logic [3:0] red, green, blue
);

logic [17:0] rom_address;
logic [2:0] rom_q;

logic [3:0] palette_red, palette_green, palette_blue;
logic [9:0] scaled_x;
logic [17:0] row_offset;

logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// Scale the 640x480 scan position into the 480x480 chessboard texture.
// Using shift/add math here avoids the wide multiply/divide chain that hurt timing.
assign scaled_x = ((DrawX << 1) + DrawX) >> 2;
assign row_offset = ({DrawY, 9'b0}) - ({DrawY, 5'b0}); // DrawY * (512 - 32) = DrawY * 480
assign rom_address = row_offset + scaled_x;

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

chessboard_rom chessboard_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address),
	.douta       (rom_q)
);

chessboard_palette chessboard_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

endmodule
