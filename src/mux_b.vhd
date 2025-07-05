library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_b is
    Port (
        sel     : in  std_logic;  -- 0 = rs2_data, 1 = imm_out
        rs2     : in  std_logic_vector(31 downto 0);
        imm     : in  std_logic_vector(31 downto 0);
        result  : out std_logic_vector(31 downto 0)
    );
end mux_b;

architecture Behavioral of mux_b is
begin
    result <= rs2 when sel = '0' else imm;
end Behavioral;

