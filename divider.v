`timescale 1 ns / 1 ps
module divider (clk,clk_1HZ,clk_10000HZ);
    parameter N=100_000_000;
    parameter M=10000;
//     parameter N=5;
    input clk;
    output reg clk_1HZ;
    output reg clk_10000HZ;
    reg [31:0] count;
    reg [31:0] count_10000;
    initial 
        begin
          clk_1HZ<=0;
          clk_10000HZ<=0;
          count<=0;
          count_10000<=0;
          
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
        
    always @ (posedge clk)
        begin;
          if(count_10000==M/2-1)
            begin 
                clk_10000HZ<=~clk_10000HZ;
                count_10000<=0;
            end
          else
                count_10000<=count_10000+1;
        end
endmodule