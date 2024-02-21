library verilog;
use verilog.vl_types.all;
entity ex is
    port(
        rst             : in     vl_logic;
        aluop           : in     vl_logic_vector(7 downto 0);
        alusel          : in     vl_logic_vector(2 downto 0);
        reg1            : in     vl_logic_vector(31 downto 0);
        reg2            : in     vl_logic_vector(31 downto 0);
        wd_i            : in     vl_logic_vector(4 downto 0);
        wreg_i          : in     vl_logic;
        hi_i            : in     vl_logic_vector(31 downto 0);
        lo_i            : in     vl_logic_vector(31 downto 0);
        wb_hi_i         : in     vl_logic_vector(31 downto 0);
        wb_lo_i         : in     vl_logic_vector(31 downto 0);
        wb_whilo_i      : in     vl_logic;
        mem_hi_i        : in     vl_logic_vector(31 downto 0);
        mem_lo_i        : in     vl_logic_vector(31 downto 0);
        mem_whilo_i     : in     vl_logic;
        wdata           : out    vl_logic_vector(31 downto 0);
        wd_o            : out    vl_logic_vector(4 downto 0);
        wreg_o          : out    vl_logic;
        hi_o            : out    vl_logic_vector(31 downto 0);
        lo_o            : out    vl_logic_vector(31 downto 0);
        whilo_o         : out    vl_logic
    );
end ex;
