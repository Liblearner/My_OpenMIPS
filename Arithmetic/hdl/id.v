`include"defines.v"
//ID，即译码器，使用case的方式匹配译码，根据指令输出控制信号，组合逻辑
module id(

    input wire rst,
    input wire[`InstAddrBus] pc,
    input wire[`InstBus]     inst,
//从Regfile中读写，提供给ex阶段
    input wire[`RegBus]  reg1_data_i,//从RegFile预读出的reg数据？
    input wire[`RegBus]  reg2_data_i,

    input wire ex_wreg_i,
    input wire[`RegAddrBus] ex_wd_i,
    input wire[`RegBus] ex_wdata_i,

    input wire mem_wreg_i,
    input wire[`RegAddrBus] mem_wd_i,
    input wire[`RegBus] mem_wdata_i,

    output reg reg1_read_o,        //提供给RegFile的reg读使能信号与地址
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

//送到EX阶段（ALU与Reg）
    output reg[`AluOpBus] aluop_o,//ALU操作与选择码
    output reg[`AluSelBus] alusel_o,

    output reg[`RegBus] reg1_data_o,//译码阶段进行的源操作数
    output reg[`RegBus] reg2_data_o,
    output reg[`RegAddrBus] wd_o,//要写入的目的寄存器的地址
    output reg wreg_o//指令是否需要写入目的寄存器
);

//第一步：取指令中指令码（不仅仅是针对I型指令）
wire [5:0] op = inst[31:26];//指令码
wire [5:0] op2 = inst[10:6];//对于R型中的位移指令是一个立即数
wire [5:0] op3 = inst[5:0];//特征码，在R型指令确定是运算类之后根据这个判断操作类型
wire [5:0] op4 = inst[20:16];//rt,部分操作数

//保存指令中的立即数
reg[`RegBus] imm;
//指示指令是否有效
reg instvaild;

/*第一阶段译码,
向ALU传递操作码与选择码，
向Regfile传递读使能信号与地址，
给出目的寄存器的写信号与地址，
以及指令与立即数的状态
*/
always @(*) begin
    if(rst == `RstEnable) begin
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `RegNopAddr;
        reg2_addr_o <= `RegNopAddr;
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= `RegNopAddr;
        wreg_o <= `WriteDisable;   
        imm <= 32'b0;
        instvaild <= `InstVaild;//重置时设置指令为有效？
    end
    //先将信号归到默认状态，后面再根据op更新
    else begin
        reg1_read_o <= 1'b0;  
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst[25:21];
        reg2_addr_o <= inst[20:16];
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= inst[15:11];
        wreg_o <= `WriteDisable;   
        imm <= 32'b0;
        instvaild <= `InstInvaild;   

        case(op)
            `EXE_ORI:begin
            //运算类型
            aluop_o <= `EXE_ORI_OP;
            alusel_o <= `EXE_RES_LOGIC;
            //(由上面rst处可知，reg1对应rs，即inst[25:21]，接口2当源操作数是立即数时便不需要)
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            wd_o <= inst[20:16];
            wreg_o <= `WriteEnable;
            imm <= {16'h0,inst[15:0]};
            instvaild <= `InstVaild;
            end
            
            `EXE_ANDI: begin
            //运算类型
            aluop_o <= `EXE_ANDI_OP;
            alusel_o <= `EXE_RES_LOGIC;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            wd_o <= inst[20:16];
            wreg_o <= `WriteEnable;
            imm <= {16'h0,inst[15:0]};
            instvaild <= `InstVaild;     
            end     

            `EXE_XORI: begin
            aluop_o <= `EXE_XORI_OP;
            alusel_o <= `EXE_RES_LOGIC;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            wd_o <= inst[20:16];
            wreg_o <= `WriteEnable;
            imm <= {16'h0,inst[15:0]};
            instvaild <= `InstVaild;
            end

            //lui的功能是将立即数填至高16bit，低16bit用0填充
            //实现是通过将imm填到高16bit并且和0或运算之后写入得到
            `EXE_LUI: begin
            aluop_o <= `EXE_LUI_OP;//或者用OR来实现？
            alusel_o <= `EXE_RES_LOGIC;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            wd_o <= inst[20:16];
            wreg_o <= `WriteEnable;
            imm <= {inst[15:0],16'h0};//此处和别的不同，需要将指令中的立即数放在高16bit
            instvaild <= `InstVaild;             
            end

            `EXE_PREF:begin
            //运算类型
            aluop_o <= `EXE_NOP_OP;
            alusel_o <= `EXE_RES_LOGIC;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            wreg_o <= `WriteDisable;
            instvaild <= `InstVaild;
            end

            `SPECIAL:begin
                case(op2)//inst[10:6]
                    5'b00000:begin
                        case(op3)//inst[5:0]
                            `AND:begin
                                    aluop_o <= `EXE_AND_OP;
                                    alusel_o <= `EXE_RES_LOGIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wd_o <= inst[15:11];//可以不写，和上面的重复了
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                                end
                            `OR:begin
                                    aluop_o <= `EXE_OR_OP;
                                    alusel_o <= `EXE_RES_LOGIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wd_o <= inst[15:11];
                                    imm <= 32'b0;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;  
                                end
                            `XOR:begin
                                    aluop_o <= `EXE_XOR_OP;
                                    alusel_o <= `EXE_RES_LOGIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wd_o <= inst[15:11];
                                    wreg_o <= `WriteEnable;
                                    imm <= 32'b0;
                                    instvaild <= `InstVaild; 
                                    end
                            `NOR:begin
                                    aluop_o <= `EXE_NOR_OP;
                                    alusel_o <= `EXE_RES_LOGIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wd_o <= inst[15:11];
                                    wreg_o <= `WriteEnable;
                                    imm <= 32'b0;
                                    instvaild <= `InstVaild;
                                end
                            `SLLV:begin
                                    aluop_o <= `EXE_SLLV_OP;
                                    alusel_o <= `EXE_RES_SHIFT;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wd_o <= inst[15:11];
                                    wreg_o <= `WriteEnable;
                                    imm <= 32'b0;
                                    instvaild <= `InstVaild;
                                end
                            `SRLV:begin
                                    aluop_o <= `EXE_SRLV_OP;
                                    alusel_o <= `EXE_RES_SHIFT;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wd_o <= inst[15:11];
                                    wreg_o <= `WriteEnable;
                                    imm <= 32'b0;
                                    instvaild <= `InstVaild;
                                end
                            `SRAV:begin
                                    aluop_o <= `EXE_SRAV_OP;
                                    alusel_o <= `EXE_RES_SHIFT;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wd_o <= inst[15:11];
                                    wreg_o <= `WriteEnable;
                                    imm <= 32'b0;
                                    instvaild <= `InstVaild;                               
                                end
                            `SYNC:begin
                                    aluop_o <= `EXE_NOP_OP;
                                    alusel_o <= `EXE_RES_NOP;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteDisable;
                                    instvaild <= `InstVaild;                                    
                                end
                            `MOVN:begin
                                    aluop_o <= `EXE_MOVN_OP;
                                    alusel_o <= `EXE_RES_MOVE;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    if(reg2_data_o != 32'b0)
                                        wreg_o <= `WriteEnable;
                                    else
                                        wreg_o <= `WriteDisable;
                                    instvaild <= `InstVaild;
                            end
                            `MOVZ:begin
                                    aluop_o <= `EXE_MOVZ_OP;
                                    alusel_o <= `EXE_RES_MOVE;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b1;
                                    if(reg2_data_o == 32'b0)
                                        wreg_o <= `WriteEnable;
                                    else
                                        wreg_o <= `WriteDisable;
                                    instvaild <= `InstVaild;
                            end
                            `MFHI:begin
                                    aluop_o <= `EXE_MFHI_OP;
                                    alusel_o <= `EXE_RES_MOVE;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                            end
                            `MFLO:begin
                                    aluop_o <= `EXE_MFLO_OP;
                                    alusel_o <= `EXE_RES_MOVE;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                            end
                            `MTHI:begin
                                    aluop_o <= `EXE_MTHI_OP;
                                    alusel_o <= `EXE_RES_NOP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= `WriteDisable;
                                    instvaild <= `InstVaild;
                            end
                            `MTLO:begin
                                    aluop_o <= `EXE_MTLO_OP;
                                    alusel_o <= `EXE_RES_NOP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= `WriteDisable;
                                    instvaild <= `InstVaild;
                            end
                            `SLT:begin
                                    aluop_o <= `EXE_SLT_OP;
                                    alusel_o <= `EXE_RES_ARITHMETIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                            end
                            `SLTU:begin
                                    aluop_o <= `EXE_SLTU_OP;
                                    alusel_o <= `EXE_RES_ARITHMETIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                            end
                            `ADD:begin
                                    aluop_o <= `EXE_ADD_OP;
                                    alusel_o <= `EXE_RES_ARITHMETIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                            end
                            `ADDU:begin
                                    aluop_o <= `EXE_ADDU_OP;
                                    alusel_o <= `EXE_RES_ARITHMETIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                            end
                            `SUB:begin
                                    aluop_o <= `EXE_SUB_OP;
                                    alusel_o <= `EXE_RES_ARITHMETIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                            end
                            `SUBU:begin
                                    aluop_o <= `EXE_SUBU_OP;
                                    alusel_o <= `EXE_RES_ARITHMETIC;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteEnable;
                                    instvaild <= `InstVaild;
                            end
                            `MULT:begin
                                    aluop_o <= `EXE_MULT_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteDisable;
                                    instvaild <= `InstVaild;
                            end
                            `MULTU:begin
                                    aluop_o <= `EXE_MULTU_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= `WriteDisable;
                                    instvaild <= `InstVaild;
                            end
                            default:begin
                            end
                        endcase//end case op3 inst[5:0]
                    end//end 5'b00000
                    //注意这里，由于指令中的sa是用户编写的随机数，因此根据这个来判断指令类别是不可行的
                    default: begin
                    end
                endcase//end case op2 inst[10:6]
            end// end `SPECIAL
            `SLTI:begin
            aluop_o <= `EXE_SLT_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            wreg_o <= `WriteEnable;
            instvaild <= `InstVaild;
            imm <= {{16{inst_i[15]}}, inst_i[15:0]}; 
            wd_o <= inst_i[20:16];               
            end
            `SLTIU:begin
            aluop_o <= `EXE_SLTU_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            wreg_o <= `WriteEnable;
            instvaild <= `InstVaild;
            imm <= {{16{inst_i[15]}}, inst_i[15:0]}; 
            wd_o <= inst_i[20:16];
            end
            `ADDI:begin
            aluop_o <= `EXE_ADDI_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            wreg_o <= `WriteEnable;
            instvaild <= `InstVaild;
            imm <= {{16{inst_i[15]}}, inst_i[15:0]}; 
            wd_o <= inst_i[20:16];
            end
            `ADDIU:begin
            aluop_o <= `EXE_ADDIU_OP;
            alusel_o <= `EXE_RES_ARITHMETIC;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            wreg_o <= `WriteEnable;
            instvaild <= `InstVaild;
            imm <= {{16{inst_i[15]}}, inst_i[15:0]}; 
            wd_o <= inst_i[20:16]; 
            end
            `SPECIAL2:begin
                case(op3):
                    `CLZ:begin
                    aluop_o <= `EXE_CLZ_OP;
                    alusel_o <= `EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= `WriteEnable;
                    instvaild <= `InstVaild; 
                    end
                    `CLO:begin
                    aluop_o <= `EXE_CLO_OP;
                    alusel_o <= `EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= `WriteEnable;
                    instvaild <= `InstVaild; 
                    end
                    `MUL:begin
                    aluop_o <= `EXE_MUL_OP;
                    alusel_o <= `EXE_RES_MUL;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= `WriteEnable;
                    instvaild <= `InstVaild; 
                    end
                    default:begin
                    end
                endcase //end `SPECIAL2 case(op3)
            end
            default:begin
            end
        endcase//end case op
//对指令中有sa特殊情况的指令单独判断解码，其特征是inst[25:21]均为0
//reg1[25:21]，reg2[20:16]
    if(inst[31:21] == 11'b0) begin
        case(op3)
            `EXE_SLL_OP:begin
                aluop_o <= `EXE_SLL_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                wd_o <= inst[15:11];
                wreg_o <= `WriteEnable;
                imm <= {27'b0,inst[10:6]};
                //imm[4:0] <= inst[10:6];
                instvaild <= `InstVaild;                 
            end
            `EXE_SRL_OP:begin
                aluop_o <= `EXE_SRL_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                wd_o <= inst[15:11];
                wreg_o <= `WriteEnable;
                imm <= {27'b0,inst[10:6]};
                instvaild <= `InstVaild; 
            end
            `EXE_SRA_OP:begin
                aluop_o <= `EXE_SRA_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                wd_o <= inst[15:11];
                wreg_o <= `WriteEnable;
                imm <= {27'b0,inst[10:6]};
                instvaild <= `InstVaild; 
            end
            default:begin
            end
        endcase
    end
    end//end rst = `Disable
end//end if 



//第二阶段，确定进行运算的源操作数：来自reg或者立即数，需要根据指令需要进行判断
//增加对数据冲突的处理，使用从EX或MEM阶段到ID阶段的数据旁路
always @(*) begin
    if(rst == `RstEnable)begin
        reg1_data_o <= 32'b0;
    end
    else if((reg1_read_o == 1'b1)&&(ex_wreg_i == 1'b1)&&(ex_wd_i == reg1_addr_o)) begin
        reg1_data_o <= ex_wdata_i;
    end
    
    else if((reg1_read_o == 1'b1)&&(mem_wreg_i == 1'b1)&&(mem_wd_i == reg1_addr_o)) begin
        reg1_data_o <= mem_wdata_i;
    end

    else if(reg1_read_o == 1'b1) begin
        reg1_data_o <= reg1_data_i;
    end
    else if(reg1_read_o == 1'b0) begin
        reg1_data_o <= imm;
    end
    else begin
        reg1_data_o <= 32'b0;
    end
    end


//reg2同理
always @(*) begin
    if(rst == `RstEnable)begin
        reg2_data_o <= 32'b0;
    end
    
    else if((reg2_read_o == 1'b1)&&(ex_wreg_i == 1'b1)&&(ex_wd_i == reg2_addr_o)) begin
        reg2_data_o <= ex_wdata_i;
    end
    
    else if((reg2_read_o == 1'b1)&&(mem_wreg_i == 1'b1)&&(mem_wd_i == reg2_addr_o)) begin
        reg2_data_o <= mem_wdata_i;
    end

    else if(reg2_read_o == 1'b1) begin
        reg2_data_o <= reg2_data_i;
    end
    else if(reg2_read_o == 1'b0) begin
        reg2_data_o <= imm;
    end
    else begin
        reg2_data_o <= 32'b0;
    end
    end

endmodule
