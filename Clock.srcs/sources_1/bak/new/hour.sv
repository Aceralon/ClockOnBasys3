`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/12/21 13:17:07
// Design Name:
// Module Name: hour
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


module hour(
    input clk1h,
    input reset,
    output [0:7] hour_sig
    );

	parameter U1 = 9;
	parameter U2 = 3;
	parameter T = 2;

	logic [0:3] hourU;
	logic [0:3] hourT;

	always_ff @ (posedge clk1h, posedge reset)
	begin
		if(reset)
		begin
			hourU <= 0;
			hourT <= 0;
		end
		else 
		begin
			if(hourT < T)
			begin
				if(hourU < U1)
					hourU <= hourU + 1;
				else
				begin
					hourU <= 0;
					hourT <= hourT + 1;
				end
			end
			else
			begin
				if(hourU < U2)
					hourU <= hourU + 1;
				else
				begin
					hourU <= 0;
					hourT <= 0;
				end
			end
		end	
	end
	
	assign hour_sig = {hourT, hourU};

endmodule