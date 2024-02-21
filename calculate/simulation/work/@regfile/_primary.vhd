library verilog;
use verilog.vl_types.all;
entity Regfile is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        wAddr           : in     vl_logic_vector(4 downto 0);
        wData           : in     vl_logic_vector(31 downto 0);
        we              : in     vl_logic;
        re1             : in     vl_logic;
        rAddr1          : in     vl_logic_vector(4 downto 0);
        rData1          : out    vl_logic_vector(31 downto 0);
        re2             : in     vl_logic;
        rAddr2          : in     vl_logic_vector(4 downto 0);
        rData2          : out    vl_logic_vector(31 downto 0)
    );
end Regfile;
