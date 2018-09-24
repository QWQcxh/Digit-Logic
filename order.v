`timescale 1ns / 1ps
module order(clk,power_light,order_time,clean_time,run_state,rest_time);
    input clk,power_light,order_time,clean_time;
    input wire[1:0] run_state;
    output reg[6:0] rest_time;
    
    parameter N=100_000_000;
    reg [31:0] counter;
    reg order_flag,clean_flag;
    initial
        begin
            counter<=0;
            rest_time<=7'b0;
            order_flag<=0;
            clean_flag<=0;
        end
        
    always @ (posedge clk)
        begin
            if(power_light==1'b0)
              begin
                counter<=0;
                rest_time<=0;
                order_flag<=0;
              end
            else if(run_state==2'b00) //未启动
              begin
                if(order_time==1'b1&&order_flag==1'b0)
                  begin
                    order_flag<=order_time;
                    rest_time<=(rest_time+10)%70;
                  end
                else
                    order_flag<=order_time;
              end
            else if(run_state==2'b01) //启动
              begin
                if(clean_time==1'b1&&clean_flag==1'b0) //清时信号
                  begin
                    rest_time<=7'b0;
                    clean_flag<=clean_time;
                  end
                else if(rest_time==7'b0)  //已经为0
                    begin counter<=32'b0; clean_flag<=clean_time; end
                else //不为0
                  begin
                    clean_flag<=clean_time;
                    if(counter==N-1)
                       begin rest_time<=rest_time-1; counter<=32'b0; end
                    else
                       counter<=counter+1;
                  end  
              end
            else counter<=32'b0;
        end
endmodule
