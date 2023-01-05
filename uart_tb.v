`timescale 1ns/1ns
`include "uart_tx.v"
`include "uart_rx.v"

module uart_tb ();

parameter c_CLOCK_PERIOD_NS = 10;
parameter c_CLKS_PER_BIT    = 16;
parameter c_BIT_PERIOD      = 100;
  
reg CLOCK = 0;
reg TX_VALID = 0;
reg [7:0] TX_PARALLEL = 0;
reg RX_SERIAL = 1;
wire [7:0] RX_PARALLEL;
wire DONE;

task UART_WRITE_BYTE;
  input [7:0] DATA;
  integer     i;
  begin
      
    RX_SERIAL <= 1'b0;
    #(c_BIT_PERIOD);
      
    for (i=0; i<8; i=i+1)
      begin
        RX_SERIAL <= DATA[i];
        #(c_BIT_PERIOD);
      end
      
    RX_SERIAL <= 1'b1;
    #(c_BIT_PERIOD);
    end
endtask 

uart_rx #(.CLK(c_CLKS_PER_BIT)) UART_RX_INST
(   
    .CLOCK(CLOCK),
    .RX_SERIAL(RX_SERIAL),
    .RX_VALID(),
    .RX_PARALLEL(RX_PARALLEL)
);

uart_tx #(.CLK(c_CLKS_PER_BIT)) UART_TX_INST
(   
    .CLOCK(CLOCK),
    .TX_VALID(TX_VALID),
    .TX_PARALLEL(TX_PARALLEL),
    .TX_SERIAL(),
    .DONE(DONE)
);

always
  #(c_CLOCK_PERIOD_NS/2) CLOCK <= !CLOCK;

initial
begin

  @(posedge CLOCK);
  @(posedge CLOCK);
  TX_VALID <= 1'b1;
  TX_PARALLEL <= 8'hAB;
  @(posedge CLOCK);
  TX_VALID <= 1'b0;
  @(posedge DONE);
  @(posedge CLOCK);
  UART_WRITE_BYTE(8'h3F);
  @(posedge CLOCK);
  if (RX_PARALLEL == 8'h3F)
    $display("Test Passed - Correct Byte Received");
  else
    $display("Test Failed - Incorrect Byte Received");
end

endmodule