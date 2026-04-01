module chess_game_logic (
    input  logic [3:0] curr_board[63:0],
    input  logic       chess_click,
    input  logic [9:0] cursorX,
    input  logic [9:0] cursorY,
    input  logic       clk,
    input  logic       chess_reset,

    output logic       change_board,
    output logic [5:0] piece_board_addr,
    output logic [3:0] piece_change,
    output logic [5:0] hovered_val,
    output logic       hovered_val_OUB,
    output logic [5:0] pre_sel_val,
    output logic       highlight_border,
    output logic       legal_move,
    output logic [2:0] curr_state,
    output logic       curr_player
);

    localparam logic WHITE = 1'b0;
    localparam logic BLACK = 1'b1;

    localparam logic [2:0] GAME_START             = 3'b000;
    localparam logic [2:0] PIECE_TO_MOVE          = 3'b001;
    localparam logic [2:0] MOVE_LOCATION          = 3'b010;
    localparam logic [2:0] REPLACE_PIECE          = 3'b011;
    localparam logic [2:0] DISCARD_PREV_LOC_PIECE = 3'b100;

    logic [3:0] cursor_piece;
    logic [3:0] selected_piece;
    logic [3:0] horizontal_diff;
    logic [3:0] vertical_diff;

    assign highlight_border = (curr_state == MOVE_LOCATION);
    assign cursor_piece = curr_board[hovered_val];
    assign selected_piece = curr_board[pre_sel_val];

    assign horizontal_diff = (hovered_val[2:0] >= pre_sel_val[2:0])
        ? (hovered_val[2:0] - pre_sel_val[2:0])
        : (pre_sel_val[2:0] - hovered_val[2:0]);

    assign vertical_diff = (hovered_val[5:3] >= pre_sel_val[5:3])
        ? (hovered_val[5:3] - pre_sel_val[5:3])
        : (pre_sel_val[5:3] - hovered_val[5:3]);

    always_comb begin
        hovered_val = 6'd0;
        hovered_val_OUB = 1'b1;

        if ((cursorX < 10'd480) && (cursorY < 10'd480)) begin
            hovered_val = ((cursorY / 10'd60) * 6'd8) + (cursorX / 10'd60);
            hovered_val_OUB = 1'b0;
        end
    end

    always_ff @(posedge clk or posedge chess_reset) begin
        if (chess_reset) begin
            curr_state <= GAME_START;
            curr_player <= WHITE;
            pre_sel_val <= 6'd0;
            piece_board_addr <= 6'd0;
            piece_change <= 4'd0;
            change_board <= 1'b0;
        end else begin
            case (curr_state)
                GAME_START: begin
                    curr_state <= PIECE_TO_MOVE;
                    curr_player <= WHITE;
                    change_board <= 1'b0;
                    piece_board_addr <= 6'd0;
                    piece_change <= 4'd0;
                end

                PIECE_TO_MOVE: begin
                    change_board <= 1'b0;
                    if (chess_click && !hovered_val_OUB &&
                        (cursor_piece[3] == curr_player) &&
                        (cursor_piece[2:0] != 3'b000)) begin
                        curr_state <= MOVE_LOCATION;
                        pre_sel_val <= hovered_val;
                    end
                end

                MOVE_LOCATION: begin
                    change_board <= 1'b0;
                    if (chess_click) begin
                        if (!hovered_val_OUB &&
                            ((cursor_piece[3] != curr_player) || (cursor_piece[2:0] == 3'b000)) &&
                            legal_move) begin
                            curr_state <= REPLACE_PIECE;
                            piece_board_addr <= hovered_val;
                            piece_change <= selected_piece;
                            change_board <= 1'b1;
                        end else if (!hovered_val_OUB &&
                                     (cursor_piece[3] == curr_player) &&
                                     (cursor_piece[2:0] != 3'b000)) begin
                            pre_sel_val <= hovered_val;
                        end else begin
                            curr_state <= PIECE_TO_MOVE;
                        end
                    end
                end

                REPLACE_PIECE: begin
                    curr_state <= DISCARD_PREV_LOC_PIECE;
                    change_board <= 1'b1;
                    piece_board_addr <= pre_sel_val;
                    piece_change <= 4'd0;
                end

                DISCARD_PREV_LOC_PIECE: begin
                    curr_state <= PIECE_TO_MOVE;
                    change_board <= 1'b0;
                    piece_board_addr <= 6'd0;
                    piece_change <= 4'd0;
                    curr_player <= ~curr_player;
                end

                default: begin
                    curr_state <= GAME_START;
                    curr_player <= WHITE;
                    change_board <= 1'b0;
                    piece_board_addr <= 6'd0;
                    piece_change <= 4'd0;
                    pre_sel_val <= 6'd0;
                end
            endcase
        end
    end

    always_comb begin
        legal_move = 1'b0;

        case (selected_piece[2:0])
            3'b001: begin
                if (curr_player == WHITE) begin
                    if ((vertical_diff == 4'd2) &&
                        (horizontal_diff == 4'd0) &&
                        (pre_sel_val[5:3] == 3'b110) &&
                        (cursor_piece[2:0] == 3'b000) &&
                        (curr_board[pre_sel_val - 6'b001000][2:0] == 3'b000) &&
                        (hovered_val[5:3] < pre_sel_val[5:3])) begin
                        legal_move = 1'b1;
                    end else if ((vertical_diff == 4'd1) &&
                                 (horizontal_diff == 4'd0) &&
                                 (cursor_piece[2:0] == 3'b000) &&
                                 (hovered_val[5:3] < pre_sel_val[5:3])) begin
                        legal_move = 1'b1;
                    end else if ((vertical_diff == 4'd1) &&
                                 (horizontal_diff == 4'd1) &&
                                 (cursor_piece[3] == BLACK) &&
                                 (cursor_piece[2:0] != 3'b000) &&
                                 (hovered_val[5:3] < pre_sel_val[5:3])) begin
                        legal_move = 1'b1;
                    end
                end else begin
                    if ((vertical_diff == 4'd2) &&
                        (horizontal_diff == 4'd0) &&
                        (pre_sel_val[5:3] == 3'b001) &&
                        (cursor_piece[2:0] == 3'b000) &&
                        (curr_board[pre_sel_val + 6'b001000][2:0] == 3'b000) &&
                        (hovered_val[5:3] > pre_sel_val[5:3])) begin
                        legal_move = 1'b1;
                    end else if ((vertical_diff == 4'd1) &&
                                 (horizontal_diff == 4'd0) &&
                                 (cursor_piece[2:0] == 3'b000) &&
                                 (hovered_val[5:3] > pre_sel_val[5:3])) begin
                        legal_move = 1'b1;
                    end else if ((vertical_diff == 4'd1) &&
                                 (horizontal_diff == 4'd1) &&
                                 (cursor_piece[3] == WHITE) &&
                                 (cursor_piece[2:0] != 3'b000) &&
                                 (hovered_val[5:3] > pre_sel_val[5:3])) begin
                        legal_move = 1'b1;
                    end
                end
            end

            3'b010: legal_move = ((horizontal_diff == 4'd2) && (vertical_diff == 4'd1)) ||
                                 ((horizontal_diff == 4'd1) && (vertical_diff == 4'd2));

            3'b011: legal_move = (horizontal_diff == vertical_diff);

            3'b100: legal_move = (horizontal_diff == 4'd0) || (vertical_diff == 4'd0);

            3'b101: legal_move = (horizontal_diff == 4'd0) ||
                                 (vertical_diff == 4'd0) ||
                                 (horizontal_diff == vertical_diff);

            3'b110: legal_move = (horizontal_diff <= 4'd1) && (vertical_diff <= 4'd1);

            default: legal_move = 1'b0;
        endcase
    end

endmodule
