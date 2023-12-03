//testbench
`timescale 1ns/1ps

module openmips_min_sopc_tb;

reg CLK_50M;
reg rst;

//osc initial
initial begin
    CLK_50M = 1'b0;
    forever begin
        #10 CLK_50M = ~CLK_50M;//T = 20ns f = 50M
    end
end
// reset initial
initial begin
    rst = 1'b1;
    #200 rst = 1'b0;
    #2000 rst = 1'b1;
    #1000 $stop;
end

openmips_min_sopc openmips_min_sopc0(
    .clk(CLK_50M),
    .rst(rst)
);

endmodule
