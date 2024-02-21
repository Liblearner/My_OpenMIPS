`include "defines.v"
//仿存阶段，负责访问RAM，取出想要的数据，但由于ORI指令不需要仿存，固我们只需要传递数据即可


module mem(
    input wire rst,
    input wire[`RegAddrBus] wd_i,
    input wire[`RegBus] wdata_i,
    input wire wreg_i,

    input wire whilo_i,
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,

    output reg[`RegAddrBus] wd_o,
    output reg[`RegBus] wdata_o,
    output reg wreg_o,

    output reg whilo_o,
    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o
);

always @(*) begin
    if(rst == `RstEnable) begin
    wd_o <= `RegNopAddr;
    wdata_o <= `RegNopData;
    wreg_o <= 1'b0;
    whilo_o <= 1'b0;
    hi_o <= 32'b0;
    lo_o <= 32'b0;

    end
    else begin
    wd_o <= wd_i;
    wdata_o <= wdata_i;
    wreg_o <= wreg_i;
    whilo_o <= whilo_i;
    hi_o <= hi_i;
    lo_o <= lo_i;

    end

end

endmodule