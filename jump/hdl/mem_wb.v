`include "defines.v"
module mem_wb(
    input wire clk,
    input wire rst,
    input wire[`RegAddrBus] mem_wd,
    input wire[`RegBus] mem_wdata,
    input wire mem_wreg,

    input wire mem_whilo,
    input wire[`RegBus] mem_hi,
    input wire[`RegBus] mem_lo,

    input wire[5:0] stall,
    
    output reg[`RegAddrBus] wb_wd,
    output reg[`RegBus] wb_wdata,
    output reg wb_wreg,

    output reg wb_whilo,
    output reg[`RegBus] wb_hi,
    output reg[`RegBus] wb_lo
);
always @(posedge clk) begin
    if(rst == `RstEnable) begin
    wb_wd <= `RegNopAddr;
    wb_wdata <= 32'b0;
    wb_wreg <= 1'b0;
    wb_whilo <= 1'b0;
    wb_hi <= 32'b0;
    wb_lo <= 32'b0;
    end
    else if(stall[4] == `Stop && stall[5] == `NoStop)begin
    wb_wd <= `RegNopAddr;
    wb_wdata <= `ZeroWord;
    wb_wreg <= `WriteDisable;
    wb_hi <= `ZeroWord;
    wb_lo <= `ZeroWord;
    wb_whilo <= `WriteDisable;
    end
    else if(stall[4] == `NoStop)begin
    wb_wd <= mem_wd;
    wb_wdata <= mem_wdata;
    wb_wreg <= mem_wreg;
    wb_whilo <= mem_whilo;
    wb_hi <= mem_hi;
    wb_lo <= mem_lo;
    end

end


endmodule