`include"defines.v"
//ID，即译码器，使用case的方式匹配译码，根据指令输出控制信号，组合逻辑
module id(

    input wire rst,
    input wire[`InstAddrBus] pc,
    input wire[`InstBus]     inst,
//从Regfile中读写
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
wire [5:0] op2 = inst[10:6];//
wire [5:0] op3 = inst[5:0];//
wire [5:0] op4 = inst[20:16];//

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
            //(默认接口1是读rs，即inst[25:21]，接口2当源操作数是立即数时便不需要)
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            //reg1_addr_o <= 在默认阶段已经给出地址（时序？）
            //reg2_addr_o <= 
            wd_o <= inst[20:16];
            wreg_o <= `WriteEnable;
            imm <= {16'h0,inst[15:0]};
            instvaild <= `InstVaild;
            end
            default:begin
            end
        endcase
    end
end

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
