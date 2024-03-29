library verilog;
use verilog.vl_types.all;
entity ex_mem is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        ex_wd           : in     vl_logic_vector(4 downto 0);
        ex_wreg         : in     vl_logic;
        ex_wdata        : in     vl_logic_vector(31 downto 0);
        ex_hi           : in     vl_logic_vector(31 downto 0);
        ex_lo           : in     vl_logic_vector(31 downto 0);
        ex_whilo        : in     vl_logic;
        mem_wd          : out    vl_logic_vector(4 downto 0);
        mem_wreg        : out    vl_logic;
        mem_wdata       : out    vl_logic_vector(31 downto 0);
        mem_whilo       : out    vl_logic;
        mem_hi          : out    vl_logic_vector(31 downto 0);
        mem_lo          : out    vl_logic_vector(31 downto 0)
    );
end ex_mem;
