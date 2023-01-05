module uart_rx 
#(parameter CLK)
(
  input        CLOCK,
  input        RX_SERIAL,
  output       RX_VALID,
  output [7:0] RX_PARALLEL
);
    
parameter IDLE      = 2'b00;
parameter START_BIT = 2'b01;
parameter DATA_BITS = 2'b10;
parameter STOP_BIT  = 2'b11;
  
reg           RX_DATA1        = 1'b1;
reg           RX_DATA2        = 1'b1;
reg [7:0]     CLOCK_COUNTER   = 0;
reg [2:0]     INDEX           = 0; 
reg [7:0]     RX_PARALLEL_REG = 0;
reg           RX_VALID_REG    = 0;
reg [2:0]     STATE           = 0;

always @(posedge CLOCK)
begin
  RX_DATA1 <= RX_SERIAL;
  RX_DATA2   <= RX_DATA1;
end


always @(posedge CLOCK)
begin
  case (STATE)
    IDLE :
      begin
        RX_VALID_REG <= 1'b0;
        CLOCK_COUNTER <= 0;
        INDEX <= 0;
        if (RX_DATA2 == 1'b0)          
          STATE <= START_BIT;
        else
          STATE <= IDLE;
      end
      
    START_BIT :
      begin
        if (CLOCK_COUNTER == (CLK-1)/2)
          begin
            if (RX_DATA2 == 1'b0)
              begin
                CLOCK_COUNTER <= 0;  
                STATE <= DATA_BITS;
              end
            else
              STATE <= IDLE;
          end
        else
          begin
            CLOCK_COUNTER <= CLOCK_COUNTER + 1;
            STATE <= START_BIT;
          end
      end 
      
    DATA_BITS :
      begin
        if (CLOCK_COUNTER < CLK-1)
          begin
            CLOCK_COUNTER <= CLOCK_COUNTER + 1;
            STATE <= DATA_BITS;
          end
        else
          begin
            CLOCK_COUNTER  <= 0;
            RX_PARALLEL_REG[INDEX] <= RX_DATA2;
              
            if (INDEX < 7)
              begin
                INDEX <= INDEX + 1;
                STATE <= DATA_BITS;
              end
            else
              begin
                INDEX <= 0;
                STATE <= STOP_BIT;
              end
          end
      end 
  
    STOP_BIT :
      begin
        if (CLOCK_COUNTER < CLK-1)
          begin
            CLOCK_COUNTER <= CLOCK_COUNTER + 1;
            STATE     <= STOP_BIT;
          end
        else
          begin
            RX_VALID_REG       <= 1'b1;
            CLOCK_COUNTER <= 0;
          end
      end
      default : STATE <= IDLE;
  endcase
end   

assign RX_VALID   = RX_VALID_REG;
assign RX_PARALLEL = RX_PARALLEL_REG;

endmodule 