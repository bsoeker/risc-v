library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_a is
    Port (
        sel    : in  std_logic_vector(1 downto 0);  -- "00"=rs1, "01"=PC, "10"=zero
        rs1    : in  std_logic_vector(31 downto 0);
        pc     : in  std_logic_vector(31 downto 0);
        result : out std_logic_vector(31 downto 0)
    );
end mux_a;

architecture Behavioral of mux_a is
begin
    process(sel, rs1, pc)
    begin
        case sel is
            when "00" =>
                result <= rs1;
            when "01" =>
                result <= pc;
            when "10" =>
                result <= (others => '0');  -- zero
            when others =>
                result <= rs1;  -- default fallback
        end case;
    end process;
end Behavioral;

