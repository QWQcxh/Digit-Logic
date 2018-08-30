`timescale 1 ns / 1 ps
module water_amount (power_light,run_state,finish,clothes_add,current_water);
    input power_light,finish,clothes_add;
    input [1:0] run_state;
    output reg [2:0] current_water;

    initial 
        begin
          current_water<=0;
        end
    
    always @ (negedge power_light or posedge finish or posedge clothes_add)
        begin
          if (!power_light||finish)
            current_water<=2;
          else if(clothes_add&&run_state==0)
            current_water<=(current_water+1)%6;
          else
            current_water<=current_water;
        end