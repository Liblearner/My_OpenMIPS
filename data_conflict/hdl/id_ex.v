`include "defines.v"
//传递阶段的寄存器
module id_ex(
    input wire clk,
    input wire rst,

    input wire[`AluOpBus] id_aluop,
    input wire[`AluSelBus] id_alusel,

    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
    input wire id_wreg,
    input wire[`RegAddrBus] id_wd,

    output reg[`AluOpBus] ex_aluop,
    output reg[`AluSelBus] ex_alusel,

    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg ex_wreg,
    output reg[`RegAddrBus] ex_wd
    );

always @(posedge clk) begin
    if(rst == `RstEnable)begin
    ex_aluop  <= `EXE_NOP_OP;
    ex_alusel <= `EXE_RES_NOP;
    ex_reg1 <= 32'b0;
    ex_reg2 <= 32'b0;
    ex_wreg <= 1'b0;
    ex_wd <= `RegNopAddr;
    
    end
    else begin
    ex_aluop  <= id_aluop;
    ex_alusel <= id_alusel;
    ex_reg1 <= id_reg1;
    ex_reg2 <= id_reg2;
    ex_wreg <= id_wreg;
    ex_wd <= id_wd;
    end
    end

endmodule