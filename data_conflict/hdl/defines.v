//Enablity
`define ChipEnable      1'b1        //ROM禁止
`define ChipDisable     1'b0
`define RstEnable       1'b1        //系统重置
`define RstDisable     1'b0

`define ReadEnable      1'b1       //读允许
`define ReadDisable     1'b0
`define WriteEnable     1'b1      //写允许
`define WriteDisable    1'b0

`define InstVaild       1'b1          //指令有效
`define InstInvaild     1'b0

//InstCode
`define EXE_ORI         6'b001101

//Regfiles
`define RegNum          32          //寄存器数量
`define RegNumLog2      5           //寄存器寻址地址位数
`define RegNopAddr      5'b0        //空操作寄存器地址
`define RegNopData      32'b0       //空操作寄存器数据    

//BusWide
`define InstAddrBus     31:0        //指令地址宽度
`define InstBus         31:0        //指令长度
`define RegAddrBus      4:0         //reg地址宽度
`define RegBus          31:0        //reg位数

//ALU相关
`define AluOpBus        7:0           //ALU操作码长度
`define AluSelBus       2:0           //ALU选择码长度

`define EXE_OR_OP       8'b00100101  //ALU各操作码
`define EXE_ORI_OP      8'b01011010
`define EXE_NOP_OP      8'b00000000  //空操作操作码
`define EXE_RES_LOGIC   3'b001    //ALU各选择码
`define EXE_RES_NOP     3'b000 

//ROM相关
`define InstMemNumLog2 17       //ROM按字寻址地址线数
`define InstMemNum 131072       //ROM中字个数=2^(17)