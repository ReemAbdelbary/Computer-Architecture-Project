`include "master.v"
`include "slave1.v"
`include "slave2.v"
`timescale 1ns/1ns

module APB_Protocol(
	input		 	PCLK, PRESETn, Trans, ReadOrWrite,
	input [31:0] 	Write_Address,
	input [31:0]	INPUT_DATA,
	input [31:0] 	Read_Address,
	output 			PSLVERR, 
	output [31:0]	OUT_DATA,
	input  [3:0] 	Input_STRB,
	output [3:0]  	PSTRB
);

wire [31:0]			PWDATA, PRDATA, PRDATA1, PRDATA2, PADDR;
wire				PREADY, PREADY1, PREADY2, PENABLE, PSEL1, PSEL2, PWRITE;
assign 				PREADY = PADDR[31] ? PREADY2 : PREADY1 ;
assign 				PRDATA = ReadOrWrite ? (PADDR[31] ? PRDATA2 : PRDATA1) : 32'dx ;

master_bridge dut_mas(
	Write_Address, Read_Address, INPUT_DATA, PRDATA, PRESETn, PCLK, ReadOrWrite, Trans, PREADY,
	PSEL1, PSEL2, PENABLE, PADDR, PWRITE, PWDATA, OUT_DATA, PSLVERR, Input_STRB, PSTRB
); 


slave1 dut1(  PCLK,PRESETn, PSEL1,PENABLE,PWRITE, PADDR[31:0],PWDATA, PRDATA1, PREADY1,PSTRB );
slave2 dut2(  PCLK,PRESETn, PSEL2,PENABLE,PWRITE, PADDR[31:0],PWDATA, PRDATA2, PREADY2,PSTRB );

endmodule