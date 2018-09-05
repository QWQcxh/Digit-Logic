`timescale 1 ns / 1 ps
module washing_machine (reset,clk,start,model_choose,clothes_add,
power_light,start_light,wash_light,dwash_light,dry_light,inwater_light,outwater_light,buzzer_light,digit_show,AN);
    input reset,clk,start,model_choose,clothes_add;//电源开关，100MHZ时钟，启动/暂停开关，模式选择开关，衣物添加开关
    output reg power_light;//电源指示灯
    output start_light;//启动、暂停灯
    output wash_light,dwash_light,dry_light;//洗涤，漂洗，脱水指示灯
    output inwater_light,outwater_light,buzzer_light;//进水，排水，蜂鸣灯。
    output wire[7:0] digit_show;//数字七段显示管
//    output wire[7:0] AN;//显示管控制信号
    output wire [3:0] AN;
    
    //本模块用到的线网及寄存器。
    wire clk_1HZ,clk_10000HZ,finish;
    wire [6:0] total_time,current_time;
    wire [2:0] current_water;
    wire [2:0] current_model;
    wire [1:0] current_program;

    reg close_power;
    reg[3:0] end_counter;
    reg[1:0] run_state;//仿真添加output
    reg start_flag;

    water_amount ins_water (clk,power_light,run_state,finish,clothes_add,current_water);
    model_change ins_model (power_light,run_state,finish,model_choose,current_model);
    time_control ins_time  (clk,power_light,run_state,current_model,current_water,
finish,current_time,total_time,current_program,inwater_light,outwater_light);
    program_light ins_light (clk,clk_1HZ,start,reset,power_light,finish,model_choose,clothes_add,
current_model,current_program,run_state,wash_light,dwash_light,dry_light,start_light,
buzzer_light);
    divider ins_divider (clk,clk_1HZ,clk_10000HZ);
    display ins_display (clk_10000HZ,power_light,current_time,total_time,current_water,digit_show,AN);

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

    always @ (posedge clk)
        begin
          if (power_light==1'b0)
            run_state<=2'b00;
          else
            if(start)
              begin
                if (start_flag==1'b0)
                    begin
                      start_flag<=1'b1;
                      case (run_state)
                        2'b00:run_state<=2'b01;
                        2'b01:run_state<=2'b10;
                        2'b10:run_state<=2'b01;
                        2'b11:run_state<=2'b00;
                      endcase
                    end
                else    
                    run_state<=run_state;
              end
            else
                start_flag<=1'b0;
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