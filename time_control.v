`timescale 1 ns / 1 ps
module time_control (clk_1HZ,power_light,run_state,current_model,current_water,current_time,total_time,current_program,in_water,out_water);
    input clk_1HZ,power_light;
    input [1:0] run_state;
    input [2:0] current_model,current_water;
    output reg in_water,out_water;
    output reg[1:0] current_program;
    output reg[6:0] current_time,total_time;

    reg [6:0] wash_time,dwash_time,dry_time;
    reg [31:0] clk_counter;
    parameter N=100_000_000;

    initial 
        begin
          in_water<=0;
          out_water<=0
          current_program<=0;
          current_time<=11;
          total_time<=31;
          wash_time<=0;
          dwash_time<=0;
          dry_time<=0;
          clk_counter<=0;
        end

    always @ (power_light or current_model or current_water)
        begin
          if (!power_light)
            begin
              wash_time<=0;
              dwash_time<=0;
              dry_time<=0;              
            end
          else if (run_state!=0)//已经启动或暂停设定不变
            begin
              wash_time<=wash_time;
              dwash_time<=dwash_time;
              dry_time<=dry_time;
            end
          else
            begin
              case (current_model)
                3'b000://洗漂脱
                begin
                  wash_time<=9+current_water;
                  dwash_time<=9+2*current_water;
                  dry_time<=3+current_water;  
                end
                3'b001: //单洗
                begin
                  wash_time<=9+current_water;
                  dwash_time<=0;
                  dry_time<=0;
                end 
                3'b010: //洗漂
                begin
                  wash_time<=9+current_water;
                  dwash_time<=9+2*current_water;
                  dry_time<=0;  
                end
                3'b011: //单漂
                begin
                  wash_time<=0;
                  dwash_time<=9+2*current_water;
                  dry_time<=0;
                end
                3'b100: //漂脱
                begin
                  wash_time<=0;
                  dwash_time<=9+2*current_water;
                  dry_time<=3+current_water;  
                end
                3'b101: //单脱
                begin
                  wash_time<=0;
                  dwash_time<=0;
                  dry_time<=3+current_water;  
                end
                default: //其余特殊情况
                begin
                  wash_time<=wash_time;
                  dwash_time<=dwash_time;
                  dry_time<=dry_time;
                end 
              endcase
            end
        end

    always @　(posedge clk or negedge power_light)
        begin
          if (!power_light)      //恢复预设
            current_time<=11;
          else if (run_state==0) //未启动状态确定启动前的各时间设置。
            begin
              if (wash_time) //洗衣时间不为0
                begin
                  current_time<=wash_time;
                  current_program<=0;
                end
              else if (dwash_time)
                begin
                  current_time<=dwash_time;
                  current_program<=1;
                end
              else
                begin
                  current_time<=dry_time;
                  current_program<=2;
                end
            end
          else if (run_state==2) //暂停状态
            begin
              current_time<=current_time;//时间不变
            end
          else if(run_state==1)//启动状态
            begin
              clk_counter<=clk_counter+1;
              if (clk_counter==N-1)  //已经计时1s
              begin
                clk_counter<=0;
                if (current_time==1) //当前程序已经计数完成
                begin
                  current_program<=current_program+1;
                  case (current_model)
                    3'b000://洗漂脱
                    if (current_program==2)
                      begin
                        run_state<=3;//完成
                        current_time<=11;
                      end
                    else if (current_program==0)
                      current_time<=dwash_time;
                    else
                      current_time<=dry_time;
                    3'b001://单洗
                    begin
                      run_state<=3;//完成
                      current_time<=11;
                    end
                    3'b010://洗漂
                    if (current_program==1)
                      begin
                        run_state<=3;//完成
                        current_time<=11;
                      end
                    else
                      current_time<=dwash_time;
                    3'b011://单漂
                    begin
                      run_state<=3;
                      current_time<=11;
                    end
                    3'b100://漂脱
                    if(current_program==2)
                      begin
                        run_state<=3;//完成
                        current_time<=11;
                      end
                    else
                      current_time<=dry_time;
                    3'b101://
                    begin
                      run_state<=3;
                      current_time<=11;
                    end
                    default:current_time<=current_time; 
                  endcase
                end
              end
            end
          else //完成状态
            current_time<=11;
        end

    always @ (posedge clk or negedge power_light)
      begin
        if (!power_light)
          total_time<=31;
        else if (run_state==0) //未启动状态
          total_time<=wash_time+dwash_time+dry_time;
        else if (run_state==2) //暂停状态
          total_time<=total_time;
        else if (run_state==3) //完成状态
          total_time<=31;
        else //启动状态
          begin
            if (clk_counter==N-1) //1s
              begin
                if (total_time==1)
                  total_time<=31;
                else
                  total_time<=total_time-1;
              end
            else
              total_time<=total_time;
          end
      end

    always @ (current_program or current_time or power_light)
      begin
        if (!power_light)
          begin
            in_water<=0;
            out_water<=0;
          end
        else if (run_state==1)//启动状态
          begin
            case (current_program)
              2'b00://洗涤程序
                if(wash_time-current_time<=current_water)//进水状态
                  begin in_water<=1;out_water<=0; end
                else
                  begin in_water<=0;out_water<=0; end
              2'b01://漂洗程序
                if (dwash_time-current_time<=current_water+3)//排水状态
                  begin in_water<=0;out_water<=1; end
                else if (dwash_time-current_time<=2*current_water+3)//进水
                  begin in_water<=1;out_water<=0; end
                else 
                  begin in_water<=0;out_water<=0;end
              2'b10://脱水程序
                begin in_water<=0;out_water<=1;end
              default:begin in_water<=0; out_water<=0;end
            endcase
          end
        else if (run_state==2)//暂停状态
          begin in_water<=in_water;out_water<=out_water;end
        else //完成状态或未启动状态
          begin in_water<=0;out_water<=0;end
      end