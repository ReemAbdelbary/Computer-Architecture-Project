module uart_tx 
#(parameter CLK)
(
  input         CLOCK,
  input         TX_VALID,
  input [7:0]   TX_PARALLEL, 
  output reg    TX_SERIAL,
  output        DONE
);
  
parameter IDLE      = 2'b00;
parameter START_BIT = 2'b01;
parameter DATA_BITS = 2'b10;
parameter STOP_BIT  = 2'b11;
  
reg [1:0]    State = 0;
reg [7:0]    CLOCK_COUNTER = 0;
reg [2:0]    INDEX = 0;
reg [7:0]    TX_DATA = 0;
reg          DONE_REG = 0;

always @(posedge CLOCK)
begin
  case (State)
    IDLE :
      begin
        TX_SERIAL <= 1'b1;  
        DONE_REG <= 1'b0;
        CLOCK_COUNTER <= 0;
        INDEX <= 0;

        if ( TX_VALID == 1'b1 )
          begin
            TX_DATA   <= TX_PARALLEL;
            State   <= START_BIT;
          end
        else
          State <= IDLE;
      end 

    START_BIT :
      begin
        TX_SERIAL <= 1'b0;
          
        if ( CLOCK_COUNTER < CLK-1 )
          begin
            CLOCK_COUNTER <= CLOCK_COUNTER + 1;
            State     <= START_BIT;
          end
        else
          begin
            CLOCK_COUNTER <= 0;
            State     <= DATA_BITS;
          end
      end 
            
    DATA_BITS :
      begin
        TX_SERIAL <= TX_DATA[INDEX];

        if (CLOCK_COUNTER < CLK-1)
          begin
            CLOCK_COUNTER <= CLOCK_COUNTER + 1;
            State     <= DATA_BITS;
          end
        else
          begin
            CLOCK_COUNTER <= 0;
            if (INDEX < 7)
              begin
                INDEX <= INDEX + 1;
                State   <= DATA_BITS;
              end
            else
              begin
                INDEX <= 0;
                State   <= STOP_BIT;
              end
          end
      end

    STOP_BIT :
      begin
        TX_SERIAL <= 1'b1;

        if (CLOCK_COUNTER < CLK-1)
          begin
            CLOCK_COUNTER <= CLOCK_COUNTER + 1;
            State     <= STOP_BIT;
          end
        else
          begin
            DONE_REG     <= 1'b1;
            CLOCK_COUNTER <= 0;
          end
      end
      default : State <= IDLE;
  endcase
end

assign DONE = DONE_REG;
endmodule