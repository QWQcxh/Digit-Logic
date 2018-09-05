`timescale 1 ns / 1 ps
module seven_decoder(num,digit_show);
    input wire [3:0] num;
    output reg [7:0] digit_show;

    always @ (num)
        begin
          case (num)
            0:digit_show<=8'b11000000;
            1:digit_show<=8'b11111001;
            2:digit_show<=8'b10100100;
            3:digit_show<=8'b10110000;
            4:digit_show<=8'b10011001;
            5:digit_show<=8'b10010010;
            6:digit_show<=8'b10000010;
            7:digit_show<=8'b11111000;
            8:digit_show<=8'b10000000;
            9:digit_show<=8'b10010000;
            default:digit_show<=8'b11111111;
          endcase
        end
endmodule