`timescale 1ns/1ns

module test;

reg             PCLK, PRESETn, Trans, ReadOrWrite;
reg  [31:0]     Write_Address, INPUT_DATA, Read_Address;
wire [31:0]     OUT_DATA;
reg  [3:0]      Input_STRB;
wire            PSLVERR;
wire [3:0]      PSTRB;

APB_Protocol dut_c(  
  PCLK,
  PRESETn,
  Trans,
  ReadOrWrite,
  Write_Address,
  INPUT_DATA,
  Read_Address,
  PSLVERR, 
  OUT_DATA,
  Input_STRB,
  PSTRB
);

integer i, j;
initial
begin
  PCLK <= 0;
  forever #5 PCLK = ~PCLK;
end

initial
begin
  PRESETn<=0; Trans<=0; ReadOrWrite = 0;
              @(posedge PCLK)      PRESETn = 1;         
              @(posedge PCLK)      Trans = 1;
    repeat(2) @(posedge PCLK);
              @(negedge PCLK)      Write_slave1;        
    repeat(3) @(posedge PCLK);     Write_slave2;                                 
              @(posedge PCLK);    
    repeat(2) @(posedge PCLK);    
    repeat(2) @(posedge PCLK);
              @(posedge PCLK)     ReadOrWrite = 1; PRESETn <= 0; Trans <= 0; 
              @(posedge PCLK)     PRESETn = 1;
    repeat(3) @(posedge PCLK)     Trans = 1;         
    repeat(2) @(posedge PCLK)     Read_slave1;          
    repeat(3) @(posedge PCLK);    Read_slave2;
    repeat(3) @(posedge PCLK);                         
    repeat(4) @(posedge PCLK);
    $finish;
end

task Write_slave1;
  begin
    Trans =1;
    Write_Address = 32'd12;
    INPUT_DATA = 32'd11;
  end
endtask

task Write_slave2;
  begin
  end
endtask

task Read_slave1;
  begin 
    Read_Address = 32'd12;
  end
endtask


task Read_slave2;
  begin 
  end
endtask

endmodule