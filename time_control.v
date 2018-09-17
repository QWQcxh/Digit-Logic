`timescale 1 ns / 1 ps
module time_control (clk,power_light,run_state,current_model,current_water,
finish,current_time,total_time,current_program,in_water,out_water);
    input clk,power_light; //100MHZ信号，电灯状态,程序完成状态
    input [1:0] run_state; //运行状态
    input [2:0] current_model,current_water;//当前洗衣模式以及水量
    output reg in_water,out_water,finish; //进出水指示，
    output reg[1:0] current_program;//当前程序
    output reg[6:0] current_time,total_time;//当前时间以及总剩余时间

    reg [6:0] wash_time,dwash_time,dry_time;
    reg [31:0] clk_counter;
    parameter N=100_000_000;
//    parameter N=5;//仿真用
    
    initial 
        begin
          in_water<=0;
          out_water<=0;
          current_program<=0;
          current_time<=11;
          total_time<=29;
          wash_time<=11;
          dwash_time<=13;
          dry_time<=5;
          clk_counter<=0;
          finish<=0;
        end

    // 确定洗、漂、脱三个程序所需时间
    // 可以添加附加功能current_add表示用户手动调整的时间
    always @ (posedge clk)
        begin
          if (power_light==1'b0) //断电
            begin
              wash_time<=7'b0000000;
              dwash_time<=7'b0000000;
              dry_time<=7'b0000000;
            end
          else if (run_state==2'b00) //未启动
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
              endcase
            end
         else   
            begin
              wash_time<=wash_time;
              dwash_time<=dwash_time;
              dry_time<=dry_time;
            end
        end

    //设定当前程序剩余时间 current_time,当前程序current_program,完成状态finish.
    //影响信号：断电恢复预设，来脉冲计时，根据当前模式和程序维护current_time,current_program,finish
    always @(posedge clk)
        begin
          if (power_light==1'b0)      //未通电状态恢复预设
            begin 
              current_time<=11;
              current_program<=0;
              finish<=0;
              clk_counter<=0; 
            end
          else if (run_state==2'b00) //通电且未启动确定启动前的各时间设置。
            begin
              clk_counter<=0;
              if (wash_time) //洗衣时间不为0
                begin
                  current_time<=wash_time;
                  current_program<=2'b00;
                end
              else if (dwash_time)
                begin
                  current_time<=dwash_time;
                  current_program<=2'b01;
                end
              else
                begin
                  current_time<=dry_time;
                  current_program<=2'b10;
                end
            end
          else if (run_state==2'b10) //暂停状态屏蔽脉冲
            begin
              current_time<=current_time;//时间不变
              finish<=finish;
            end
          else if (run_state==2'b01&&finish==0)//启动状态根据模式和当前程序维护current_time和current_program
            begin
              if (clk_counter>= N-1)  //已经计时1s
                begin
                  clk_counter<=32'd0;//清零计数器
                  if (current_time==1) //当前程序已经计数完成
                    begin
                      current_program<=current_program+1;//当前程序变为下一个程序
                      case (current_model) //确定新的current_time
                        3'b000://洗漂脱
                        if (current_program==2'b10) //表示脱水完成
                          begin
                            finish<=1'b1;//完成
                            current_time<=32'd11;//恢复预设模式
                          end
                        else if (current_program==0) //洗涤完成
                          current_time<=dwash_time;
                        else  //漂洗完成
                          current_time<=dry_time;
                        3'b001://单洗
                        begin
                          finish<=1'b1;//完成
                          current_time<=32'd11;
                        end
                        3'b010://洗漂
                        if (current_program==1)
                          begin
                            finish<=1'b1;//完成
                            current_time<=32'd11;
                          end
                        else
                          current_time<=dwash_time;
                        3'b011://单漂
                        begin
                          finish<=1'b1;
                          current_time<=32'd11;
                        end
                        3'b100://漂脱
                        if(current_program==2'b10)
                          begin
                            finish<=1'b1;//完成
                            current_time<=32'd11;
                          end
                        else
                          current_time<=dry_time;
                        3'b101://单脱
                        begin
                          finish<=1'b1;
                          current_time<=32'd11;
                        end
                        default:current_time<=32'd11; 
                      endcase
                    end
                  else 
                    current_time<=current_time-1;
                end
              else 
                clk_counter<=clk_counter+1;
            end
          else //finish 状态
             current_time<=current_time;
        end
        
        
    //确定total_time
    always @(posedge clk)
      begin
        if (power_light==1'b0)
          total_time<=7'd29;
        else if (run_state==2'b00) //未启动状态
          total_time<=wash_time+dwash_time+dry_time;
        else if (run_state==2'b10) //暂停状态
          total_time<=total_time;
        else if (finish==1) //完成状态
          total_time<=7'd29;//恢复预设
        else //启动状态
          begin
            if (clk_counter == N-1) //计时1s
              begin
                if (total_time==7'd1)//时间即将变为0，恢复预设
                  total_time<=7'd29;
                else
                  total_time<=total_time-1;
              end
            else
              total_time<=total_time;
          end
      end
     
    //设定进出水指示灯
    always @ (posedge clk)
      begin
        if (power_light<=1'b0) //未加电
          begin
            in_water<=0;
            out_water<=0;
          end
        else if (run_state==1&&finish==0)//启动状态
          begin
            case (current_program)
              2'b00://洗涤程序
                if(wash_time-current_time < current_water)//进水状态
                  begin in_water<=1;out_water<=0; end
                else
                  begin in_water<=0;out_water<=0; end
              2'b01://漂洗程序
                if (dwash_time-current_time < current_water+3)//排水状态
                  begin in_water<=0;out_water<=1; end
                else if (dwash_time-current_time < 2*current_water+3)//进水
                  begin in_water<=1;out_water<=0; end
                else 
                  begin in_water<=0;out_water<=0;end
              2'b10://脱水程序
                begin in_water<=0;out_water<=1;end
              default:begin in_water<=0; out_water<=0;end
            endcase
          end
        else if(run_state==2'b00||finish==1'b1)//未启动状态或者完成状态
          begin in_water<=0;out_water<=0;end
        else //暂停状态
          begin in_water<=in_water;out_water<=out_water; end
      end

endmodule