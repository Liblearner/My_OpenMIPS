`include "defines.v"
//仿存阶段，负责访问RAM，取出想要的数据，但由于ORI指令不需要仿存，固我们只需要传递数据即可


module mem(
    input wire rst,
    input wire[`RegAddrBus] wd_i,
    input wire[`RegBus] wdata_i,
    input wire wreg_i,

    output reg[`RegAddrBus] wd_o,
    output reg[`RegBus] wdata_o,
    output reg wreg_o
);

always @(*) begin
    if(rst == `RstEnable) begin
    wd_o <= `RegNopAddr;
    wdata_o <= `RegNopData;
    wreg_o <= 1'b0;
    end
    else begin
    wd_o <= wd_i;
    wdata_o <= wdata_i;
    wreg_o <= wreg_i;
    end

end

endmodule