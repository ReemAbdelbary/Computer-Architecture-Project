`timescale 1ns/1ns

module slave2(
   input          PCLK, PRESETn, PSEL, PENABLE, PWRITE,
   input  [7:0]   PADDR, PWDATA,
   output [7:0]   PRDATA2,
   output reg     PREADY,
   input  [3:0]   PSTRB
);

reg [31:0] ADDRESS;
reg [31:0] MEMORY2 [0:63];
assign PRDATA2 =  MEMORY2[ADDRESS];

always @(*)
   begin
      if(!PRESETn)
         PREADY = 0;
      else
      begin
         if(PSEL && !PENABLE && !PWRITE)
         begin
            PREADY = 0; 
         end 
         else if(PSEL && PENABLE && !PWRITE)
         begin  
            PREADY = 1;
            ADDRESS =  PADDR; 
         end
         else if(PSEL && !PENABLE && PWRITE)
         begin  
            PREADY = 0; 
         end
         else if(PSEL && PENABLE && PWRITE)
         begin  
            PREADY = 1;
            MEMORY2[PADDR] = PWDATA; 
         end
         else PREADY = 0;
      end
   end
endmodule