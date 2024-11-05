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

    //实现累乘增加的输入
    input wire[`DoubleRegBus] hilo_temp_i,
    input wire[1:0] cnt_i,
    
    //实现除法增加的输入
    input wire[`DoubleRegBus] div_result_i,
    input wire div_ready_i,

    output reg[`RegBus] wdata,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,

    output reg[`DoubleRegBus] hilo_temp_o,
    output reg[1:0] cnt_o,

    //连接到HI与LO
    output reg [`RegBus] hi_o,
    output reg [`RegBus] lo_o,
    output reg whilo_o,

    //除法输出
    output reg[`RegBus] div_opdata1_o,
    output reg[`RegBus] div_opdata2_o,
    output reg div_start_o,
    output reg signed_div_o,

    output reg stallreq
);

    reg[`RegBus] logicout;
    reg[`RegBus] shiftres;
    reg[`RegBus] moveres;
    reg[`RegBus] HI;
    reg[`RegBus] LO;

    //运算用的变量
    wire ov_sum;                    //保存溢出情况
    wire reg1_eq_reg2;              //第一个操作数是否等于第二个操作数
    wire reg1_lt_reg2;              //第一个操作数是否小于第二个操作数
    reg[`RegBus] arithmeticres;     //算数运算结果
    wire[`RegBus] reg2_mux;         //保存输入的第二个操作数reg2的补码
    wire[`RegBus] reg1_not;         //保存输入的第一个操作数reg1取反的值
    wire[`RegBus] result_sum;       //保存假发结果
    wire[`RegBus] opdata1_mult;     //乘法中的被乘数
    wire[`RegBus] opdata2_mult;     //乘法中的乘数
    wire[`DoubleRegBus] hilo_temp;  //临时保存乘法结果，宽度64bit
    reg[`DoubleRegBus] hilo_temp1;  //累乘命令临时结果保存
    reg[`DoubleRegBus] mulres;      //保存乘法结果，宽度64bit

    reg stallreq_for_madd_msub;     //累乘请求暂停
    reg stallreq_for_div;           //除法请求暂停

//第一阶段，根据aluop码进行运算或处理,logic,shift.move与arithmetic分always块


//取补码的情况：减法，此外SLT的执行也用到了减法
assign reg2_mux = ((aluop == `EXE_SUB_OP) || (aluop == `EXE_SUBU_OP) || 
                    (aluop == `EXE_SLT_OP))?(~reg2) + 1 : reg2;

//求和
assign result_sum = reg1 + reg2_mux;

//求和溢出的情况：负数+负数=正数，正数+正数=负数
assign ov_sum = ((!reg1[31] && !reg2_mux[31] && result_sum[31])) || 
                (reg1[31] && reg2[31] && result_sum[31]);

//比较大小运算,不是SLT运算的部分是？
assign reg1_lt_reg2 = (aluop == `EXE_SLT_OP)?
                        ((reg1[31] && !reg2[31])||(!reg1[31] && !reg2[31] && result_sum[31])
                        ||(reg1[31] && reg2[31] && result_sum[31])) : (reg1 < reg2);

assign reg1_not = ~reg1;


always @(*) begin
    if(rst == `RstEnable)begin
        arithmeticres <= 32'b0;
    end
    else begin
        case (aluop)
        `EXE_SLT_OP, `EXE_SLTU_OP:
            arithmeticres <= reg1_lt_reg2;
        `EXE_ADD_OP, `EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP:
            arithmeticres <= result_sum;
        `EXE_SUB_OP, `EXE_SUBU_OP:
            arithmeticres <= result_sum;
        `EXE_CLZ_OP://数0的个数，到1停止
            arithmeticres <= (reg1[31] ? 0 : reg1[30] ? 1 : reg1[29] ? 2:
            reg1[28] ? 3 : reg1[27] ? 4 : reg1[26] ? 5 : reg1[25] ? 6 : 
            reg1[24] ? 7 : reg1[23] ? 8 : reg1[22] ? 9 : reg1[21] ? 10:
            reg1[20] ? 11 : reg1[19] ? 12 : reg1[18] ? 13 : reg1[17] ? 14:
            reg1[16] ? 15 : reg1[15] ? 16 : reg1[14] ? 17 : reg1[13] ? 18:
            reg1[12] ? 19 : reg1[11] ? 20 : reg1[10] ? 21 : reg1[9] ? 22:
            reg1[8] ? 23 : reg1[7] ? 24 : reg1[6] ? 25 : reg1[5] ? 26 :
            reg1[4] ? 27 : reg1[3] ? 28 : reg1[2] ? 29: reg1[1] ? 30 :
            reg1[0] ? 31 : 32);
        `EXE_CLO_OP://数1的个数，到0停止，可以利用取非来判断
            arithmeticres <= (reg1_not[31] ? 0 : reg1_not[30] ? 1 : reg1_not[29] ? 2:
            reg1_not[28] ? 3 : reg1_not[27] ? 4 : reg1_not[26] ? 5 : reg1_not[25] ? 6 : 
            reg1_not[24] ? 7 : reg1_not[23] ? 8 : reg1_not[22] ? 9 : reg1_not[21] ? 10:
            reg1_not[20] ? 11 : reg1_not[19] ? 12 : reg1_not[18] ? 13 : reg1_not[17] ? 14:
            reg1_not[16] ? 15 : reg1_not[15] ? 16 : reg1_not[14] ? 17 : reg1_not[13] ? 18:
            reg1_not[12] ? 19 : reg1_not[11] ? 20 : reg1_not[10] ? 21 : reg1_not[9] ? 22:
            reg1_not[8] ? 23 : reg1_not[7] ? 24 : reg1_not[6] ? 25 : reg1_not[5] ? 26 :
            reg1_not[4] ? 27 : reg1_not[3] ? 28 : reg1_not[2] ? 29: reg1_not[1] ? 30 :
            reg1_not[0] ? 31 : 32);
        default:
            arithmeticres <= 32'b0;
        endcase
    end
end

//取得乘法操作的操作数，如果是有符号除法且操作数是负数，则取反+1
assign opdata1_mult = (((aluop == `EXE_MUL_OP) || (aluop == `EXE_MULT_OP)
                        ||(aluop == `EXE_MADD_OP) || (aluop == `EXE_MSUB_OP)) 
                        && (reg1[31] == 1'b1)) ? (~reg1 + 1) : reg1;
assign opdata2_mult = (((aluop == `EXE_MUL_OP) || (aluop == `EXE_MULT_OP)
                        ||(aluop == `EXE_MADD_OP) || (aluop == `EXE_MSUB_OP)) 
                        && (reg2[31] == 1'b1)) ? (~reg2 + 1) : reg2;

assign hilo_temp = opdata1_mult * opdata2_mult;

always@(*) begin
    if(rst == `RstEnable)
        mulres <= 64'b0;
    else if((aluop == `EXE_MUL_OP) || (aluop == `EXE_MULT_OP) ||
            (aluop == `EXE_MADD_OP) ||(aluop == `EXE_MSUB_OP))begin
        //最高位异或，不一样说明是异号相乘
        if(reg1[31] ^ reg2[31] == 1'b1)
            mulres <= ~hilo_temp + 1;
        //有符号数但同号的情况
        else
            mulres <= hilo_temp;
    end
    //无符号数
    else
        mulres <= hilo_temp;
end

always @(*) begin
    if(rst == `RstEnable)begin
        hilo_temp_o <= {`ZeroWord, `ZeroWord};
        cnt_o <= 2'b00;
        stallreq_for_madd_msub <= `NoStop;
    end
    else begin
        case(aluop)
        `EXE_MADD_OP, `EXE_MADDU_OP:begin
            //双周期计算的第一个周期
            if(cnt_i == 2'b00) begin
                hilo_temp_o <= mulres;
                cnt_o <= 2'b01;
                hilo_temp1 <= {`ZeroWord, `ZeroWord};
                stallreq_for_madd_msub <= `Stop;
            end
            //双周期计算的第二个周期
            else if(cnt_i == 2'b01) begin
                hilo_temp_o <= {`ZeroWord, `ZeroWord};
                cnt_o <= 2'b10;
                hilo_temp1 <= hilo_temp_i + {HI, LO};
                stallreq_for_madd_msub <= `NoStop;
            end
        end
        `EXE_MSUB_OP, `EXE_MSUBU_OP:begin
            if(cnt_i == 2'b00) begin
                hilo_temp_o <= ~mulres + 1;
                cnt_o <= 2'b01;
                hilo_temp1 <= {`ZeroWord, `ZeroWord};
                stallreq_for_madd_msub <= `Stop;
            end
            else if(cnt_i == 2'b01)begin
                hilo_temp_o <= {`ZeroWord, `ZeroWord};
                cnt_o <= 2'b01;
                hilo_temp1 <= hilo_temp_i + {HI, LO};
                stallreq_for_madd_msub <= `Stop;
            end
        end
        default:begin
            hilo_temp_o <= {`ZeroWord, `ZeroWord};
            cnt_o <= 2'b00;
            stallreq_for_madd_msub <= `NoStop;
        end
        endcase
    end
end





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

    if(((aluop == `EXE_ADD_OP) || (aluop == `EXE_ADDI_OP) || 
            (aluop == `EXE_SUB_OP)) && (ov_sum == 1'b1))
        wreg_o <= `WriteDisable;
    else
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
    `EXE_RES_ARITHMETIC:begin
        wdata <= arithmeticres;
    end
    `EXE_RES_MUL:begin
        wdata <= mulres[31:0];
    end
    default:
        wdata <= 32'b0;
    endcase
end

always @(*) begin
    stallreq = stallreq_for_madd_msub || stallreq_for_div;
end


//对于MTHI与MTLO，实现whilo_o与HI与LO的写输出
always @ (*) begin
	if(rst == `RstEnable) begin
		whilo_o <= `WriteDisable;
		hi_o <= 32'b0;
		lo_o <= 32'b0;		
    end else if((aluop == `EXE_MSUB_OP)||(aluop == `EXE_MSUBU_OP))begin 
        whilo_o <= `WriteEnable;
        hi_o <= hilo_temp1[63:32];
        lo_o <= hilo_temp1[31:0];
    end else if((aluop == `EXE_MADD_OP)||(aluop == `EXE_MADDU_OP))begin 
        whilo_o <= `WriteEnable;
        hi_o <= hilo_temp1[63:32];
        lo_o <= hilo_temp1[31:0];
    end else if((aluop == `EXE_MULT_OP) || (aluop == `EXE_MULTU_OP)) begin
        whilo_o <= `WriteEnable;
        hi_o <= mulres[63:32];
        lo_o <= mulres[31:0];
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