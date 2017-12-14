`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/21 08:35:45
// Design Name: 
// Module Name: second
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


module second(
    input logic clk1s,
    input logic reset,
    output logic [0:7] sec_sig,
	output logic clk1m
    );
	
	parameter U = 9;
	parameter T = 5;
	parameter M = 29;
	
	logic [0:3] secU;
	logic [0:3] secT;
	logic [0:4] cnt;

	//second units
	always_ff @ (posedge clk1s, posedge reset)
	begin
		if(reset)
		begin
			secU <= 0;
			secT <= 0;
		end
		else 
		begin
			if(secU < U)
				secU <= secU + 1;
			else
			begin                     //SEEMS DONE need to be checked
				secU <= 0;
				if(secT < T)
					secT <= secT + 1;
				else
					secT <= 0;
			end
		end
	end
	
	//create a 1m clk
	always_ff @ (posedge clk1s, posedge reset)
	begin
		if(reset)
		begin
			cnt <= 0;
			clk1m <= 0;
		end
		else if(cnt < M)
		begin
			cnt <= cnt + 1;
			clk1m <= 0;
		end
		else
		begin
			cnt <= 0;
			clk1m <= 1;
		end
	end
	
	assign sec_sig = {secT, secU};
	
endmodule