library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_a is
    Port (
        sel     : in  std_logic;  -- 0 = rs1_data, 1 = PC
        rs1     : in  std_logic_vector(31 downto 0);
        pc      : in  std_logic_vector(31 downto 0);
        result  : out std_logic_vector(31 downto 0)
    );
end mux_a;

architecture Behavioral of mux_a is
begin
    result <= rs1 when sel = '0' else pc;
end Behavioral;

