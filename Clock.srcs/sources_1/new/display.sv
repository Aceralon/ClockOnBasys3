`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/12/20 14:18:41
// Design Name:
// Module Name: display
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


module display(
    input logic reset,
    input logic clk190,
	input logic clk1s,
    input logic [0:15] content,
    output logic [0:6] seg,
    output logic [0:3] position,
    output logic dp
    );

	logic [0:1] cnt;
    logic [0:3] nowContent;
    logic [0:3] en;
	
	//decide the content to read
	always_comb
		case (cnt)
			0 : nowContent <= content[0:3];
			1 : nowContent <= content[4:7];
			2 : nowContent <= content[8:11];
			3 : nowContent <= content[12:15];
			default : nowContent <= content[0:3];
		endcase
	
	//decode to 7seg
	always_comb
		case (nowContent)
			0: seg <= 7'b0000001;
            1: seg <= 7'b1001111;
            2: seg <= 7'b0010010;
            3: seg <= 7'b0000110;
            4: seg <= 7'b1001100;
            5: seg <= 7'b0100100;
            6: seg <= 7'b0100000;
            7: seg <= 7'b0001111;
            8: seg <= 7'b0000000;
            9: seg <= 7'b0000100;
            default: seg <= 7'b1111111;
		endcase
	
	//the position of output
	always_comb
	begin
		position = 4'b1111;
		if(!reset)
            position[cnt] = 0;
	end
		
	//count 4
	always_ff @ (posedge clk190, posedge reset)
	begin
		if(reset)
			cnt <= 0;
		else
			cnt <= cnt + 1;
	end
    
	//second dot contrl
	always_comb
		if(cnt == 3)
			dp <= clk1s;
		else
			dp <= 1;
	
endmodule