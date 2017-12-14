`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/20 09:25:41
// Design Name: 
// Module Name: clk_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_div(
    input logic main_clk,
    input logic reset,
    output logic clk190,
    output logic clk1s
    );
    
    parameter N = 49999999;
    logic [0:24] cnt1;
    logic [0:29] cnt2;
    logic inclk1s;
    
    always_ff @ (posedge main_clk, posedge reset) 
    begin
        if(reset)
        begin
            cnt1 <= 0;
            cnt2 <= 0;
            inclk1s <= 0;
        end
        else
        begin
            cnt1 <= cnt1 + 1;
            if(cnt2 < N)
            begin
                cnt2 <= cnt2 + 1;
            end
            else
            begin
                inclk1s <= ~inclk1s;
                cnt2 <= 0;
            end
        end
    end
    
    assign clk190 = cnt1[8];
    assign clk1s = inclk1s;
    
endmodule
