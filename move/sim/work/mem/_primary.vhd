library verilog;
use verilog.vl_types.all;
entity mem is
    port(
        rst             : in     vl_logic;
        wd_i            : in     vl_logic_vector(4 downto 0);
        wdata_i         : in     vl_logic_vector(31 downto 0);
        wreg_i          : in     vl_logic;
        whilo_i         : in     vl_logic;
        hi_i            : in     vl_logic_vector(31 downto 0);
        lo_i            : in     vl_logic_vector(31 downto 0);
        wd_o            : out    vl_logic_vector(4 downto 0);
        wdata_o         : out    vl_logic_vector(31 downto 0);
        wreg_o          : out    vl_logic;
        whilo_o         : out    vl_logic;
        hi_o            : out    vl_logic_vector(31 downto 0);
        lo_o            : out    vl_logic_vector(31 downto 0)
    );
end mem;
