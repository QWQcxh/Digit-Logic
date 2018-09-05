`timescale 1 ns / 1 ps
module water_amount (clk,power_light,run_state,finish,clothes_add,current_water);
    input clk,power_light,finish,clothes_add;
    input [1:0] run_state;
    output reg [2:0] current_water;
    
    reg clothes_add_flag;

    initial 
        begin
          current_water<=0;
          clothes_add_flag<=0;
        end
    
    always @ (posedge clk)
        begin
          if (power_light==1'b0||finish==1'b1) //未加电或者已经完成恢复预设
            current_water<=3'b010;
          else if (run_state==2'b00) //加电未启动
            begin
               if (clothes_add!=clothes_add_flag)
                  begin
                    if(clothes_add==1'b1)
                        begin
                           if (current_water==3'b101)
                            begin current_water<=3'b010; clothes_add_flag<=clothes_add;end
                           else 
                            begin current_water<=current_water+1;clothes_add_flag<=clothes_add;end
                        end
                    else
                        clothes_add_flag<=clothes_add;
                  end
               else
                  current_water<=current_water;
            end
          else //暂停或者启动
            current_water<=current_water;
        end
endmodule