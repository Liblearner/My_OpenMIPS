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
    reg[`RegBus] shiftres;

//第一阶段，根据aluop码进行运算或处理,logic与shift分两个always块
always@(*) begin
    if(rst == `RstEnable)begin
    logicout <= 32'b0;
    end
    else begin
        //同类型带I与不带I的可以合并，LUI也可以合并，节省硬件开销
        case(aluop)
        `EXE_OR_OP:begin
            logicout <= reg1 | reg2;
        end
        `EXE_ORI_OP:begin
            logicout <= reg1 | reg2;
        end
        `EXE_AND_OP:begin
            logicout <= reg1 & reg2;
        end
        `EXE_ANDI_OP:begin
            logicout <= reg1 & reg2;
        end
        `EXE_NOR_OP:begin
            logicout <= ~(reg1 & reg2);
        end
        `EXE_XOR_OP:begin
            logicout <= reg1 ^ reg2;
        end
        `EXE_XORI_OP:begin
            logicout <= reg1 ^ reg2;
        end
        `EXE_LUI_OP:begin
            logicout <= reg1 | reg2;//reg1是$0，reg2高16bit是寄存器指令中值
        end
        default:begin
            logicout <= 32'b0;
        end
        endcase
    end
end

always@(*) begin
    if(rst == `RstEnable)begin
    shiftres <= 32'b0;
    end
    else begin
        case(aluop)
        `EXE_SLL_OP:begin
            shiftres <= reg2 << reg1[4:0];
        end
        `EXE_SLLV_OP:begin
            shiftres <= reg2 << reg1[4:0];
        end
        `EXE_SRL_OP:begin
            shiftres <= reg2 >> reg1[4:0];
        end
        `EXE_SRLV_OP:begin
            shiftres <= reg2 >> reg1[4:0];            
        end
        `EXE_SRA_OP:begin//算术移略显特殊
			shiftres <= ({32{reg2[31]}} << (6'd32-{1'b0, reg1[4:0]})) | reg2 >> reg1[4:0];
        end
        `EXE_SRAV_OP:begin
            shiftres <= ({32{reg2[31]}} << (6'd32-{1'b0, reg1[4:0]})) | reg2 >> reg1[4:0];      
        end
        default:begin
            shiftres <= 32'b0;
        end
        endcase
    end
end


//第二阶段，根据alusel制定类型选择一个结果作为最终结果
ialways @(*) begin
    wd_o <= wd_i;
    wreg_o <= wreg_i;
    case(alusel)
    `EXE_RES_LOGIC:begin
        wdata <= logicout;
    end
    `EXE_RES_SHIFT:begin
        wdata <= shiftres;
    end
    default:
        wdata <= 32'b0;
    endcase
end



endmodule