`timescale 1 ns / 1 ps
module washing_machine (reset_in,clk,start_in,model_choose_in,clothes_add_in,order_time_in,clean_time_in,
power_light,start_light,wash_light,dwash_light,dry_light,inwater_light,outwater_light,buzzer_light,digit_show,AN);
    input reset_in,clk,start_in,model_choose_in,clothes_add_in,order_time_in,clean_time_in;//电源开关，100MHZ时钟，启动/暂停开关，模式选择开关，衣物添加开关
    output power_light;//电源指示灯
    output start_light;//启动、暂停灯
    output wash_light,dwash_light,dry_light;//洗涤，漂洗，脱水指示灯
    output inwater_light,outwater_light,buzzer_light;//进水，排水，蜂鸣灯。
    output wire[7:0] digit_show;//数字七段显示管
    output wire[7:0] AN;//显示管控制信号
    // output wire [3:0] AN;
    
    //本模块用到的线网及寄存器。
    wire clk_1HZ,clk_10000HZ,finish;
    wire [6:0] total_time,current_time;
    wire [2:0] current_water;
    wire [2:0] current_model;
    wire [1:0] current_program,run_state;
    wire [6:0] rest_time;
    wire reset,start,model_choose,clothes_add,order_time,clean_time;

    debounce ins_1 (clk,reset_in,reset);
    debounce ins_2 (clk,start_in,start);
    debounce ins_3 (clk,model_choose_in,model_choose);
    debounce ins_4 (clk,clothes_add_in,clothes_add);
    debounce ins_5 (clk,order_time_in,order_time);
    debounce ins_6 (clk,clean_time_in,clean_time);
    
    system_state ins_state (clk,clk_1HZ,reset,start,model_choose,finish,rest_time,run_state,power_light);
    water_amount ins_water (clk,power_light,run_state,finish,clothes_add,current_water);
    model_change ins_model (power_light,run_state,finish,model_choose,current_model);
    time_control ins_time  (clk,power_light,run_state,current_model,current_water,rest_time,
finish,current_time,total_time,current_program,inwater_light,outwater_light);
    program_light ins_light (clk,clk_1HZ,start,reset,power_light,finish,model_choose,clothes_add,
current_model,current_program,run_state,rest_time,order_time,wash_light,dwash_light,dry_light,start_light,
buzzer_light);
    divider ins_divider (clk,clk_1HZ,clk_10000HZ);
    display ins_display (clk_10000HZ,power_light,current_time,total_time,current_water,rest_time,digit_show,AN);
    order ins_order (clk,power_light,order_time,clean_time,run_state,rest_time);
endmodule