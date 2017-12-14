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
	input  logic        main_clk,
	input  logic [0:4]  btnIn,
	input  logic [0:15] swi,
	output logic [0:6]  seg,
	output logic [0:3]  posi,
	output logic [0:15] led,
	output logic        dp
	);
	
	logic [0:4]  delay1     = 5'b0;
	logic [0:4]  delay2     = 5'b0;
	logic [0:4]  delay3     = 5'b0;
	logic [0:4]  delay4     = 5'b0;
	logic [0:31] clkCnt     = 32'b0;
	logic [0:31] clkCnt2    = 32'b0;
	logic [0:31] clkSW      = 32'b0;
	logic [0:7]  clk        = 8'b0;
	logic [0:1]  mode       = 2'b0;
	logic [0:5]  sec        = 6'b0;
	logic [0:5]  min        = 6'b0;
	logic [0:5]  hrs        = 6'b0;
	logic [0:5]  minAla     = 6'b0;
	logic [0:5]  hrsAla     = 6'b0;
	logic [0:5]  secSW      = 6'b0;
	logic        startSW    = 0;
	logic [0:4]  btn;
	logic [0:3]  nowContent = 4'b0;
	logic        alarmOn    = 0;
	logic        alarmShine = 0;
	logic [0:1]  setting    = 0;
	
	//create clock
	always_ff @ (posedge main_clk)
	begin
		if(clkCnt < 39_0625)
			clkCnt <= clkCnt + 1;
		else
		begin
			clk <= clk + 1;  //256Hz sig
			clkCnt <= 32'b0;
		end
		
		if(startSW)
		begin
			if(clkCnt2 < 10000)
				clkCnt2 <= clkCnt2 + 1;
			else
			begin
				clkCnt2 <= 0;
				if(clkSW < 10000)
					clkSW <= clkSW + 1;
				else
				begin
					clkSW <= 0;
					if(secSW < 59)
						secSW <= secSW + 1;
					else
						secSW <= 0;
				end
			end
		end
		
		if(mode == 3 && setting == 0)
		begin
			secSW <= 6'b0;
			clkCnt2 <= 32'b0;
			clkSW <= 32'b0;
		end
		
	end
	
	//mode contrl
	always_ff @ (posedge btn[1])
		mode <= mode + 1;
	
	//alarm clock bright
	always_comb
		if(alarmOn && hrs == hrsAla && min == minAla)
		begin
			led[0:7] <= {hrsAla, minAla};
			alarmShine <= 1;
		end
		else if(alarmShine)
			if(swi[0:7] == led[0:7])
			begin
				led[0:7] <= 8'b0000_0000;
				alarmShine <= 0;
			end
		else
			led[0:7] <= 8'b0000_0000;
			
	
	//bcd to 7seg
	always_comb
	begin
		case (nowContent)
			0:       seg <= 7'b0000001;
            1:       seg <= 7'b1001111;
            2:       seg <= 7'b0010010;
            3:       seg <= 7'b0000110;
            4:       seg <= 7'b1001100;
            5:       seg <= 7'b0100100;
            6:       seg <= 7'b0100000;
            7:       seg <= 7'b0001111;
            8:       seg <= 7'b0000000;
            9:       seg <= 7'b0000100;
            default: seg <= 7'b1111111;
		endcase
	end
	
	always_ff @ (posedge clk[7])
	begin
	   
		if(clk == 8'b1111_1111)
			sec = sec + 1;
		
		
		
		if(setting == 1)
		begin
			if(mode == 0)
			begin
				if(btn[0])
					min = (min + 1) % 60;
				else if(btn[4])
				begin
					min = min - 1;
					if(min >= 60)
						min = 59;
				end
			end
			else if(mode == 1)
			begin
				if(btn[0])
					sec = (sec + 1) % 60;
				else if(btn[4])
				begin
					sec = sec - 1;
					if(sec >= 60)
						sec = 59;
				end
			end
			else if(mode == 2)
			if(btn[0])
					minAla = (minAla + 1) % 60;
				else if(btn[4])
				begin
					minAla = minAla - 1;
					if(minAla >= 60)
						minAla = 59;
				end
			else if(mode == 3)
			begin
				startSW = 1;
			end
		end
		else if(setting == 2)
		begin
			if(mode == 0)
			begin
				if(btn[0])
					hrs = (hrs + 1) % 60;
				else if(btn[4])
				begin
					hrs = hrs - 1;
					if(hrs >= 24)
						min = 23;
				end
			end
			else if(mode == 1)
			begin
				if(btn[0])
					min = (min + 1) % 60;
				else if(btn[4])
				begin
					min = min - 1;
					if(min >= 60)
						min = 59;
				end
			end
			else if(mode == 2)
			if(btn[0])
					hrsAla = (hrsAla + 1) % 60;
				else if(btn[4])
				begin
					hrsAla = hrsAla - 1;
					if(hrsAla >= 24)
						hrsAla = 23;
				end
						else if(mode == 3)
			begin
				startSW = 0;
			end
		end
		
		
		//process time
		min = min + sec / 60;
		hrs = hrs + min / 60;
		sec = sec % 60;
		min = min % 60;
		hrs = hrs % 24;
		
		
	end
	
	//slide display content
	always_comb
	begin
		if(mode == 0) //clock HH/MM
		begin
			case (clkCnt[15:16])
				2'b00:
					begin
						posi <= 4'b0111;
						nowContent <= hrs / 10;
						dp <= 1;
					end
				2'b01:
					begin
						posi <= 4'b1011;
						nowContent <= hrs % 10;
						dp <= 1;
					end
				2'b10:
					begin
						posi <= 4'b1101;
						nowContent <= min / 10;
						dp <= 1;
					end
				2'b11:
					begin
						posi <= 4'b1110;
						nowContent <= min % 10;
						dp <= clk[0];  //display second
					end
				default:
					begin
						posi <= 4'b1111;
						dp <= 1;
					end
			endcase
		end
		else if(mode == 1)  //clock MM/SS
		begin
			case (clkCnt[15:16])
				2'b00:
					begin
						posi <= 4'b0111;
						nowContent <= min / 10;
						dp <= 1;
					end
				2'b01:
					begin
						posi <= 4'b1011;
						nowContent <= min % 10;
						dp <= 1;
					end
				2'b10:
					begin
						posi <= 4'b1101;
						nowContent <= sec / 10;
						dp <= 1;
					end
				2'b11:
					begin
						posi <= 4'b1110;
						nowContent <= sec % 10;
						dp <= clk[0];  //display second
					end
				default:
					begin
						posi <= 4'b1111;
						dp <= 1;
					end
			endcase			
		end
		else if(mode == 2) //alram clock
		begin
			dp <= 1;
			case (clkCnt[15:16])
				2'b00:
					begin
						posi <= 4'b0111;
						nowContent <= hrsAla / 10;						
					end
				2'b01:
					begin
						posi <= 4'b1011;
						nowContent <= hrsAla % 10;
					end
				2'b10:
					begin
						posi <= 4'b1101;
						nowContent <= minAla / 10;
					end
				2'b11:
					begin
						posi <= 4'b1110;
						nowContent <= minAla % 10;
					end
				default:
						posi <= 4'b1111;
			endcase
		end
		else if(mode == 3) //stop atch
		begin
			dp <= 1;
			case (clkCnt[15:16])
				2'b00:
					begin
						posi <= 4'b0111;
						nowContent <= secSW / 10;						
					end
				2'b01:
					begin
						posi <= 4'b1011;
						nowContent <= secSW % 10;
					end
				2'b10:
					begin
						posi <= 4'b1101;
						nowContent <= clkSW / 1000 % 10;
					end
				2'b11:
					begin
						posi <= 4'b1110;
						nowContent <= minAla /100 % 10;
					end
				default:
						posi <= 4'b1111;
			endcase
		end
	end
	
	//button debounce
	always_ff @ (posedge clk[6])
	begin
		delay1 <= btnIn;
        delay2 <= delay1;
        delay3 <= delay2;
        delay4 <= delay3;
	end
	
	//setting on
	always_ff @ (posedge btn[3])
		if(setting < 2)
			setting <= setting + 1;
		else
			setting <= 0;
	
	assign btn = btnIn & delay1 & delay2 & delay3 & delay4;
	assign led[15] = alarmOn;
    
endmodule