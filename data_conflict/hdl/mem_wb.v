`include "defines.v"
module mem_wb(
    input wire clk,
    input wire rst,
    input wire[`RegAddrBus] mem_wd,
    input wire[`RegBus] mem_wdata,
    input wire mem_wreg,

    output reg[`RegAddrBus] wb_wd,
    output reg[`RegBus] wb_wdata,
    output reg wb_wreg
);
always @(posedge clk) begin
    if(rst == `RstEnable) begin
    wb_wd <= `RegNopAddr;
    wb_wdata <= 32'b0;
    wb_wreg <= 1'b0;
    end
    else begin
    wb_wd <= mem_wd;
    wb_wdata <= mem_wdata;
    wb_wreg <= mem_wreg;
    end

end


endmodule
