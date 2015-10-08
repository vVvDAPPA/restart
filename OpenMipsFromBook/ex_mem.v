`include "defines.v"

module ex_mem(
	input		wire					clk,
	input		wire					rst,
	
	//来自控制模块的信息
	input		wire[5:0]			stall,
	
	//累乘加，累乘减指令增加接口
	input		wire[`DoubleRegBus]	hilo_i,
	input		wire[1:0]			cnt_i,
	
	output	reg[`DoubleRegBus]	hilo_o,
	output	reg[1:0]				cnt_o,
	
	//从执行阶段传递过来的信息
	input		wire[`RegAddrBus]	ex_wd,
	input		wire					ex_wreg,
	input		wire[`RegBus]		ex_wdata,
	input		wire[`RegBus]		ex_hi,
	input		wire[`RegBus]		ex_lo,
	input		wire					ex_whilo,
	
	//送到访存阶段的信息
	output	reg[`RegAddrBus]	mem_wd,
	output	reg					mem_wreg,
	output	reg[`RegBus]		mem_wdata,
	output	reg[`RegBus]		mem_hi,
	output	reg[`RegBus]		mem_lo,
	output	reg					mem_whilo
);

//在流水线执行阶段暂停时，将输入信号hilo_i通过hilo_o送出，cnt_i通过cnt_o送出，其余时刻，hilo_o和cnt_o为0

always	@	(posedge	clk)	begin
	if(rst == `RstEnable)	begin
		mem_wd		<=	`NOPRegAddr;
		mem_wreg		<=	`WriteDisable;
		mem_wdata	<=	`ZeroWord;
		mem_hi		<= `ZeroWord;
		mem_lo		<= `ZeroWord;
		mem_whilo	<= `WriteDisable;
		hilo_o		<= {`ZeroWord, `ZeroWord};
		cnt_o			<= 2'b00;
	end	else
	if(stall[3] == `Stop && stall[4] == `NoStop)	begin
		mem_wd		<= `NOPRegAddr;
		mem_wreg		<= `WriteDisable;
		mem_wdata	<= `ZeroWord;
		mem_hi		<=	`ZeroWord;
		mem_lo		<= `ZeroWord;
		mem_whilo	<= `WriteDisable;
		hilo_o		<= hilo_i;
		cnt_o			<= cnt_i;
	end	else
	if(stall[3] == `NoStop)begin
		mem_wd		<=	ex_wd;
		mem_wreg		<=	ex_wreg;
		mem_wdata	<=	ex_wdata;
		mem_hi		<= ex_hi;
		mem_lo		<= ex_lo;
		mem_whilo	<= ex_whilo;
		hilo_o		<= {`ZeroWord, `ZeroWord};
		cnt_o			<= 2'b00;
	end	else	begin
		hilo_o		<= hilo_i;
		cnt_o			<= cnt_i;
	end
end

endmodule