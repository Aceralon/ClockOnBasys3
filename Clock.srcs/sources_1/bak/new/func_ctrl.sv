`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/21 14:10:12
// Design Name: 
// Module Name: function
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


module func_ctrl(
    input logic clk1s,
    input logic clk1m,
    input logic clk1h,
    input logic reset,
	input logic changeBtn,
	input logic setBtn,
    input logic [0:7] sec_sig,
    input logic [0:7] min_sig,
    input logic [0:7] hour_sig,
    output logic [0:15] disp_sig,
	output logic toS,
	output logic toM,
	output logic toH
    );
	
	logic dspMode;
	logic [0:1] setMode;
	
	// change clock display mode (HH/MM or MM/SS)
	always_ff @ (posedge changeBtn, posedge reset)
	begin
		if(reset)
			dspMode <= 0;
		else if(setMode == 0)
			dspMode <= ~dspMode;		
	end
	
	always_comb
		if(dspMode == 0)
			disp_sig <= {hour_sig, min_sig};
		else
			disp_sig <= {min_sig, sec_sig};
	
	//change setBtn mode from no set, min set, hour set
	always_ff @ (posedge setBtn, posedge reset)
	begin
		if(reset)
			setMode <= 0;
		else
			setMode <= setMode + 1;
	end
	
	always_comb
		case (setMode)
			0:	begin
				toS <= clk1s;
				toM <= clk1m;
				toH <= clk1h;
				end
			1:	begin
				toS <= changeBtn;
				toM <= clk1m;
				toH <= clk1h;
				//dspMode <= 1;
				end
			2:	begin
				toS <= clk1s;
				toM <= changeBtn;
				toH <= clk1h;
				end
			3: begin
				toS <= clk1s;
				toM <= clk1m;
				toH <= changeBtn;
				//dspMode <= 0;
				end
		endcase
		
		
				
endmodule