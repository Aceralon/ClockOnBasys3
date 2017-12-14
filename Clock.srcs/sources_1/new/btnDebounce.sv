`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/21 15:19:39
// Design Name: 
// Module Name: btnDebounce
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


module btnDebounce(
	input logic clk190,
    input logic [0:3] btnIn,
    output logic [0:3] btnOut
    );
	
	logic [0:3] delay1;
	logic [0:3] delay2;
	logic [0:3] delay3;
	logic [0:3] delay4;
	
	always_ff @ (posedge clk190)
	begin
		delay1 <= btnIn;
		delay2 <= delay1;
		delay3 <= delay2;
		delay4 <= delay3;
	end
	
	assign btnOut = btnIn & delay1 & delay2 & delay3 & delay4;
	
endmodule