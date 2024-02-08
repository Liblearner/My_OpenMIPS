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
        wdata           : out    vl_logic_vector(31 downto 0);
        wd_o            : out    vl_logic_vector(4 downto 0);
        wreg_o          : out    vl_logic
    );
end ex;
