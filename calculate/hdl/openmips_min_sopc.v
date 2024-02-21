`include "defines.v"
module openmips_min_sopc (
    input wire clk,
    input wire rst
);
    wire [`InstBus]  rom_data_o;
    wire [`InstAddrBus] rom_addr_o;
    wire rom_ce_o;
    openmips openmips0(
        .clk(clk),
        .rst(rst),
        .rom_data_o(rom_data_o),
        .rom_ce_o(rom_ce_o),
        .rom_addr_i(rom_addr_o)
    );
    inst_mem inst_mem0(
        .ce(rom_ce_o),
        .addr(rom_addr_o),
        .inst(rom_data_o)
    );

endmodule