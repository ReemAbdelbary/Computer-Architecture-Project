module GPIO (
  input                   PCLK,
  input                   PRESETn, 					// active low 
  input                   PSEL,
  input                   PENABLE, 					// active high
  input                   PWRITE, 					
  output reg  		      PREADY,						// active high
  input     	[3:0] 	  PSTRB,
  input      	[31:0] 	  PADDR,
  output reg 	[31:0] 	  PRDATA, 					// return to the bus 
  input      	[31:0] 	  PWDATA,						// data from CPU
  input  wire	[7:0]	  GPIO_DATA_IN,
  output reg	[7:0]	  GPIO_DATA_OUT
);
	
	reg [7:0] control 		= 8'b00			;
	reg [1:0] NEXT_STATE					;
	reg [1:0] IDLE 							;
	reg [1:0] SETUP 						;
	reg [1:0] ACCESS						;
	reg [7:0] MASTER_DATA;			// 8 bits from STRP
	
	initial begin
		IDLE 	= 2'b00;
		SETUP 	= 2'b01;
		ACCESS	= 2'b10;
		NEXT_STATE = IDLE;
	end
	
	always @(posedge PCLK) begin
		if(PSEL)begin
			if(!PRESETn) begin
				NEXT_STATE = IDLE;
			end
			else begin
				case(NEXT_STATE) 
					IDLE: begin
						PREADY=1'b0;
						if(PENABLE) begin
							NEXT_STATE = SETUP;
						end
						else begin
							NEXT_STATE = IDLE;
						end
					end
					
					SETUP: begin
						NEXT_STATE = ACCESS;
					end
					
					ACCESS: begin
						if(PADDR == {32{1'b0}})begin
							case(PSTRB)
								4'b0001: begin	
									control = PWDATA[7:0];
								end
								4'b0010: begin
									control = PWDATA[15:8];
								end
								4'b0100: begin
									control = PWDATA[23:16];
								end
								4'b1000: begin
									control = PWDATA[31:24];
								end
								default: NEXT_STATE = SETUP;
							endcase
						end
						
						else if(PADDR == {32{1'b1}}) begin
						
							if(PWRITE)begin 										
								case(PSTRB) 
									4'b0001: begin
										MASTER_DATA = PWDATA[7:0];
									end
									4'b0010: begin
										MASTER_DATA = PWDATA[15:8];
									end
									4'b0100: begin
										MASTER_DATA = PWDATA[23:16];
									end
									4'b1000: begin
										MASTER_DATA = PWDATA[31:24];
									end
									default: NEXT_STATE = SETUP;
								endcase
								GPIO_DATA_OUT = MASTER_DATA & control;	//WRITE ON BITS
								PREADY = 1'b1;	
							end
							else											
							begin
								PRDATA = GPIO_DATA_IN & (~control);	//RETURN SELECT READABLE BITS
								PREADY = 1'b1;	
							end	
						end
						NEXT_STATE = IDLE;
					end
				endcase
			end
		end
	end
endmodule
