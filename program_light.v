`timescale 1 ns / 1 ps
module program_light (clk,clk_1HZ,start,reset,power_light,finish,model_choose,clothes_add,current_model,current_program,run_state,
wash_light,dwash_light,dry_light,start_light,buzzer_light);
    input clk,clk_1HZ,start,reset,power_light,finish,model_choose,clothes_add;
    input [2:0]current_model;
    input [1:0]current_program,run_state;
    output reg wash_light,dwash_light,dry_light,start_light,buzzer_light;

    reg [31:0] counter;
    reg power_flag,start_flag,model_flag,clothes_flag;//三个开关状态
    reg end_program;//程序结束标志

    parameter N=100_000_000;
//    parameter N=4;
    
    initial 
        begin
          wash_light<=0;
          dwash_light<=0;
          dry_light<=0;
          start_light<=0;
          buzzer_light<=0;
          counter<=0;
          power_flag<=0;
          start_flag<=0;
          model_flag<=0;
          clothes_flag<=0;
          end_program<=0;
        end

    //确定wash_light,dwash_light,dry_light的输出
    //影响信号：开关灯信号power_light,模式选择信号和当前程序信号，以及闪烁脉冲和程序完成信号
    always @ (posedge clk)
        begin
          if (power_light==1'b0)//电源关闭，关上所有灯
            begin
              wash_light<=0;
              dwash_light<=0;
              dry_light<=0;
            end
          else if (run_state==2'b00) //电源开启且处于暂停或者未启动状态，常亮模式灯
            begin
              case (current_model)
                3'b000://洗漂脱
                    begin
                      wash_light<=1;
                      dwash_light<=1;
                      dry_light<=1;
                    end 
                3'b001://单洗
                    begin
                      wash_light<=1;
                      dwash_light<=0;
                      dry_light<=0;
                    end
                3'b010://洗漂
                    begin
                      wash_light<=1;
                      dwash_light<=1;
                      dry_light<=0;
                    end
                3'b011://单漂
                    begin
                      wash_light<=0;
                      dwash_light<=1;
                      dry_light<=0;
                    end
                3'b100://漂脱
                    begin
                      wash_light<=0;
                      dwash_light<=1;
                      dry_light<=1;
                    end
                3'b101://单脱
                    begin
                      wash_light<=0;
                      dwash_light<=0;
                      dry_light<=1;
                    end
                default: 
                    begin
                      wash_light<=0;
                      dwash_light<=0;
                      dry_light<=0;
                    end
              endcase
            end
          else if(run_state==2'b10) //暂停
            begin
              case(current_program)
                2'b00:wash_light<=1;
                2'b01:dwash_light<=1;
                2'b10:dry_light<=1;
                default:begin wash_light<=1; dwash_light<=1; dry_light<=1; end
              endcase
            end
          else if(finish==1'b0)//处于启动未完成状态,需要闪烁
            begin
              case (current_model)
              3'b000://洗漂脱
                begin
                  if (current_program==2'b00) //洗涤灯闪烁
                    begin
                      wash_light<=clk_1HZ;
                      dwash_light<=1;
                      dry_light<=1;
                    end
                  else if (current_program==2'b01) //漂洗灯闪烁
                    begin
                      wash_light<=0;
                      dwash_light<=clk_1HZ;
                      dry_light<=1;
                    end
                  else  //脱水灯闪烁
                    begin
                      wash_light<=0;
                      dwash_light<=0;
                      dry_light<=clk_1HZ;
                    end
                end
              3'b001://单洗
                begin
                  wash_light<=clk_1HZ;
                end
              3'b010://洗漂
                begin
                  if (current_program==2'b00)
                    begin
                      wash_light<=clk_1HZ;
                      dwash_light<=1;
                    end
                  else
                    begin
                      wash_light<=0;
                      dwash_light<=clk_1HZ; 
                    end
                end
              3'b011://单漂
                begin
                  dwash_light<=clk_1HZ;
                end
              3'b100://漂脱
                begin
                  if (current_program==2'b01)
                    begin
                      dwash_light<=clk_1HZ;
                      dry_light<=1;
                    end
                  else
                    begin
                      dwash_light<=0;
                      dry_light<=clk_1HZ;
                    end
                end
              3'b101://单脱
                begin
                  dry_light<=clk_1HZ;
                end
              default:
                begin
                  wash_light<=0;
                  dwash_light<=0;
                  dry_light<=0;
                end
              endcase
            end
          else  //程序完成灯恢复默认洗漂脱模式
            begin
              wash_light<=1;
              dwash_light<=1;
              dry_light<=1;
            end
        end

    //确定启动暂停灯
    //影响信号：启动暂停键的拨动，程序彻底结束信号（蜂鸣3次）
    always @ (posedge clk)
      begin
        if (run_state==2'b00||run_state==2'b10||end_program==1'b01)
            start_light<=0;
        else
            start_light<=1;
      end

    //确定蜂鸣灯
    always @ (posedge clk)   //开关被按下或者完成
      begin
        if (power_light==1'b0)//电源关闭，所有信号无效。恢复预设。
          begin
             counter<=0;
             power_flag<=0;
             start_flag<=0;
             model_flag<=0;
             clothes_flag<=0;
             end_program<=0;
          end
        else if (reset!=power_flag)//电源键计时触发
          begin
            if (reset==1'b0) //开关闭合
              power_flag<=reset;
            else if(counter)//开关打开，但前一个计时正在进行
              power_flag<=reset;
            else //开关打开且未计时
              begin counter<=counter+1;buzzer_light<=1;power_flag<=reset; end
          end
        else if (start!=start_flag)//启动计时触发
          begin
            if (start==1'b0)//启动开关闭合
              start_flag<=start;
            else if (counter)
              start_flag<=start;
            else
              begin counter<=counter+1;buzzer_light<=1;start_flag<=start; end
          end
        else if (model_choose!=model_flag)  //模式选择开关
          begin
            if (model_choose==1'b0)
              model_flag<=model_choose;
            else if (counter)
              model_flag<=model_choose;
            else  
              begin counter<=counter+1;buzzer_light<=1;model_flag<=model_choose; end
          end
        else if (clothes_add!=clothes_flag) //加衣开关
          begin
            if (clothes_add==1'b0)
              clothes_flag<=clothes_add;
            else if (counter)
              clothes_flag<=clothes_add;
            else 
              begin counter<=counter+1;buzzer_light<=1;clothes_flag<=clothes_add; end
          end
        else if(counter==32'd0&&finish==1'b1)//运行完成计时触发
          begin counter<=counter+1;buzzer_light<=1;end
        else if (counter) //正在计时
          begin
            if (finish==1'b1)//运行完成蜂鸣9声计时。
              begin
                case (counter)
                  N/4:begin buzzer_light<=0;counter<=counter+1;end
                  N/2:begin buzzer_light<=1;counter<=counter+1;end
                  3*N/4:begin buzzer_light<=0;counter<=counter+1;end
                  N:begin buzzer_light<=1;counter<=counter+1;end
                  5*N/4:begin buzzer_light<=0;counter<=counter+1;end//第一个
                  7*N/4:begin buzzer_light<=1;counter<=counter+1;end
                  2*N:begin buzzer_light<=0;counter<=counter+1;end
                  9*N/4:begin buzzer_light<=1;counter<=counter+1;end
                  5*N/2:begin buzzer_light<=0;counter<=counter+1;end
                  11*N/4:begin buzzer_light<=1;counter<=counter+1;end
                  3*N:begin buzzer_light<=0;counter<=counter+1;end//第二个
                  7*N/2:begin buzzer_light<=1;counter<=counter+1;end
                  15*N/4:begin buzzer_light<=0;counter<=counter+1;end
                  4*N:begin buzzer_light<=1;counter<=counter+1;end
                  17*N/4:begin buzzer_light<=0;counter<=counter+1;end
                  9*N/2:begin buzzer_light<=1;counter<=counter+1;end
                  19*N/4:begin buzzer_light<=0;counter<=counter;end_program<=1;end//第三个
                  default:counter<=counter+1;
                endcase
              end
            else //开关计时
              begin
                if (counter==N/4)
                  begin
                    counter<=0;
                    buzzer_light<=0;
                  end
                else 
                    counter<=counter+1;
              end
          end
        else //没触发，也没正在计时
          counter <= 32'd0;
      end
endmodule