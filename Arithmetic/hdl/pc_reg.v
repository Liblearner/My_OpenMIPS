`include "defines.v"
//pc_reg only need to get the addr, no need for data
module pc_reg(

    input wire clk,
    input wire rst,
    input wire[5:0] stall,//来自控制模块CTRL

    output reg[`InstAddrBus] pc,
    output reg ce
);

//first consider the rst, to decide whether the ROM ia able
always @(posedge clk) begin
    if(rst == `RstEnable)
        ce <= `ChipDisable;
    else
        ce <= `ChipEnable;

end

//then for the behavior of pc,reset or plus 4
always @(posedge clk) begin
    if(ce == `ChipDisable)
        pc <= 32'b0;
    else if(stall[0] == `NoStop)
        pc <= pc+4'h4;

end


endmodule