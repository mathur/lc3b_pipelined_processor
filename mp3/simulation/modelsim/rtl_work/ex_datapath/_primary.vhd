library verilog;
use verilog.vl_types.all;
library work;
entity ex_datapath is
    port(
        clk             : in     vl_logic;
        ex_src1_data_in : in     vl_logic_vector(15 downto 0);
        ex_src2_data_in : in     vl_logic_vector(15 downto 0);
        ex_instruction_in: in     vl_logic_vector(15 downto 0);
        ex_pc_in        : in     vl_logic_vector(15 downto 0);
        ex_ctrl_in      : in     work.lc3b_types.lc3b_control_word;
        ex_alu_out      : out    vl_logic_vector(15 downto 0);
        ex_br_out       : out    vl_logic_vector(15 downto 0)
    );
end ex_datapath;