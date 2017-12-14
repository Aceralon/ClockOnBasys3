`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/21 13:08:16
// Design Name: 
// Module Name: minute
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


module minute(
    input logic clk1m,
    input logic reset,
    output logic [0:7] min_sig,
    output logic clk1h
    );
	
	parameter U = 9;
	parameter T = 5;
	parameter M = 59;
	
	logic [0:3] minU;
	logic [0:3] minT;
	logic [0:4] cnt;
	logic inclk1h;
	
	//minute units
	always_ff @ (posedge clk1m, posedge reset)
	begin
		if(reset)
		begin
			minU <= 0;
			minT <= 0;
		end
		else 
		begin
			if(minU < U)
				minU <= minU + 1;
			else
			begin                     //SEEMS DONE need to be checked
				minU <= 0;
				if(minT < T)
					minT <= minT + 1;
				else
					minT <= 0;
			end
		end
	end
	
	//create a 1h clk
	always_ff @ (posedge clk1m, posedge reset)
	begin
		if(reset)
		begin
			cnt <= 0;
			inclk1h <= 1;
		end
		else if(cnt < M)
			cnt <= cnt + 1;
		else
		begin
			cnt <= 0;
			inclk1h <= ~inclk1h;
		end
	end
	
	assign clk1h = inclk1h;
	assign min_sig = {minT, minU};
	
endmodule