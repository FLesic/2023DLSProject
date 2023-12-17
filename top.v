module top(
    input clk,
    input PS2_clk,
    input PS2_data,
    input SW,
    input [3:0] BTN,
    input BTNX,
    output wire [3:0] AN,
    output wire [7:0] SEGMENT,
    output wire [7:0] LED,
    output hs,
    output vs,
    output [3:0]r,g,b
);
    wire [7:0] KeyBoard_Output;
    wire [3:0] dirMove;//depend on KeyBoard_Output
    reg [31:0] clkdiv;
    reg [11:0] vga_data;
    wire [9:0] col_addr;
    wire [8:0] row_addr;
    reg [2:0]gameState;
    PS2 My_PS2(.clk(clk), .rst_n_in(SW), .key_clk(PS2_clk), .key_data(PS2_data), .out(KeyBoard_Output));
    Clockdiv clk0(.clk(clk), .clkdiv(clkdiv));
    VGA My_VGA(.vga_clk(clkdiv[1]), .clrn(1), .color_in(vga_data), .row_addr(row_addr), .col_addr(col_addr),
        .r(r), .g(g), .b(b), .vs(vs), .hs(hs));
    Main MyGame(.clk(clkdiv[1]), .reset(BTN[0]), .vs(vs), .dirMove(dirMove), 
        .x(col_addr), .y(row_addr), .RGB(vga_data), .gameState(gameState));
