`timescale 1 ns / 1 ps
module washing_machine (reset,clk,start,module_choose,clothes_add,power_light,start_light,wash_light,dwash_light,dry_light,inwater_light,outwater_light,buzzer_light,digit_show);
    input reset;//reset 是电源开关
    input clk;  //100MHZ时钟信号
    input start;//启动或暂定按钮
    input module_choose;//模块选择键
    input clothes_add;//衣物添加按钮
    output reg power_light;//电源指示灯
    output reg start_light;//启动、暂停灯
    output wash_light，dwash_light,dry_light;//洗涤，漂洗，脱水指示灯
    output inwater_light,outwater_light,buzzer_light;//进水，排水，蜂鸣灯。
    output wire[7:0] digit_show;//数字七段显示管

    wire clk_1HZ;
    reg finish,close_power;
    reg[6:0] total_time,current_time;
    reg[3:0] end_counter;
    reg[1:0] run_state;
    divider mydiv (clk,clk_1HZ);
    initial 
        begin
          close_power=0;
          power_light=0;
          start_light=0;
          finish=0;
          end_counter=0;
          run_state=0;
        end

    always @ (posedge reset or posedge close_power)  //电源开关发生变化
        begin
          if(power_light)
            power_light<=0;
          else if (reset)
            power_light<=1;
          else
            power_light<=power_light;
        end
    
    always @ (negedge power_light or posedge start) //启动、暂停键被触发
        begin
          if (power_light) //电源处于开启状态来的启动、暂停信号
            begin
              if (run_state==0) //未启动
                begin
                  run_state=1;
                  start_light=1;
                end
              else if (run_state==1) //启动
                begin
                  run_state=2;//转为暂停
                  start_light=0;
                end
              else  //暂停
                begin
                  run_state=1;//转为启动
                  start_light=1;
                end
            end
          else  //电源关闭,恢复预设
            begin
              run_state=0;
              start_light=0;
            end
        end

    always @ (total_time or power_light) //洗衣时间为0，洗衣完成，开关启动，finish预设为0
        begin
          if(power_light==0) //关闭了电源，恢复预设
            finish<=0;
          else if (total_time==0) //电源开启且洗衣完成。
            finish<=1;
          else
            finish<=finish;
        end
      
    always @ (posedge clk_1HZ)
        begin
          if (power_light==0)
            end_counter<=0;
          else if (finish==0) //电源开启，洗衣未完成
            end_counter<=0;
          else if (end_counter==10) //finish==1且记完10s
            begin
              close_power<=1;//自动断电
              end_counter<=0;
            end
          else
            end_counter<=end_counter+1;
        end
endmodule