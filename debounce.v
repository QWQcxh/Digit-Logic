`timescale 1ns / 1ps
module debounce(clk,sw_in,sw_out);
    input clk,sw_in;
    output reg sw_out;
    parameter M=2500_000;
//    parameter M=3;
    reg [24:0] counter;
    reg sw_flag;
    initial 
      begin
        counter<=25'b0;
        sw_out<=0;
        sw_flag<=0;
      end
      
    always @(posedge clk)
      begin
        if(sw_in!=sw_flag)       //按键被按下
          begin
            sw_flag<=sw_in;
            if(sw_in==1'b1) //按下
              begin sw_out<=counter==25'b0 ? sw_in : sw_out;end
            else //松开
              begin
                if(counter==25'b0) //开始触发时间延迟
                    begin counter<=counter+1;sw_out<=sw_in; end
                else
                    counter<=counter==M-1 ? 0 : counter+1;
              end
          end  
       else if(counter)
         counter<=counter==M-1 ? 0 : counter+1;
       else counter<=counter; 
      end
endmodule
