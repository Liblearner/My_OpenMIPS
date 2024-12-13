`include "defines.v"
//传递阶段的寄存器
module id_ex(
    input wire clk,
    input wire rst,

    input wire[5:0] stall,

    input wire[`AluOpBus] id_aluop,
    input wire[`AluSelBus] id_alusel,

    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
    input wire id_wreg,
    input wire[`RegAddrBus] id_wd,

    //跳转指令相关，来自ID
    input wire[`RegBus] id_link_address,
    input wire id_is_in_delayslot,
    input wire next_inst_in_delayslot_i,

    output reg[`AluOpBus] ex_aluop,
    output reg[`AluSelBus] ex_alusel,

    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg ex_wreg,
    output reg[`RegAddrBus] ex_wd

    //跳转相关，送到EX
    output reg[`RegBus] ex_link_address,
    output reg ex_is_in_delayslot,
    output reg is_in_delayslot_o
    );

always @(posedge clk) begin
    if(rst == `RstEnable)begin
    ex_aluop  <= `EXE_NOP_OP;
    ex_alusel <= `EXE_RES_NOP;
    ex_reg1 <= 32'b0;
    ex_reg2 <= 32'b0;
    ex_wreg <= 1'b0;
    ex_wd <= `RegNopAddr;
    ex_link_address <= 32'b0;
    ex_is_in_delayslot <= `NotInDelaySlot;
    is_in_delayslot_o <= `NotInDelaySlot;
    end
    else if(stall[2] == `Stop && stall[3] == `NoStop) begin
    ex_aluop  <= `EXE_NOP_OP;
    ex_alusel <= `EXE_RES_NOP;
    ex_reg1 <= 32'b0;
    ex_reg2 <= 32'b0;
    ex_wreg <= 1'b0;
    ex_wd <= `RegNopAddr;
    ex_link_address <= 32'b0;
    ex_is_in_delayslot <= `NotInDelaySlot;
    end
    else if(stall[2] == `NoStop)begin
    ex_aluop  <= id_aluop;
    ex_alusel <= id_alusel;
    ex_reg1 <= id_reg1;
    ex_reg2 <= id_reg2;
    ex_wreg <= id_wreg;
    ex_wd <= id_wd;
    ex_link_address <= id_link_address;
    ex_is_in_delayslot <= id_is_in_delayslot;
    is_in_delayslot_o <= next_inst_in_delayslot_i;
    end
    end

endmodule