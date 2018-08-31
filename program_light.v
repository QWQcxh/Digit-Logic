`timescale 1 ns / 1 ps
module program_light (clk,clk_1HZ,start,reset,current_model,current_program,run_state,wash_light,dwash_light,dry_light,start_light,buzzer_light);
    input clk,clk_1HZ,start,reset;
    input [2:0]current_model;
    input [1:0]current_program,run_state;
    output reg wash_light,dwash_light,dry_light,start_light,buzzer_light;

    reg [31:0] counter;
    reg power_switch,start_switch,model_switch;//三个开关状态
    reg end_program;//程序结束标志

    parameter N=100_000_000;

    initial 
        begin
          wash_light<=0;
          dwash_light<=0;
          dry_light<=0;
          start_light<=0;
          buzzer_light<=0;
          counter<=0;
          power_switch<=0;
          start_switch<=0;
          model_switch<=0;
          end_program<=0;
        end

    always @ (current_model or current_program or power_light or clk_1HZ)
        begin
          if (!power_light)//电源未开启
            begin
              wash_light<=0;
              dwash_light<=0;
              dry_light<=0;
            end
        else if (run_state!=1) //电源开启但是未启动
            begin
              case (current_model)
                3'b000://洗漂脱
                    begin
                      wash_light<=1;
                      dwash_light<=1;
                      drylight<=1;
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
                      wash_light<=wash_light;
                      dwash_light<=dwash_light;
                      dry_light<=dry_light;
              endcase
            end
        else //电源启动
            begin
              case (current_model)
              3'b000://洗漂脱
                begin
                  if (current_program==0)
                    begin
                      wash_light<=clk_1HZ;
                      dwash_light<=1;
                      dry_light<=1;
                    end
                  else if (current_program==1)
                    begin
                      wash_light<=1;
                      dwash_light<=clk_1HZ;
                      dry_light<=1;
                    end
                  else
                    begin
                      wash_light<=1;
                      dwash_light<=1;
                      dry_light<=clk_1HZ;
                    end
                end
              3'b001://单洗
                begin
                  wash_light<=clk_1HZ;
                end
              3'b010://洗漂
                begin
                  if (current_program==0)
                    begin
                      wash_light<=clk_1HZ;
                      dwash_light<=1;
                    end
                  else
                    begin
                      wash_light<=1;
                      dwash_light<=clk_1HZ; 
                    end
                end
              3'b011://单漂
                begin
                  dwash_light<=clk_1HZ;
                end
              3'b100://漂脱
                begin
                  if (current_program==1)
                    begin
                      dwash_light<=clk_1HZ;
                      dry_light<=1;
                    end
                  else
                    begin
                      dwash_light<=1;
                      dry_light<=clk_1HZ;
                    end
                end
              3'b101://单脱
                begin
                  dry_light<=clk_1HZ;
                end
            end
        end

    always @ (run_state)
        begin
          if (!power_light) //电源关闭状态
              start_light<=0;
          else if (run_state==1) //启动
              start_light<=1;
          else //暂停或完成
              start_light<=0;
        end

    always @ (posedge clk)   //开关被按下或者完成
      begin
        if (!power_light)//电源关闭，所有信号无效。恢复预设。
          begin
            counter<=0;
            power_switch<=0;
            start_switch<=0;
            model_switch<=0;
            end_program<=0;
          end
        else if (reset!=power_switch)//触发计时启动
          begin
            if (!reset) //开关闭合
              power_switch<=reset;
            else if(counter)//开关打开，但前一个计时正在进行
              counter<=counter;
            else //开关打开且未计时
              begin counter<=counter+1;buzzer_light<=1; end
          end
        else if (start!=start_switch)//启动计时触发
          begin
            if (!start)//启动开关闭合
              start_switch<=start;
            else if (counter)
              counter<=counter;
            else
              begin counter<=counter+1;buzzer_light<=1; end
          end
        else if (model_choose!=model_switch)
          begin
            if (!model_choose)
              model_switch<=model_choose;
            else if (counter)
              counter<=counter;
            else  
              begin counter<=counter+1;buzzer_light<=1; end
          end
        else if(!counter&&run_state==3)//运行完成计时触发
          begin counter<=counter+1;buzzer_light<=1; end
        else if (counter) //正在计时
          begin
            if (run_state==3)//运行完成蜂鸣9声计时。
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
                  19*N/4:begin buzzer_light<=0;counter<=counter+1;end//第三个
                  default:counter<=counter+1;
              end
            else //开关计时
              begin
                if (counter==N/4)
                  begin
                    counter<=0;
                    buzzer_light<=0;
                  end
              end
          end
        else //没触发，也没正在计时
          counter<=counter;
        //需要区分正在进行的计时
        //计时完毕且无触发信号
      end
endmodule