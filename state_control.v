`timescale 1 ns / 1 ps
module model_change (power_light,start_light,finish,model_choose,current_model);
    input power_light,start_light,finish,model_choose;
    output reg [2:0]current_model;

    initial
        begin
          current_model<=3'b000;
        end

    always @ (negedge power_light or posedge finish or posedge model_choose)
        begin
          if (!power_light||finish)
            current_model<=3'b000;
          else if (model_choose&&!start_light)
            current_model<=model_choose+1;
          else
            current_model<=model_choose;
        end
endmodule