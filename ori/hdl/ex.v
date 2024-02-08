`include "defines.v"
//执行阶段，主要负责运算，调用ALU或者写寄存器，并产生输出结果
module ex(
    input wire rst,
    input wire[`AluOpBus] aluop,
    input wire[`AluSelBus] alusel,
    
    input wire[`RegBus] reg1,
    input wire[`RegBus] reg2,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,

    output reg[`RegBus] wdata,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o
);

    reg[`RegBus] logicout;
//第一阶段，根据aluop码进行运算或处理
always@(*) begin
    if(rst == `RstEnable)begin
    logicout <= 32'b0;
    end
    else begin
        case(aluop)
        `EXE_ORI_OP:begin
            logicout <= reg1 | reg2;
            end
        default:begin
        logicout <= 32'b0;
        end
        endcase
    end
end
//第二阶段，根据alusel制定类型选择一个结果作为最终结果
always @(*) begin
    wd_o <= wd_i;
    wreg_o <= wreg_i;
    case(alusel)
    `EXE_RES_LOGIC:begin
    wdata <= logicout;
    end
    default:
    wdata <= 32'b0;
    endcase
end



endmodule