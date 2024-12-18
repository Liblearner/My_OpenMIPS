`include "defines.v"
module ex_mem(
    input wire clk,
    input wire rst,
    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,

    input wire[`RegBus] ex_hi,
    input wire[`RegBus] ex_lo,
    input wire ex_whilo,

    input wire[5:0] stall,

    input wire[`DoubleRegBus] hilo_i,
    input wire[1:0] cnt_i,

    output reg[`DoubleRegBus] hilo_o,
    output reg[1:0] cnt_o,

    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata,

    output reg mem_whilo,
    output reg[`RegBus] mem_hi,
    output reg[`RegBus] mem_lo

    
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
        mem_wd <= `RegNopAddr;
        mem_wreg <= 1'b0;
        mem_wdata <= `RegNopData;

        mem_hi <= 32'b0;
        mem_lo <= 32'b0;
        mem_whilo <= 1'b0;

        hilo_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
        end

        else if(stall[3] == `Stop && stall[4] == `NoStop)begin
        mem_wd <= `RegNopAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;

        mem_hi <= `ZeroWord;
        mem_lo <= `ZeroWord;
        mem_whilo <= `WriteDisable;

        hilo_o <= hilo_i;
        cnt_o <= cnt_i;
        end
        
        else if(stall[3] == `NoStop)begin
        mem_wd <= ex_wd;
        mem_wdata <= ex_wdata;
        mem_wreg <= ex_wreg;

        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;

        hilo_o <= hilo_i;
        cnt_o <= cnt_i;
        end
    end


endmodule