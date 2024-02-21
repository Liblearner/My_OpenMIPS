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
    else begin
    wb_wd <= mem_wd;
    wb_wdata <= mem_wdata;
    wb_wreg <= mem_wreg;
    wb_whilo <= mem_whilo;
    wb_hi <= mem_hi;
    wb_lo <= mem_lo;
    end

end


endmodule
