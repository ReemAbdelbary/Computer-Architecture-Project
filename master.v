`timescale 1ns/1ns

module master_bridge(
	input [31:0] 		Write_Address, Read_Address, INPUT_DATA, PRDATA,         
	input 				PRESETn, PCLK, ReadOrWrite, Trans, PREADY,
	output 				PSEL1, PSEL2,
	output reg 			PENABLE,
	output reg [31:0]	PADDR,
	output reg 		 	PWRITE,
	output reg [31:0]	PWDATA, OUT_DATA,
	output 			 	PSLVERR,
	input [3:0] 	 	Input_STRB,
	output reg [3:0] 	PSTRB 
); 
reg [1:0] State , N_State;

reg INVALID_SETUP_ERROR, SETUP_ERROR, INVALID_READ_ADDRESS, INVALID_WRITE_ADDRESS, INVALID_WRITE_DATA ;

localparam IDLE = 2'b00, SETUP = 2'b01, ENABLE = 2'b10 ;


always @(posedge PCLK)
begin
	if(!PRESETn)
		State <= IDLE;
	else
		State <= N_State; 
end

always @(State,Trans,PREADY)
	begin
	if(!PRESETn)
		N_State = IDLE;
	else
        begin
            PWRITE = ~ReadOrWrite;
	    	case(State)
				IDLE: begin 
						PENABLE =0;
						if(!Trans)
						N_State = IDLE ;
						else
						N_State = SETUP;
				end

				SETUP: begin
					PENABLE =0;
					if(ReadOrWrite) 
					begin   
						PADDR = Read_Address; 
						PSTRB <= 'b0 ;
					end
					else 
					begin   
						PADDR = Write_Address;
						PWDATA = INPUT_DATA;  
						PSTRB  <= Input_STRB ;
					end
					if(Trans && !PSLVERR)
						N_State = ENABLE;
					else
						N_State = IDLE;
		        end

				ENABLE: begin
					if(PSEL1 || PSEL2)
						PENABLE =1;
					if(Trans & !PSLVERR)
					begin
						if(PREADY)
						begin
							if(!ReadOrWrite)
							begin	
								N_State = SETUP; 
							end
							else 
							begin
								N_State = SETUP; 
								OUT_DATA = PRDATA; 
							end
						end
						else N_State = ENABLE;
					end
					else N_State = IDLE;
				end
                default: N_State = IDLE; 
            endcase
        end
    end
    assign {PSEL1,PSEL2} = ((State != IDLE) ? (PADDR[31] ? {1'b0,1'b1} : {1'b1,1'b0}) : 2'd0);

always @(*)
    begin
    	if(!PRESETn)
		begin 
			SETUP_ERROR =0;
			INVALID_READ_ADDRESS = 0;
			INVALID_WRITE_ADDRESS = 0;
			INVALID_WRITE_ADDRESS =0 ;
		end
        else
		begin
			begin	
				if(State == IDLE && N_State == ENABLE)
					SETUP_ERROR = 1;
				else SETUP_ERROR = 0;
			end
			begin
				if((INPUT_DATA===32'dx) && (!ReadOrWrite) && (State==SETUP || State==ENABLE))
					INVALID_WRITE_DATA =1;
				else INVALID_WRITE_DATA = 0;
			end
			begin
				if((Read_Address===32'dx) && ReadOrWrite && (State==SETUP || State==ENABLE))
					INVALID_READ_ADDRESS = 1;
				else  INVALID_READ_ADDRESS = 0;
			end
			begin
				if((Write_Address===32'dx) && (!ReadOrWrite) && (State==SETUP || State==ENABLE))
					INVALID_WRITE_ADDRESS =1;
				else INVALID_WRITE_ADDRESS =0;
			end
			begin
				if(State == SETUP)
					begin
						if(PWRITE)
							begin
								if(PADDR==Write_Address && PWDATA==INPUT_DATA)
									SETUP_ERROR=1'b0;
								else
									SETUP_ERROR=1'b1;
							end
						else 
							begin
								if (PADDR==Read_Address)
									SETUP_ERROR=1'b0;
								else
									SETUP_ERROR=1'b1;
							end    
					end 
				else SETUP_ERROR=1'b0;
			end 
		end
    INVALID_SETUP_ERROR = SETUP_ERROR ||  INVALID_READ_ADDRESS || INVALID_WRITE_DATA || INVALID_WRITE_ADDRESS  ;
	end 
assign PSLVERR =  INVALID_SETUP_ERROR ;
endmodule