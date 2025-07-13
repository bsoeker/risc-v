library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_wb is
    Port (
        sel : in  std_logic_vector(1 downto 0);
        a   : in  std_logic_vector(31 downto 0); -- ALU result
        b   : in  std_logic_vector(31 downto 0); -- Memory data
        c   : in  std_logic_vector(31 downto 0); -- PC + 4
        y   : out std_logic_vector(31 downto 0)
    );
end mux_wb;

architecture Behavioral of mux_wb is
begin
    process(sel, a, b, c)
    begin
        case sel is
            when "00" =>
                y <= a;
            when "01" =>
                y <= b;
            when "10" =>
                y <= c;
            when others =>
                y <= a;  -- fallback to ALU result
        end case;
    end process;
end Behavioral;

