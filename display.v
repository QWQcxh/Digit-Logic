`timescale 1 ns / 1 ps
module display (clk,power_light,current_time,total_time,current_water,digit_show,AN);
    input clk,power_light;
    input [6:0] current_time,total_time;
    input [2:0] current_water;
    output wire [7:0] digit_show;
    
    output reg [7:0] AN;
    // output reg [3:0] AN;
    
    reg [2:0] mod8_counter;//控制当前显示哪个七段显示管
    reg [3:0] RAM[7:0]; //存储各个待显示的数
    reg [3:0] current_num; //当前要显示的数
    
    seven_decoder show (current_num,digit_show);//调用译码模块

    initial 
        begin
          mod8_counter<=3'b000;
          AN<=8'b11111111;
          RAM[7] <= 10;
          RAM[6] <= 10;
          RAM[5] <= total_time/10;
          RAM[4] <= total_time%10;
          RAM[3] <= current_time/10;
          RAM[2] <= current_time%10;
          RAM[1] <= current_water/10;
          RAM[0] <= current_water%10;
          current_num <= 10;
        end
    
    always @ (posedge clk)
        begin
          mod8_counter<=(mod8_counter+1)%8;
        end

   always @ (posedge clk)
       begin
         case (mod8_counter)
           0:AN<=8'b11111110;
           1:AN<=8'b11111101;
           2:AN<=8'b11111011;
           3:AN<=8'b11110111;
           4:AN<=8'b11101111;
           5:AN<=8'b11011111;
           6:AN<=8'b10111111;
           7:AN<=8'b01111111;
           default:AN<=8'b11111111;
         endcase
       end

   always @ (posedge clk) //确定current_num
       begin
         if (!power_light) //电源关闭
           current_num<=4'd10;
         else
           case (mod8_counter)
             0:current_num<=RAM[0];
             1:current_num<=RAM[1];
             2:current_num<=RAM[2];
             3:current_num<=RAM[3];
             4:current_num<=RAM[4];
             5:current_num<=RAM[5];
             6:current_num<=RAM[6];
             7:current_num<=RAM[7];  
             default:current_num<=4'd10;
           endcase
       end

    always @ (posedge clk)
        begin
         RAM[7] <= 10;
         RAM[6] <= 10;
         RAM[5] <= total_time/10;
         RAM[4] <= total_time%10;
         RAM[3] <= current_time/10;
         RAM[2] <= current_time%10;
         RAM[1] <= current_water/10;
         RAM[0] <= current_water%10;
        end
endmodule