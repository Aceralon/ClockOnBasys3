`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/20 09:01:00
// Design Name: 
// Module Name: Clock_main
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

module Clock_main(
	input logic main_clk,
	input logic [0:4] btn,
	output logic [0:6] seg,
	output logic [0:3] posi,
	output logic dp,
	output logic [0:3] pos
	);
	
	logic reset;	
	assign reset = btn[4];
	
	logic clk190;
	logic clk1s;
	
	clk_div clkGen (
		.main_clk(main_clk),
		.reset(reset),
		.clk190(clk190),
		.clk1s(clk1s)
		);
	
	logic [0:3] btnOut;
	
	btnDebounce debounce (
		.clk190(clk190),
		.btnIn(btn[0:3]),
		.btnOut(btnOut)
	);
	
	logic changeBtn;
	logic setBtn;
	assign changeBtn = btnOut[3];
	assign setBtn = btnOut[2];
	
	logic [0:7] sec_sig;
	logic clk1m;
	
	logic [0:15] disp_sig;
	logic toS;
	logic toM;
	logic toH;
	
	logic [0:7] hour_sig;
	
    logic [0:7] min_sig;
    logic clk1h;
	
	func_ctrl functionCtrl(
		.clk1s(clk1s),
		.clk1m(clk1m),
		.clk1h(clk1h),
		.reset(reset),
		.changeBtn(changeBtn),
		.setBtn(setBtn),
		.sec_sig(sec_sig),
		.min_sig(min_sig),
		.hour_sig(hour_sig),
		.disp_sig(disp_sig),
		.toS(toS),
		.toM(toM),
		.toH(toH)
	);
	
	second  secGen (
		.clk1s(toS),
		.reset(reset),
		.sec_sig(sec_sig),
		.clk1m(clk1m)
	);
	
	minute minGen (
		.clk1m(toM),
		.reset(reset),
		.min_sig(min_sig),
		.clk1h(clk1h)
		);
	
	hour hourGen (
		.clk1h(toH),
		.reset(reset),
		.hour_sig(hour_sig)
	);

	display displayPart(
		.reset(reset),
		.clk190(clk190),
		.clk1s(clk1s),
		.content(disp_sig),
		.seg(seg),
		.position(posi),
		.dp(dp)
	);
	
	assign pos = posi;

endmodule