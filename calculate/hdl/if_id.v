`include "defines.v"
 //ID到IF阶段的寄存器，只负责传递，ROM负责根据PC值实时读出值
module if_id(
    input wire clk,
    input wire rst,

    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus] if_inst,
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst
);

always@(posedge clk)begin
if(rst == `RstEnable)begin
    id_pc <= 32'b0;
    id_inst <= 32'b0;
end

else begin
    id_pc <= if_pc;
    id_inst <= if_inst;
end
end

 endmodule