`include "defines.v"
//pc_reg only need to get the addr, no need for data
module pc_reg(

    input wire clk,
    input wire rst,
    input wire[5:0] stall,//来自控制模块CTRL

    input wire branch_target_address_i,
    input wire [`RegBus] branch_flag_address_i,
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
    else if(stall[0] == `NoStop) begin
        if(branch_target_address_i == `Branch)begin
            pc <= branch_flag_address_i
        end
        else
            pc <= pc+4'h4;
    end
end


endmodule