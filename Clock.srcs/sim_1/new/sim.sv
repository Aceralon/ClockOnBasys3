`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/21 16:45:56
// Design Name: 
// Module Name: sim
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


module sim(
    );
    
    logic clk = 0;
    always
        #5 clk = ~clk;
    
    logic [0:4] btn;
    logic [0:15] swi;
    
    assign swi = 16'b0;
    
   // logic [0:15] content = 16'h1234;
    
    assign btn[0:4] = 5'b0000; 
    
    logic [0:6] seg;
    logic [0:3] position;
    logic dp;
    logic [0:15] led;
    logic [0:7] clkk;
    
    Clock_main U(
        .main_clk(clk),
        .btnIn(btn),
        .swi(swi),
        .seg(seg),
        .posi(position),
        .led(led),
        .dp(dp),
        .clkk(clkk)
        );
    
endmodule