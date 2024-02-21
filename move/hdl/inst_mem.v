`include "defines.v"
module inst_mem(
    input wire ce,
    input wire[`InstAddrBus] addr,
    output reg[`InstBus] inst
);
//ͨ������Ĵ�����ķ�ʽ����ROM
reg[`InstBus] inst_mem[0:`InstMemNum-1];

//ʹ��rom.data��initial ROM����initial�����Ա��ۺ�
initial $readmemh ("inst_mem.data", inst_mem);

always @(*) begin
    if(ce == `ChipDisable)
        inst <= 32'b0;
    else begin
        inst <= inst_mem[addr[`InstMemNumLog2 + 1 : 2]];//����ַ����2λ���ֶ���
    end
end


endmodule