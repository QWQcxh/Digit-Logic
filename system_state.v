`timescale 1ns / 1ps
module system_state(clk,clk_1HZ,reset,start,model_choose,finish,rest_time,run_state,power_light);
    input clk,clk_1HZ,reset,start,model_choose,finish;
    input wire [6:0] rest_time;
    output reg [1:0] run_state;
    output reg power_light;
    
    reg close_power;
    reg[3:0] end_counter;
    reg start_flag;
    reg model_flag;

   initial 
      begin
        close_power=0;
        power_light=0;
        end_counter=0;
        run_state=0;
        start_flag<=0;
      end

  always @ (posedge reset,posedge close_power)
      begin
        if (close_power==1)
          power_light<=0;
        else
          power_light<=~power_light;
      end

  always @ (posedge clk) //确定运行状态
      begin
        if (power_light==1'b0)//断电不响应
          run_state<=2'b00;
        else
          if(start)  //启动键被按下
            begin
              if (start_flag==1'b0)
                  begin
                    start_flag<=1'b1;
                    case (run_state)
                      2'b00:run_state<=2'b01;
                      2'b01:run_state<=rest_time==7'b0 ? 2'b10 : run_state; //启动变成暂停需要在计时器为0的情况才能用。
                      2'b10:run_state<=2'b01;
                      2'b11:run_state<=2'b00;
                    endcase
                  end
              else    
                  run_state<=run_state;
            end
          else
            begin
              start_flag<=1'b0;
              if(model_choose && model_flag==1'b0)  //按下模式选择键
                begin
                  model_flag<=1'b1;
                  run_state<=run_state==2'b10 ? 2'b00:run_state;
                end
              else
                model_flag<=model_choose;
            end
      end
  
  //设定10s自动断电信号
  always @ (posedge clk_1HZ)
      begin
        if (power_light==0)
          begin end_counter<=0;close_power<=0; end
        else if (finish==0) //电源开启，洗衣未完成
          begin end_counter<=0;close_power<=0; end
        else if (end_counter==10) //finish==1且记完10s
          begin close_power<=1;end_counter<=0; end
        else //finish==1 且未记完10s
          end_counter<=end_counter+1;
      end
endmodule
