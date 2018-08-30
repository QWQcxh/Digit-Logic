`timescale 1 ns / 1 ps
module divider (clk,clk_1HZ);
parameter N=100_000_000;
    input clk;
    output reg clk_1HZ;
    reg [31:0] count;
    initial 
        begin
          clk_1HZ<=0;
          coutn<=0;
        end
    always @ (posedge clk)
        begin
          count<=count+1;
          if(count==N/2-1)
            begin
              clk_1HZ<=~clk_1HZ;
              count<=0;
            end
        end
endmodule
    