
module Clock_main(
	input  logic        main_clk,
	input  logic [0:4]  btnIn,
	input  logic [0:15] swi,
	output logic [0:6]  seg,
	output logic [0:3]  posi,
	output logic [0:15] led,
	output logic        dp,
	output logic        alarm
	);
	
	logic [0:31] clkCnt;
	logic [0:31] clkSW;
	logic [0:7]  clk;
	logic [0:1]  mode;
	logic [0:5]  sec;
	logic [0:5]  min;
	logic [0:5]  hrs;
	logic [0:5]  minAla;
	logic [0:5]  hrsAla;
	logic [0:5]  secSW;
	logic [0:5]  minSW;
	logic [0:5]  hrsSW;
	logic        startSW;
	logic [0:4]  btn;
	logic [0:3]  nowContent;
	logic        alarmShine;
	logic [0:1]  setting;
	
	initial      
		alarm = 0;
	
	clk U1(main_clk, startSW, mode, btn, secSW, minSW, hrsSW, clkSW, clk, clkCnt);
	
	button U2(clk, btnIn, btn);
	
	modeCtr U3(btn, mode);
	
	settingCtr U4(btn, setting);
	
	alarmClk U5(clkCnt, min, hrs, minAla, hrsAla, swi, mode, setting, alarm, alarmOn, led[0:7]);
	
	timeCount U6(clk, mode, setting, btn, sec, min, hrs, minAla, hrsAla);
	
	ledCtr U7(mode, setting, led[8:14]);
	
	swCtr U8(clkCnt, mode, btn, startSW);
	
	bcdTo7Seg U9(nowContent, seg);
	
	slideDisp U10(mode, setting, clkCnt, sec, min ,hrs, minAla, hrsAla, clkSW, secSW, minSW, hrsSW, clk, posi, nowContent, dp);
	
	assign led[15] = alarmOn;
	
endmodule


module clk(
	input  logic        main_clk,
	input  logic        startSW,
	input  logic [0:1]  mode,
	input  logic [0:4]  btn,
	output logic [0:5]  secSW,
	output logic [0:5]  minSW,
	output logic [0:5]  hrsSW,
	output logic [0:31] clkSW,
	output logic [0:7]  clk,
	output logic [0:31] clkCnt
	);
	
	//logic [0:31] clkCnt     = 32'b0;
	logic [0:31] clkCnt2    = 32'b0;
		
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
					begin
						secSW <= 0;
						if(minSW < 59)
							minSW <= minSW + 1;
						else
						begin
							minSW <= 0;
							if(hrsSW < 99)
								hrsSW <= hrsSW + 1;
							else
								hrsSW <= 0;
						end
					end
				end
			end
		end
		
		if(mode == 3 && btn[2])
		begin
			secSW <= 6'b0;
			minSW <= 6'b0;
			hrsSW <= 6'b0;
			clkCnt2 <= 32'b0;
			clkSW <= 32'b0;
		end
		
	end	
endmodule

module button(
	input  logic [0:7] clk,
	input  logic [0:4] btnIn,
	output logic [0:4] btn
	);
	
	logic [0:4]  delay1;
	logic [0:4]  delay2;
	logic [0:4]  delay3;
	logic [0:4]  delay4;
	
	//button debounce
	always_ff @ (posedge clk[6])
	begin
		delay1 <= btnIn;
        delay2 <= delay1;
        delay3 <= delay2;
        delay4 <= delay3;
	end
	
	assign btn = btnIn & delay1 & delay2 & delay3 & delay4;
	
endmodule

module modeCtr(
	input  logic [0:4] btn,
	output logic [0:1]  mode
	);
	
	initial
		mode <= 2'b0;
	
	always_ff @ (posedge btn[1])
		mode <= mode + 1;
	
endmodule

module settingCtr(
	input  logic [0:4] btn,
	output logic [0:1] setting
	);
	
	initial
		setting <= 2'b0;
	
	//setting on
	always_ff @ (posedge btn[3])
		if(setting < 2)
			setting <= setting + 1;
		else
			setting <= 0;
	
endmodule

module alarmClk(
	input  logic [0:31] clkCnt,
	input  logic [0:5]  min,
	input  logic [0:5]  hrs,
	input  logic [0:5]  minAla,
	input  logic [0:5]  hrsAla,
	input  logic [0:15] swi,
	input  logic [0:1]  mode,
	input  logic [0:1]  setting,
	output logic        alarm,
	output logic        alarmOn,
	output logic [0:7]  led       //实例化时需要修改为0-7的led
	);
	
	logic inalarmOn = 0;
	logic alarmShine = 0;
	
	always_ff @ (posedge clkCnt[20])
	begin
		if(inalarmOn && hrs == hrsAla && min == minAla  && !alarmShine)
		begin
			led[0:7] <= {hrsAla[2:5], minAla[2:5]};
			alarmShine <= 1;
			alarm <= 1;
		end
		
		if(alarmShine && swi[0:7] == {hrsAla[2:5], minAla[2:5]})
		begin
			led <= 8'b0000_0000;
			alarmShine <= 0;
			inalarmOn <= 0;
			alarm <= 0;
		end
		
		if(mode == 2 && setting > 0)
		begin
            inalarmOn <= 1;
			alarm <= 0;
		end
	end
	
	assign alarmOn = inalarmOn;
	
endmodule


module timeCount(
	input  logic [0:7] clk,
	input  logic [0:1] mode,
	input  logic [0:1] setting,
	input  logic [0:4] btn,
	output logic [0:5]  sec,
	output logic [0:5]  min,
	output logic [0:5]  hrs,
	output logic [0:5]  minAla,
	output logic [0:5]  hrsAla
	);
	
	//clock count part
	always_ff @ (posedge clk[7])
	begin
		if(clk[0:6] == 8'b1111_111)
			sec = sec + 1;
		
		
		if(clk[2:6] == 5'b11111)
		begin
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
				begin
					if(btn[0])
						minAla = (minAla + 1) % 60;
					else if(btn[4])
					begin
						minAla = minAla - 1;
						if(minAla >= 60)
							minAla = 59;
					end
				end
			end
			else if(setting == 2)
			begin
				if(mode == 0)
				begin
					if(btn[0])
						hrs = (hrs + 1) % 24;
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
						hrsAla = (hrsAla + 1) % 24;
					else if(btn[4])
						begin
							hrsAla = hrsAla - 1;
							if(hrsAla >= 24)
								hrsAla = 23;
						end
			end
		end
		
		//process time
		min = min + sec / 60;
		sec = sec % 60;
		hrs = hrs + min / 60;
		min = min % 60;
		hrs = hrs % 24;
		
		
	end
	
endmodule

module ledCtr(
	input  logic [0:1] mode,
	input  logic [0:1] setting,
	output logic [0:6] led   //lde的8-14位实例化时注意
	);
	
	//mode indicator
	always_comb
	begin
		case (mode)
			0 : led[3:6] <= 4'b0001;
			1 : led[3:6] <= 4'b0010;
			2 : led[3:6] <= 4'b0100;
			3 : led[3:6] <= 4'b1000;
		endcase
	end
	
	//setting indicator
	always_comb
	begin
		case (setting)
			0 : led[0:2] <= 3'b001;
			1 : led[0:2] <= 3'b010;
			2 : led[0:2] <= 3'b100;
			default : led[0:2] <= 3'b000;
        endcase
	end	
endmodule

module swCtr(
	input  logic [0:31] clkCnt,
	input  logic [0:1]  mode,
	input  logic [0:4]  btn,
	output logic        startSW
	);
	
	//stop watch contrl
	always_ff @ (posedge clkCnt[20])
		if(mode == 3)
		begin
			if(btn[0])
				startSW <= 1;
			else if(btn[4])
				startSW <= 0;
			else
				startSW <= startSW;
		end	
endmodule

module bcdTo7Seg(
	input  logic [0:3] nowContent,
	output logic [0:6] seg
	);
	
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
endmodule

module slideDisp(
	input  logic [0:1]  mode,
	input  logic [0:1]  setting,
	input  logic [0:31] clkCnt,
	input  logic [0:5]  sec,
	input  logic [0:5]  min,
	input  logic [0:5]  hrs,
	input  logic [0:5]  minAla,
	input  logic [0:5]  hrsAla,
	input  logic [0:31] clkSW,
	input  logic [0:5]  secSW,
	input  logic [0:5]  minSW,
	input  logic [0:5]  hrsSW,
	input  logic [0:7]  clk,
	output logic [0:3]  posi,
	output logic [0:3]  nowContent,
	output logic        dp
	);
	
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
			if(setting == 0)
			begin
				case (clkCnt[15:16])
					2'b00:
						begin
							posi <= 4'b0111;
							nowContent <= secSW / 10;
							dp <= 1;
						end
					2'b01:
						begin
							posi <= 4'b1011;
							nowContent <= secSW % 10;
							dp <= 1;
						end
					2'b10:
						begin
							posi <= 4'b1101;
							nowContent <= clkSW / 1000 % 10;
							dp <= 1;
						end
					2'b11:
						begin
							posi <= 4'b1110;
							nowContent <= clkSW /100 % 10;
							dp <= clkSW /1000 % 10;
						end
					default:
							posi <= 4'b1111;
				endcase
			end
			else if(setting == 1)
			begin
				case (clkCnt[15:16])
					2'b00:
						begin
							posi <= 4'b0111;
							nowContent <= minSW / 10;
							dp <= 1;
						end
					2'b01:
						begin
							posi <= 4'b1011;
							nowContent <= minSW % 10;
							dp <= 1;
						end
					2'b10:
						begin
							posi <= 4'b1101;
							nowContent <= secSW / 10;
							dp <= 1;
						end
					2'b11:
						begin
							posi <= 4'b1110;
							nowContent <= secSW % 10;
							dp <= clkSW /1000 % 10;
						end
					default:
							posi <= 4'b1111;
				endcase
			end
			else if(setting == 2)
			begin
				case (clkCnt[15:16])
					2'b00:
						begin
							posi <= 4'b0111;
							nowContent <= hrsSW / 10;
							dp <= 1;
						end
					2'b01:
						begin
							posi <= 4'b1011;
							nowContent <= hrsSW % 10;
							dp <= 1;
						end
					2'b10:
						begin
							posi <= 4'b1101;
							nowContent <= minSW / 10;
							dp <= 1;
						end
					2'b11:
						begin
							posi <= 4'b1110;
							nowContent <= minSW % 10;
							dp <= clkSW /1000 % 10;
						end
					default:
							posi <= 4'b1111;
				endcase
			end
		end
	end	
endmodule