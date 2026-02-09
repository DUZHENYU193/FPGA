library verilog;
use verilog.vl_types.all;
entity DDS is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        f_sel           : in     vl_logic_vector(2 downto 0);
        en              : in     vl_logic;
        dds_data        : out    vl_logic_vector(7 downto 0)
    );
end DDS;
