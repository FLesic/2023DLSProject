`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:38:19 12/14/2023 
// Design Name: 
// Module Name:    PMain 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PMain (
    input clk,//像素点刷新信号
    input reset,//复位信号
    input vs,//场信号
    input [3:0]dirMove,//0000 no move   0001 up 0010 down 0100 left 1000 right
    input [9:0]x,//当前扫面像素点x坐标
    input [8:0]y,//当前扫描像素点y坐标
    output reg [11:0] RGB,//输出当前扫描点的12位RGB向量
    output reg [1:0]gameState//状态机output - 00 - initial 01 - gaming start  10 - gaming 11 -win 
);
localparam width = 40;//每一个格子的宽度
localparam height = 40;//每一个格子的高度
reg [2:0] map[15:0][11:0];//二维数组 每一个地图元素是一个3位向量 
//一个对应于地图上的一个方块空间
//000 - empty;001 - wall;010 - Box;011 Termination;100 People  - Easy for paint
reg [4:0] Px = 6, Py = 3;//人物坐标(地图尺度)，对应于左上角像素点位置(Px*width,Py*heigth)
reg [4:0] Bx = 4, By = 6;//箱子坐标 (地图尺度)，对应于左上角像素点位置(Bx*width,By*height)
//TODO 更多箱子 Bx和By处理成数组
reg [4:0] Ex = 10, Ey = 5;//终点坐标(地图尺度)，对应于左上角像素点位置(Ex*width,Ey*height)
//TO 更多终点 Ex和Ey处理成数组
reg [4:0] Px_Next = 6, Py_Next = 3;//下一时刻人物位置
reg [4:0] Bx_Next = 4, By_Next = 3;//下一时刻箱子位置
reg stop = 1; //人物是否移动 0 - move  1 - stop
reg [1:0]Dir = 1;//人物朝向

initial 
begin
    gameState = 2'b00;
end
always @(posedge vs or negedge reset) //Dealing with stop and Dir
begin 
    if(!reset) begin
            stop = 1;
            Dir = 1;//default : down
        end
    else if(gameState == 2'b01 || gameState == 2'b10)
        case (dirMove)
            4'b0000 : stop = 1;
            4'b0001 : begin stop = 0; Dir = 0; end//Up
            4'b0010 : begin stop = 0; Dir = 1; end//Down
            4'b0100 : begin stop = 0; Dir = 2; end//Left
            4'b1000 : begin stop = 0; Dir = 3; end//Right
        endcase
end

always @(posedge vs or negedge reset) //Dealing with Current State with Sequential Logic
begin
    if(!reset) begin
        Px <= 6; Py <= 3;
        Bx <= 4; By <= 6;
    end
    else if(gameState == 2'b01 || gameState == 2'b10)
    begin
        Px <= Px_Next; Py_Next <= Py_Next;
        Bx <= Bx_Next; By <= By_Next;
    end
end
always @(posedge vs or negedge reset) //Dealing with Next State with Combinational Logic
begin
    if(!reset) begin
		map[0][0] = 1; map[0][1] = 1; map[0][2] = 1; map[0][3] = 1; map[0][4] = 1;
        map[0][5] = 1; map[1][0] = 1; map[1][5] = 1; map[1][6] = 1; map[1][7] = 1;
        map[1][8] = 1; map[1][9] = 1; map[1][10] = 1; map[1][11] = 1; map[2][0] = 1;
        map[2][3] = 1; map[2][11] = 1; map[3][0] = 1; map[3][3] = 1; map[3][5] = 1;

        map[3][11] = 1; map[4][0] = 1; map[4][5] = 1; map[4][11] = 1; map[5][0] = 1;
        map[5][7] = 1; map[5][8] = 1; map[5][9] = 1; map[5][10] = 1; map[5][11] = 1;
        map[6][0] = 1; map[6][1] = 1; map[6][4] = 1; map[6][5] = 1; map[6][6] = 1;
        map[6][11] = 1; map[7][1] = 1; map[7][2] = 1; map[7][11] = 1; map[8][2] = 1;

        map[8][11] = 1; map[9][1] = 1; map[9][2] = 1; map[9][4] = 1; map[9][6] = 1;
        map[9][8] = 1; map[9][10] = 1; map[9][11] = 1; map[10][0] = 1; map[10][1] = 1;
        map[10][4] = 1; map[10][6] = 1; map[10][8] = 1; map[10][10] = 1; map[10][11] = 1;
        map[11][0] = 1; map[11][4] = 1; map[11][6] = 1; map[11][8] = 1; map[11][11] = 1;

        map[12][0] = 1; map[12][11] = 1; map[13][0] = 1; map[13][1] = 1; map[13][4] = 1;
        map[13][10] = 1; map[13][11] = 1; map[14][1] = 1; map[14][4] = 1; map[14][7] = 1;
        map[14][8] = 1; map[14][9] = 1; map[14][10] = 1; map[14][11] = 1; map[15][1] = 1;
        map[15][2] = 1; map[15][3] = 1; map[15][4] = 1; map[15][5] = 1; map[15][6] = 1;
        map[15][7] = 1;

        map[4][6] = 2; map[6][3] = 4; map[10][5] = 3;
        Ex = 10; Ey = 5;//Termination
        Px_Next = 6; Py_Next = 3;
        Bx_Next = 4; By_Next = 6;
    end
    else if(gameState == 2'b01 || gameState == 2'b10)
    begin
        Px_Next = Px; Py_Next = Py;
        Bx_Next = Bx; By_Next = By;
        if(!stop) begin
            case (Dir)
                0:  begin //Up
                    if(Bx == Px && By == Py - 1) begin//移动方向上有箱子
                            //try to update 
                            By_Next = By - 1;
                            Py_Next = Py - 1;
                            if((map[Bx_Next][By_Next]==1 || Bx_Next < 0 || Bx_Next > 15 || By_Next < 0 || By_Next > 11)) begin//出界 或者 有墙挡住
                               By_Next = By;//还原
                               Py_Next = Py;
                            end
                        end
                    else begin//移动方向上没有箱子
                        Py_Next = Py - 1;
                        if((map[Px_Next][Py_Next]==1 || Px_Next < 0 || Px_Next > 15 || Py_Next < 0 || Py_Next > 11))
                            Py_Next = Py;
                    end   
                end
                1: begin //Down
                    if(Bx == Px && By == Py + 1) begin
                        By_Next = By + 1;
                        Py_Next = Py + 1;
                        if((map[Bx_Next][By_Next]==1 || Bx_Next < 0 || Bx_Next > 15 || By_Next < 0 || By_Next > 11)) begin
                            By_Next = By;
                            Py_Next = Py;
                        end
                    end
                    else begin
                        Py_Next = Py + 1;
                        if((map[Px_Next][Py_Next]==1 || Px_Next < 0 || Px_Next > 15 || Py_Next < 0 || Py_Next > 11))
                            Py_Next = Py;
                    end
                end
                2: begin //Left
                    if(Bx == Px - 1 && By == Py) begin
                        Bx_Next = Bx - 1;
                        Px_Next = Px - 1;
                        if((map[Px_Next][Py_Next]==1 || Px_Next < 0 || Px_Next > 15 || Py_Next < 0 || Py_Next > 11)) begin
                            Bx_Next = Bx;
                            Px_Next = Px;
                        end
                    end
                    else begin
                        Px_Next = Px - 1;
                        if((map[Px_Next][Py_Next]==1 || Px_Next < 0 || Px_Next > 15 || Py_Next < 0 || Py_Next > 11)) 
                            Px_Next = Px;
                    end
                end
                3: begin //right
                    if(Bx == Px + 1 && By == Py) begin
                        Bx_Next = Bx + 1;
                        Px_Next = Px + 1;
                        if((map[Bx_Next][By_Next]==1 || Bx_Next < 0 || Bx_Next > 15 || By_Next < 0 || By_Next > 11)) begin
                            Bx_Next = Bx;
                            Px_Next = Px;
                        end
                    end 
                    else begin
                        Px_Next = Px + 1;
                        if((map[Px_Next][Py_Next]==1 || Px_Next < 0 || Px_Next > 15 || Py_Next < 0 || Py_Next > 11))
                            Px_Next = Px;
                    end
                end
            endcase
        end
		  map[Px][Py] = 0; map[Bx][By] = 0;
		  map[Px_Next][Py_Next] = 4;  map[Bx_Next][By_Next] = 2;//Update the map
    end
end
always @(posedge vs or negedge reset)//Dealing with win
begin
    if(!reset) //reset
        gameState <= 2'b01;
    else if(Bx == Ex && By == Ey && gameState == 2'b10)//box fitting and gaming
        gameState <= 2'b11;
    else if(gameState == 2'b01 || gameState == 2'b10)//gaming
        gameState <= 2'b10;
end
always @(posedge clk)
begin
    case (gameState) begin
        2'b00: begin
        
        end
        2'b01,2'b10: begin

        end
        2'b11: begin

        end
    end
end
endmodule
