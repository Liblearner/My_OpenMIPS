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

    //HI与LO的值
    input wire [`RegBus] hi_i,
    input wire [`RegBus] lo_i,

    //回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据冲突
    input wire [`RegBus] wb_hi_i,
    input wire [`RegBus] wb_lo_i,
    input wire wb_whilo_i,

    //访存阶段的指令是否要写HI、LO，用于检测HI、LO的数据冲突
    input wire [`RegBus] mem_hi_i,
    input wire [`RegBus] mem_lo_i,
    input wire mem_whilo_i,

    output reg[`RegBus] wdata,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,

    //连接到HI与LO
    output reg [`RegBus] hi_o,
    output reg [`RegBus] lo_o,
    output reg whilo_o
);

    reg[`RegBus] logicout;
    reg[`RegBus] shiftres;
    reg[`RegBus] moveres;
    reg[`RegBus] HI;
    reg[`RegBus] LO;

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

always @ (*) begin
	if(rst == `RstEnable) begin
  	moveres <= 32'b0;
  end else begin
    moveres <= 32'b0;
   case (aluop)
   	`EXE_MFHI_OP:		begin
   		moveres <= HI;
   	end
   	`EXE_MFLO_OP:		begin
   		moveres <= LO;
   	end
   	`EXE_MOVZ_OP:		begin
   		moveres <= reg1;
   	end
   	`EXE_MOVN_OP:		begin
   		moveres <= reg1;
   	end
   	default : begin
   	end
   endcase
  end
end	 

//得到最新的HI、LO寄存器的值，并在这里解决指令数据相关问题
always @(*) begin
    if(rst == `RstEnable) begin
        {HI,LO} <= {32'b0, 32'b0};
    end
    else if(mem_whilo_i == `WriteEnable) begin
        {HI,LO} <= {mem_hi_i,mem_lo_i};
    end
    else if(wb_whilo_i == `WriteEnable) begin
        {HI,LO} <= {wb_hi_i,wb_lo_i};
    end
    else
        {HI,LO} <= {hi_i,lo_i};
end




//第二阶段，根据alusel制定类型选择一个结果作为最终结果
always @(*) begin
    wd_o <= wd_i;
    wreg_o <= wreg_i;
    case(alusel)
    `EXE_RES_LOGIC:begin
        wdata <= logicout;
    end
    `EXE_RES_SHIFT:begin
        wdata <= shiftres;
    end
    `EXE_RES_MOVE:begin
        wdata <= moveres;
    end
    default:
        wdata <= 32'b0;
    endcase
end

//对于MTHI与MTLO，实现whilo_o与HI与LO的写输出
always @ (*) begin
	if(rst == `RstEnable) begin
		whilo_o <= `WriteDisable;
		hi_o <= 32'b0;
		lo_o <= 32'b0;		
	end else if(aluop == `EXE_MTHI_OP) begin
		whilo_o <= `WriteEnable;
		hi_o <= reg1;
		lo_o <= LO;
	end else if(aluop == `EXE_MTLO_OP) begin
		whilo_o <= `WriteEnable;
		hi_o <= HI;
		lo_o <= reg1;
	end else begin
		whilo_o <= `WriteDisable;
		hi_o <= 32'b0;
		lo_o <= 32'b0;
	end				
end		

endmodule