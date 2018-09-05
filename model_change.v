`timescale 1 ns / 1 ps
module model_change (power_light,run_state,finish,model_choose,current_model);
    input power_light,finish,model_choose;//电源状态，运行状态，完成状态，模式选择开关
    input [1:0] run_state;
    output reg [2:0]current_model;

    initial
        begin
          current_model<=3'b000;
        end

    always @ (negedge power_light or posedge finish or posedge model_choose)
        begin
          if (!power_light||finish)  //恢复预设
            current_model<=3'b000;
          else if (model_choose&&run_state==0) //加电未启动状态下的模式选择
            current_model<=(current_model+1)%6;
          else
            current_model<=current_model;
        end
endmodule