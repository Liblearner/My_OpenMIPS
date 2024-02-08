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

//InstCode[31:26]
`define EXE_ORI         6'b001101   //ORI
`define EXE_ANDI        6'b001100   //ANDI
`define EXE_XORI        6'b001110   //XORI
`define EXE_LUI         6'b001111   //LUI
`define EXE_PREF        6'b110011   //预读缓存，对于OpenMIPS为空指令
`define SPECIAL         6'b000000   //包括了其他大部分逻辑运算、移动指令等

//InstCode[5:0]
`define AND             6'b100100   
`define OR              6'b100101   
`define XOR             6'b100110   
`define NOR             6'b100111   
`define SLL             6'b000000
`define SRL             6'b000010
`define SRA             6'b000011
`define SLLV            6'b000100
`define SRLV            6'b000110
`define SRAV            6'b000111
`define SYNC            6'b001111
`define MOVZ            6'b001010
`define MOVN            6'b001011
`define MFHI            6'b010000
`define MFLO            6'b010010
`define MTHI            6'b010001
`define MTLO            6'b010011


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
`define EXE_AND_OP      8'b00100100
`define EXE_XOR_OP      8'b00100110
`define EXE_NOR_OP      8'b00100111
`define EXE_ANDI_OP     8'b01011001
`define EXE_XORI_OP     8'b01011011
`define EXE_LUI_OP      8'b01011100   
`define EXE_SLL_OP      8'b01111100
`define EXE_SLLV_OP     8'b00000100
`define EXE_SRL_OP      8'b00000010
`define EXE_SRLV_OP     8'b00000110
`define EXE_SRA_OP      8'b00000011
`define EXE_SRAV_OP     8'b00000111
`define EXE_MOVZ_OP     8'b00001010
`define EXE_MOVN_OP     8'b00001011
`define EXE_MFHI_OP     8'b00010000
`define EXE_MTHI_OP     8'b00010001
`define EXE_MFLO_OP     8'b00010010
`define EXE_MTLO_OP     8'b00010011
`define EXE_NOP_OP      8'b00000000  //空操作操作码


`define EXE_RES_LOGIC   3'b001    //ALU各选择码
`define EXE_RES_MOVE    3'b011	
`define EXE_RES_NOP     3'b000 
`define EXE_RES_SHIFT   3'b010

//ROM相关
`define InstMemNumLog2 17       //ROM按字寻址地址线数
`define InstMemNum 131072       //ROM中字个数=2^(17)

