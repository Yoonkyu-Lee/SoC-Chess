module mouse_cursor (
    input  logic       Reset,
    input  logic       frame_clk,
    input  logic [7:0] usb_delta_x,
    input  logic [7:0] usb_delta_y,

    output logic [9:0] CursorX,
    output logic [9:0] CursorY,
    output logic [9:0] CursorSize
);

    localparam logic [9:0] CURSOR_X_CENTER = 10'd320;
    localparam logic [9:0] CURSOR_Y_CENTER = 10'd240;
    localparam logic [9:0] CURSOR_X_MIN    = 10'd0;
    localparam logic [9:0] CURSOR_X_MAX    = 10'd639;
    localparam logic [9:0] CURSOR_Y_MIN    = 10'd0;
    localparam logic [9:0] CURSOR_Y_MAX    = 10'd479;

    logic signed [10:0] signed_delta_x;
    logic signed [10:0] signed_delta_y;
    logic signed [10:0] next_cursor_x;
    logic signed [10:0] next_cursor_y;

    assign CursorSize = 10'd4;
    assign signed_delta_x = $signed({usb_delta_x[7], usb_delta_x});
    assign signed_delta_y = $signed({usb_delta_y[7], usb_delta_y});
    assign next_cursor_x = $signed({1'b0, CursorX}) + signed_delta_x;
    assign next_cursor_y = $signed({1'b0, CursorY}) + signed_delta_y;

    always_ff @(posedge frame_clk) begin
        if (Reset) begin
            CursorX <= CURSOR_X_CENTER;
            CursorY <= CURSOR_Y_CENTER;
        end else begin
            if (next_cursor_x < $signed({1'b0, CURSOR_X_MIN})) begin
                CursorX <= CURSOR_X_MIN;
            end else if (next_cursor_x > $signed({1'b0, CURSOR_X_MAX})) begin
                CursorX <= CURSOR_X_MAX;
            end else begin
                CursorX <= next_cursor_x[9:0];
            end

            if (next_cursor_y < $signed({1'b0, CURSOR_Y_MIN})) begin
                CursorY <= CURSOR_Y_MIN;
            end else if (next_cursor_y > $signed({1'b0, CURSOR_Y_MAX})) begin
                CursorY <= CURSOR_Y_MAX;
            end else begin
                CursorY <= next_cursor_y[9:0];
            end
        end
    end

endmodule
