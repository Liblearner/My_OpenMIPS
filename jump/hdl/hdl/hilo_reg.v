/*
实现HI与LO特殊寄存器，定义其读写行为
*/
`include "defines.v"
module hilo_reg (
    input wire clk,
    input wire rst,

    input wire we,
    input wire [`RegBus] hi_i,
    input wire [`RegBus] lo_i,

    output reg [`RegBus] hi_o,
    output reg [`RegBus] lo_o
);
    always @(posedge clk) begin
        if(rst == `RstEnable)begin
            hi_o <= 32'b0;
            lo_o <= 32'b0;
        end
        else if((we == `WriteEnable))begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
    end
endmodule
