//定义寄存器组，提供读写接口；最终即映射为寄存器组
//并且最终实现了write back模块的功能，将数据写回
`include"defines.v"

module Regfile(
input wire clk,
input wire rst,

input wire[`RegAddrBus] wAddr,
input wire[`RegBus]     wData,
input wire we,

input wire re1,
input wire[`RegAddrBus] rAddr1,
output reg[`RegBus]     rData1,

input wire re2,
input wire[`RegAddrBus] rAddr2,
output reg[`RegBus]     rData2


);
//定义通用寄存器组
reg[`RegBus] regs[0:`RegNum - 1];

//写行为
always @(posedge clk ) begin
    if(rst == `RstDisable) begin
        if(we == `WriteEnable  && wAddr != `RegNumLog2'b0) begin
        regs[wAddr] <= wData;
        end
    end
end

//读行为端口1
always @(*) begin
    if(rst == `RstEnable) begin
        rData1 <= 32'b0;
    end
    else if(rAddr1 == `RegNumLog2'b0)begin
        rData1 <= 32'b0;
    end    
    else if(re1 == `ReadEnable) begin
        rData1 <= regs[rAddr1];
    end
    else begin
        rData1 <= 32'b0;
    end

end
//读行为端口1
always @(*) begin
    if(rst == `RstEnable) begin
        rData2 <= 32'b0;
    end
    else if(rAddr1 == `RegNumLog2'b0)begin
        rData2 <= 32'b0;
    end    
    else if(re1 == `ReadEnable) begin
        rData2 <= regs[rAddr2];
    end
    else begin
        rData2 <= 32'b0;
    end

end

endmodule
