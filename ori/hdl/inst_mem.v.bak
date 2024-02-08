`include "defines.v"
module inst_mem(
    input wire ce,
    input wire[`InstAddrBus] addr,
    output reg[`InstBus] inst
);
//通过定义寄存器组的方式定义ROM
reg[`InstBus] inst_mem[0:`InstMemNum-1];

//使用rom.data来initial ROM。但initial不可以被综合
initial $readmemh ("inst_mem.data", inst_mem);

always @(*) begin
    if(ce == `ChipDisable)
        inst <= 32'b0;
    else begin
        inst <= inst_mem[addr[`InstMemNumLog2 + 1 : 2]];//将地址右移2位按字读出
    end
end


endmodule