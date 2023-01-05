`timescale 1ns / 1ps
`include "GPIO.v"
module GPIO_TB;

	reg          PRESETn; 		
	reg          PCLK;			
	reg          PSEL;			
	reg          PENABLE;		
	reg  [31:0]  PADDR;			
	reg          PWRITE;			
	reg  [3:0]   PSTRB;			
	reg  [31:0]  PWDATA;			
	reg  [7:0]	 GPIO_DATA_IN;	
	wire [7:0]	 GPIO_DATA_OUT;	
	wire [31:0]  PRDATA;			
	wire         PREADY;			

  GPIO test (
    .PRESETn(PRESETn),
    .PCLK(PCLK),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PADDR(PADDR),
    .PWRITE(PWRITE),
    .PSTRB(PSTRB),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .GPIO_DATA_IN(GPIO_DATA_IN),
	.GPIO_DATA_OUT(GPIO_DATA_OUT)
  );
  
  initial begin
    PCLK = 0;
  end
  
  //clock generator
  always begin
    #5 PCLK = ~PCLK;
  end
  
   //initialize inputs
 initial begin
	PRESETn = 0;
    #5;
    PRESETn = 1;
	PSEL    <= 1;		
	PENABLE <= 1;
	
	#5
	@(posedge PCLK);
	#5 
	@(posedge PCLK)
	begin
	PADDR   = {32{1'b0}};
	PWRITE  = 1;
	PSTRB   = 4'b0001;
	PWDATA  = 32'hAF78CF55;        	//  ==> CONTROL = 01010101
	end

	#5
	@(posedge PCLK);
	@(posedge PCLK)
	begin
	PADDR   = {32{1'b1}};
	PWRITE  = 1;
	PSTRB   = 4'b0001;
	PWDATA  = 32'hCCAAFF44;       // ==> 0100 0100 --> 0100 0100 -->     44
	end

	#5
	@(posedge PCLK);										
	@(posedge PCLK);
	@(posedge PCLK)
	begin
	PADDR   = {32{1'b1}};
	PWRITE  = 0;
	PSTRB   = 4'b0000;
	GPIO_DATA_IN  = 8'h5F;        // ==> 0101 1111 --> 0000 1010  --> 10 == a
	end




	#5
	@(posedge PCLK);
	@(posedge PCLK);
	@(posedge PCLK)
	begin
	PADDR   = {32{1'b0}};
	PWRITE  = 1;
	PSTRB   = 4'b0010;
	PWDATA  = 32'hAF7888CF;        //    ==> CONTROL = 1000 1000
	end
	
	#5
	@(posedge PCLK);
	@(posedge PCLK);
	@(posedge PCLK)
	begin
	PADDR   = {32{1'b1}};
	PWRITE  = 1;
	PSTRB   = 4'b0010;
	PWDATA  = 32'hCCAA85FF;        // ==> 1000 0101 --> 1000 0000 --> 80
	end	
    end
endmodule