library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg_file is
    Port (
        clk        : in  std_logic;
        rs1_addr   : in  std_logic_vector(4 downto 0);
        rs2_addr   : in  std_logic_vector(4 downto 0);
        rd_addr    : in  std_logic_vector(4 downto 0);
        rd_data    : in  std_logic_vector(31 downto 0);
        reg_write  : in  std_logic;
        rs1_data   : out std_logic_vector(31 downto 0);
        rs2_data   : out std_logic_vector(31 downto 0)
    );
end reg_file;

architecture Behavioral of reg_file is
    type reg_array_t is array(0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array_t := (others => (others => '0'));
begin

    -- Asynchronous read
    rs1_data <= regs(to_integer(unsigned(rs1_addr)));
    rs2_data <= regs(to_integer(unsigned(rs2_addr)));

    -- Synchronous write
    process(clk)
    begin
        if rising_edge(clk) then
            if reg_write = '1' and rd_addr /= "00000" then
                regs(to_integer(unsigned(rd_addr))) <= rd_data;
            end if;
        end if;
    end process;

end Behavioral;

