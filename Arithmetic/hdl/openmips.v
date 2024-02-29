`include "defines.v"
//顶层模块
module openmips(
    input wire clk,
    input wire rst,
    input wire[`InstBus] rom_data_o,

    output wire rom_ce_o,
    output wire[`RegBus] rom_addr_i//输出到ROM的地址
);
    //定义变量
    //连接if_id与id之间的变量
    wire [`InstAddrBus] pc;
    wire [`InstAddrBus] id_pc_i;
    wire [`InstBus] id_inst_i;

    //连接id与id_ex之间的变量
    wire [`AluOpBus] id_aluop_o;
    wire [`AluSelBus] id_alusel_o;
    wire [`RegBus] id_reg1_data_o;
    wire [`RegBus] id_reg2_data_o;
    wire [`RegAddrBus] id_wd_o;
    wire id_wreg_o;

    //连接id_Ex与ex之间的变量
    wire [`AluOpBus] ex_aluop_i;
    wire [`AluSelBus] ex_alusel_i;
    wire [`RegBus] ex_reg1_i;
    wire [`RegBus] ex_reg2_i;
    wire [`RegAddrBus] ex_wd_i;
    wire ex_wreg_i;

    //连接ex与ex_mem之间的变量
    wire [`RegBus] ex_wdata_o;
    wire [`RegAddrBus] ex_wd_o;
    wire ex_wreg_o;
    wire [`RegBus] ex_hi_o;
    wire [`RegBus] ex_lo_o;
    wire ex_whilo_o;

    //连接ex与hilo之间的变量
    wire [`RegBus] hilo_hi_o;
    wire [`RegBus] hilo_lo_o;

    //连接ex_mem与mem之间的变量
    wire [`RegBus] mem_wdata_i;
    wire [`RegAddrBus] mem_wd_i;
    wire mem_wreg_i;
    wire [`RegBus] mem_hi_i;
    wire [`RegBus] mem_lo_i;
    wire mem_whilo_i;

    //连接mem与mem_wb之间的变量
    wire [`RegBus] mem_wdata_o;
    wire [`RegAddrBus] mem_wd_o;
    wire mem_wreg_o;

    wire [`RegBus] mem_hi_o;
    wire [`RegBus] mem_lo_o;
    wire mem_whilo_o;

    //连接mem_wb与会回写阶段输入的变量,实际上便是连接mem_wb与regfile
    wire [`RegBus] wb_wdata_i;
    wire [`RegAddrBus] wb_wd_i;
    wire wb_wreg_i;

    //连接id与regfile之间的变量
    wire [`RegAddrBus] id_reg1_addr_o;
    wire [`RegAddrBus] id_reg2_addr_o;
    wire id_reg1_read_o;
    wire id_reg2_read_o;
    wire [`RegBus] id_reg1_data_i;
    wire [`RegBus] id_reg2_data_i;

    //连接mem_wb与hilo之间的变量
    wire [`RegBus] hilo_hi_i;
    wire [`RegBus] hilo_lo_i;
    wire hilo_we_i;

    //连接ctrl与各模块之间的变量
    wire [5:0] stall;
    wire stallreq_from_ex;
    wire stallreq_from_id;

    //连接EX与MEM模块，用于多周期的MADD、MADDU、MSUB、MSUBU等指令
    wire[`DoubleRegBus] hilo_temp_o;
    wire[1:0] cnt_o;

    wire[`DoubleRegBus] hilo_temp_i;
    wire[1:0] cnt_i;


    //模块实例化
    pc_reg pc_reg0(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .ce(rom_ce_o),
        .stall(stall)
    );
    //pc值即为送入rom的地址
    assign rom_addr_i = pc;
    //if_id实例化
    if_id if_id0(
        .clk(clk),
        .rst(rst),
        .if_pc(pc),
        .if_inst(rom_data_o),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
        .stall(stall)
    );
    //id实例化,注意其既与id_ex相连，也有从regfile中取数的数据通路
    id id0(
        .rst(rst),
        .pc(id_pc_i),
        .inst(id_inst_i),
        .reg1_data_i(id_reg1_data_i),
        .reg2_data_i(id_reg2_data_i),
        //扩展接口的连接
        .ex_wreg_i(ex_wreg_o),
        .ex_wd_i(ex_wd_o),
        .ex_wdata_i(ex_wdata_o),
        .mem_wreg_i(mem_wreg_o),
        .mem_wd_i(mem_wd_o),
        .mem_wdata_i(mem_wdata_o),
        
        .reg1_read_o(id_reg1_read_o),
        .reg2_read_o(id_reg2_read_o),
        .reg1_addr_o(id_reg1_addr_o),
        .reg2_addr_o(id_reg2_addr_o),
        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_data_o(id_reg1_data_o),
        .reg2_data_o(id_reg2_data_o),
        .wd_o(id_wd_o),
        .wreg_o(id_wreg_o)

        .stallreq(stallreq_from_id)
    );

    Regfile Regfile0(
        .clk(clk),
        .rst(rst),
        .we(wb_wreg_i),
        .wAddr(wb_wd_i),
        .wData(wb_wdata_i),
        .re1(id_reg1_read_o),
        .rAddr1(id_reg1_addr_o),
        .rData1(id_reg1_data_i),
        .re2(id_reg2_read_o),
        .rAddr2(id_reg2_addr_o),
        .rData2(id_reg2_data_i)
    );
    //id_ex实例化
    id_ex id_ex0(
        .clk(clk),
        .rst(rst),
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_data_o),
        .id_reg2(id_reg2_data_o),
        .id_wd(id_wd_o),
        .id_wreg(id_wreg_o),
        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_wreg(ex_wreg_i),
        .stall(stall)
    );
    //ex实例化
    ex ex0(
        .rst(rst),
        .aluop(ex_aluop_i),
        .alusel(ex_alusel_i),
        .reg1(ex_reg1_i),
        .reg2(ex_reg2_i),
        .wd_i(ex_wd_i),
        .wreg_i(ex_wreg_i),

        .hi_i(hilo_hi_o),
        .lo_i(hilo_lo_o),

        .wb_hi_i(hilo_hi_i),
        .wb_lo_i(hilo_lo_i),
        .wb_whilo_i(hilo_we_i),
        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),
        .mem_whilo_i(mem_whilo_o),

        .hilo_temp_i(hilo_temp_i),
        .cnt_i(cnt_i),

        .wdata(ex_wdata_o),
        .wd_o(ex_wd_o),
        .wreg_o(ex_wreg_o),

        .hi_o(ex_hi_o),
        .lo_o(ex_lo_o),
        .whilo_o(ex_whilo_o),

        .hilo_temp_o(hilo_temp_o),
        .cnt_o(cnt_o),

        .stallreq(stallreq_from_ex)
    );
    //ex_mem实例化
    ex_mem ex_mem0(
        .clk(clk),
        .rst(rst),
        .ex_wd(ex_wd_o),
        .ex_wreg(ex_wreg_o),
        .ex_wdata(ex_wdata_o),

        .ex_hi(ex_hi_o),
        .ex_lo(ex_lo_o),
        .ex_whilo(ex_whilo_o),

        .hilo_temp_i(hilo_temp_o),
        .cnt_i(cnt_o),

        .mem_wd(mem_wd_i),
        .mem_wreg(mem_wreg_i),
        .mem_wdata(mem_wdata_i),

        .mem_hi(mem_hi_i),
        .mem_lo(mem_lo_i),
        .mem_whilo(mem_whilo_i),

        .hilo_temp_o(hilo_temp_i),
        .cnt_o(cnt_i),

        .stall(stall)
    );
    //mem实例化
    mem mem0(
        .rst(rst),
        .wd_i(mem_wd_i),
        .wdata_i(mem_wdata_i),
        .wreg_i(mem_wreg_i),
        .whilo_i(mem_whilo_i),
        .hi_i(mem_hi_i),
        .lo_i(mem_lo_i),
        .wd_o(mem_wd_o),
        .wdata_o(mem_wdata_o),
        .wreg_o(mem_wreg_o),
        .whilo_o(mem_whilo_o),
        .hi_o(mem_hi_o),
        .lo_o(mem_lo_o)
    );
    //mem_wb实例化
    mem_wb mem_wb0(
        .clk(clk),
        .rst(rst),
        .mem_wdata(mem_wdata_o),
        .mem_wd(mem_wd_o),
        .mem_wreg(mem_wreg_o),

        .mem_whilo(mem_whilo_o),
        .mem_hi(mem_hi_o),
        .mem_lo(mem_lo_o),

        .wb_wdata(wb_wdata_i),
        .wb_wd(wb_wd_i),
        .wb_wreg(wb_wreg_i),

        .wb_whilo(hilo_we_i),
        .wb_lo(hilo_lo_i),
        .wb_hi(hilo_hi_i),

        .stall(stall)
    );

    //hilo实例化
    hilo_reg hilo_reg0(
        .clk(clk),
        .rst(rst),
        .we(hilo_we_i),
        .hi_i(hilo_hi_i),
        .lo_i(hilo_lo_i),
        .hi_o(hilo_hi_o),
        .lo_o(hilo_lo_o)
    );

    //ctrl模块实例化
    ctrl ctrl0(
        .rst(rst),
        .stall(stall),
        .stallreq_from_ex(stallreq_from_ex),
        .stallreq_from_id(stallreq_from_id)
    );

endmodule