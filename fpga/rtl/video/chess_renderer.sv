module chess_renderer (
    input  logic [9:0] CursorX,
    input  logic [9:0] CursorY,
    input  logic [9:0] DrawX,
    input  logic [9:0] DrawY,
    input  logic [9:0] CursorSize,
    input  logic [7:0] Click,
    input  logic       reg_clk,
    input  logic       reset,
    input  logic       vga_clk,
    input  logic       vde,
    output logic [3:0] Red,
    output logic [3:0] Green,
    output logic [3:0] Blue
);

    logic ball_on;
    logic clicked;
    logic reset_chess;
    logic highlight_border;
    logic legal_move;
    logic curr_player;
    logic change_board;
    logic hovered_val_OUB;

    logic [2:0] curr_state;
    logic [3:0] board[63:0];
    logic [3:0] board_vga[63:0];
    logic [3:0] piece_change;
    logic [5:0] piece_board_addr;
    logic [5:0] hovered_val;
    logic [5:0] pre_sel_val;
    logic [5:0] pre_sel_val_vga;
    logic [5:0] active_square;
    logic [3:0] x_index;
    logic [3:0] y_index;
    logic       highlight_border_vga;
    logic       curr_player_vga;

    logic [3:0] cb_red, cb_green, cb_blue;
    logic [3:0] b_bishop_red, b_bishop_green, b_bishop_blue;
    logic [3:0] b_king_red, b_king_green, b_king_blue;
    logic [3:0] b_knight_red, b_knight_green, b_knight_blue;
    logic [3:0] b_pawn_red, b_pawn_green, b_pawn_blue;
    logic [3:0] b_queen_red, b_queen_green, b_queen_blue;
    logic [3:0] b_rook_red, b_rook_green, b_rook_blue;
    logic [3:0] w_bishop_red, w_bishop_green, w_bishop_blue;
    logic [3:0] w_king_red, w_king_green, w_king_blue;
    logic [3:0] w_knight_red, w_knight_green, w_knight_blue;
    logic [3:0] w_pawn_red, w_pawn_green, w_pawn_blue;
    logic [3:0] w_queen_red, w_queen_green, w_queen_blue;
    logic [3:0] w_rook_red, w_rook_green, w_rook_blue;
    logic [3:0] s_border_red, s_border_green, s_border_blue;

    int dist_x;
    int dist_y;
    int cursor_radius;
    integer i;
    integer j;
    integer k;

    function automatic logic is_piece_pixel(
        input logic [3:0] sprite_red,
        input logic [3:0] sprite_green,
        input logic [3:0] sprite_blue
    );
        is_piece_pixel = !(
            (sprite_red == 4'hF) &&
            (sprite_green == 4'h8) &&
            (sprite_blue == 4'hD)
        );
    endfunction

    function automatic logic is_border_pixel(
        input logic [3:0] sprite_red,
        input logic [3:0] sprite_green,
        input logic [3:0] sprite_blue
    );
        is_border_pixel = !(
            (sprite_red == 4'hF) &&
            (sprite_green == 4'h4) &&
            (sprite_blue == 4'hD)
        );
    endfunction

    assign x_index = DrawX / 10'd60;
    assign y_index = DrawY / 10'd60;
    assign active_square = (y_index * 4'd8) + x_index;
    assign clicked = (Click == 8'b1);
    assign reset_chess = reset;
    assign dist_x = DrawX - CursorX;
    assign dist_y = DrawY - CursorY;
    assign cursor_radius = CursorSize;

    chessboard_example chessboard_bg (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(cb_red),
        .green(cb_green),
        .blue(cb_blue)
    );

    b_bishop_example black_bishop (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(b_bishop_red),
        .green(b_bishop_green),
        .blue(b_bishop_blue)
    );

    b_king_example black_king (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(b_king_red),
        .green(b_king_green),
        .blue(b_king_blue)
    );

    b_knight_example black_knight (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(b_knight_red),
        .green(b_knight_green),
        .blue(b_knight_blue)
    );

    b_pawn_example black_pawn (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(b_pawn_red),
        .green(b_pawn_green),
        .blue(b_pawn_blue)
    );

    b_queen_example black_queen (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(b_queen_red),
        .green(b_queen_green),
        .blue(b_queen_blue)
    );

    b_rook_example black_rook (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(b_rook_red),
        .green(b_rook_green),
        .blue(b_rook_blue)
    );

    w_bishop_example white_bishop (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(w_bishop_red),
        .green(w_bishop_green),
        .blue(w_bishop_blue)
    );

    w_king_example white_king (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(w_king_red),
        .green(w_king_green),
        .blue(w_king_blue)
    );

    w_knight_example white_knight (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(w_knight_red),
        .green(w_knight_green),
        .blue(w_knight_blue)
    );

    w_pawn_example white_pawn (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(w_pawn_red),
        .green(w_pawn_green),
        .blue(w_pawn_blue)
    );

    w_queen_example white_queen (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(w_queen_red),
        .green(w_queen_green),
        .blue(w_queen_blue)
    );

    w_rook_example white_rook (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(w_rook_red),
        .green(w_rook_green),
        .blue(w_rook_blue)
    );

    selected_border_example select_border (
        .vga_clk(vga_clk),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .blank(vde),
        .red(s_border_red),
        .green(s_border_green),
        .blue(s_border_blue)
    );

    chess_game_logic game_logic (
        .curr_board(board),
        .chess_click(clicked),
        .cursorX(CursorX),
        .cursorY(CursorY),
        .clk(reg_clk),
        .chess_reset(reset_chess),
        .change_board(change_board),
        .piece_board_addr(piece_board_addr),
        .piece_change(piece_change),
        .hovered_val(hovered_val),
        .hovered_val_OUB(hovered_val_OUB),
        .pre_sel_val(pre_sel_val),
        .highlight_border(highlight_border),
        .legal_move(legal_move),
        .curr_state(curr_state),
        .curr_player(curr_player)
    );

    always_ff @(posedge reg_clk) begin
        if (reset_chess || (curr_state == 3'b000)) begin
            board[6'b111000] <= 4'b0100;
            board[6'b111001] <= 4'b0010;
            board[6'b111010] <= 4'b0011;
            board[6'b111011] <= 4'b0101;
            board[6'b111100] <= 4'b0110;
            board[6'b111101] <= 4'b0011;
            board[6'b111110] <= 4'b0010;
            board[6'b111111] <= 4'b0100;

            for (j = 0; j < 8; j++) begin
                board[48 + j] <= 4'b0001;
                board[8 + j] <= 4'b1001;
            end

            for (i = 16; i < 48; i++) begin
                board[i] <= 4'b0000;
            end

            board[6'b000000] <= 4'b1100;
            board[6'b000001] <= 4'b1010;
            board[6'b000010] <= 4'b1011;
            board[6'b000011] <= 4'b1101;
            board[6'b000100] <= 4'b1110;
            board[6'b000101] <= 4'b1011;
            board[6'b000110] <= 4'b1010;
            board[6'b000111] <= 4'b1100;
        end else if (change_board) begin
            board[piece_board_addr] <= piece_change;
        end
    end

    // Snapshot game-state registers into the video clock domain before color generation.
    always_ff @(posedge vga_clk) begin
        for (k = 0; k < 64; k++) begin
            board_vga[k] <= board[k];
        end

        pre_sel_val_vga <= pre_sel_val;
        highlight_border_vga <= highlight_border;
        curr_player_vga <= curr_player;
    end

    always_comb begin : cursor_on_proc
        ball_on = ((dist_x * dist_x) + (dist_y * dist_y)) <= (cursor_radius * cursor_radius);
    end

    always_comb begin : rgb_display
        if (ball_on) begin
            Red = 4'hF;
            Green = 4'h7;
            Blue = 4'h0;
        end else if ((DrawX < 10'd480) && (DrawY < 10'd480)) begin
            if ((active_square == pre_sel_val_vga) &&
                highlight_border_vga &&
                is_border_pixel(s_border_red, s_border_green, s_border_blue)) begin
                Red = s_border_red;
                Green = s_border_green;
                Blue = s_border_blue;
            end else if ((board_vga[active_square] == 4'b0001) &&
                         is_piece_pixel(w_pawn_red, w_pawn_green, w_pawn_blue)) begin
                Red = w_pawn_red;
                Green = w_pawn_green;
                Blue = w_pawn_blue;
            end else if ((board_vga[active_square] == 4'b0010) &&
                         is_piece_pixel(w_knight_red, w_knight_green, w_knight_blue)) begin
                Red = w_knight_red;
                Green = w_knight_green;
                Blue = w_knight_blue;
            end else if ((board_vga[active_square] == 4'b0011) &&
                         is_piece_pixel(w_bishop_red, w_bishop_green, w_bishop_blue)) begin
                Red = w_bishop_red;
                Green = w_bishop_green;
                Blue = w_bishop_blue;
            end else if ((board_vga[active_square] == 4'b0100) &&
                         is_piece_pixel(w_rook_red, w_rook_green, w_rook_blue)) begin
                Red = w_rook_red;
                Green = w_rook_green;
                Blue = w_rook_blue;
            end else if ((board_vga[active_square] == 4'b0101) &&
                         is_piece_pixel(w_queen_red, w_queen_green, w_queen_blue)) begin
                Red = w_queen_red;
                Green = w_queen_green;
                Blue = w_queen_blue;
            end else if ((board_vga[active_square] == 4'b0110) &&
                         is_piece_pixel(w_king_red, w_king_green, w_king_blue)) begin
                Red = w_king_red;
                Green = w_king_green;
                Blue = w_king_blue;
            end else if ((board_vga[active_square] == 4'b1001) &&
                         is_piece_pixel(b_pawn_red, b_pawn_green, b_pawn_blue)) begin
                Red = b_pawn_red;
                Green = b_pawn_green;
                Blue = b_pawn_blue;
            end else if ((board_vga[active_square] == 4'b1010) &&
                         is_piece_pixel(b_knight_red, b_knight_green, b_knight_blue)) begin
                Red = b_knight_red;
                Green = b_knight_green;
                Blue = b_knight_blue;
            end else if ((board_vga[active_square] == 4'b1011) &&
                         is_piece_pixel(b_bishop_red, b_bishop_green, b_bishop_blue)) begin
                Red = b_bishop_red;
                Green = b_bishop_green;
                Blue = b_bishop_blue;
            end else if ((board_vga[active_square] == 4'b1100) &&
                         is_piece_pixel(b_rook_red, b_rook_green, b_rook_blue)) begin
                Red = b_rook_red;
                Green = b_rook_green;
                Blue = b_rook_blue;
            end else if ((board_vga[active_square] == 4'b1101) &&
                         is_piece_pixel(b_queen_red, b_queen_green, b_queen_blue)) begin
                Red = b_queen_red;
                Green = b_queen_green;
                Blue = b_queen_blue;
            end else if ((board_vga[active_square] == 4'b1110) &&
                         is_piece_pixel(b_king_red, b_king_green, b_king_blue)) begin
                Red = b_king_red;
                Green = b_king_green;
                Blue = b_king_blue;
            end else begin
                Red = cb_red;
                Green = cb_green;
                Blue = cb_blue;
            end
        end else if ((curr_player_vga == 1'b0) && (DrawY > 10'd420)) begin
            Red = 4'h0;
            Green = 4'h0;
            Blue = 4'hF;
        end else if ((curr_player_vga == 1'b1) && (DrawY < 10'd60)) begin
            Red = 4'h0;
            Green = 4'h0;
            Blue = 4'hF;
        end else begin
            Red = 4'hF;
            Green = 4'hF;
            Blue = 4'hF;
        end
    end

endmodule
