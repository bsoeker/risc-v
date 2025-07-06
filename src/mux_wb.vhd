library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_wb is
    Port (
        sel : in  std_logic;
        a   : in  std_logic_vector(31 downto 0); -- ALU result
        b   : in  std_logic_vector(31 downto 0); -- RAM data
        y   : out std_logic_vector(31 downto 0)
    );
end mux_wb;

architecture Behavioral of mux_wb is
begin
    y <= b when sel = '1' else a;
end Behavioral;

