`include "uart_tx.v"
`include "uart_rx.v"
module UART_MODULE (
    input                         PRESETn, 
    input                         PCLK,
    input                         PSEL,
    input                         PENABLE, 
    input      [31:0] 			  PADDR,
    input                         PWRITE, 
    input      [31:0] 			  PWDATA,
    input      [3:0] 			  PSTRB,
    output reg [31:0] 			  PRDATA, 
    output                        PREADY, 
    output reg                    TX_DATA,
    input  reg                    RX_DATA
);
always@(PCLK)
begin   
    if(PSEL)    
    begin
        if(PWRITE && PENABLE)
        begin
            uart_tx instance1(  PCLK, PRESETn, PWDATA, TX_DATA, PREADY1 );
        end
        else if (PENABLE)
        begin
            uart_rx     instance2(  PCLK, PRESETn, RX_DATA, PRDATA2, PREADY2 );
        end
    end
end
endmodule

