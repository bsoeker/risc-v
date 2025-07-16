library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity load_unit is
    Port (
        read_mask     : in std_logic_vector(3 downto 0);
        is_unsigned   : in std_logic;
        mem_data      : in  std_logic_vector(31 downto 0);
        loaded_value  : out std_logic_vector(31 downto 0)
    );
end load_unit;

architecture Behavioural of load_unit is
begin
    process(read_mask, is_unsigned, mem_data)
    begin
        case read_mask is 
            when "0001" => -- LB or LBU
                if is_unsigned = '1' then
                    loaded_value <= x"000000" & mem_data(7 downto 0);
                else
                    loaded_value <= (31 downto 8 => mem_data(7)) & mem_data(7 downto 0);
                end if;

            when "0011" => -- LH or LHU
                if is_unsigned = '1' then
                    loaded_value <= x"0000" & mem_data(15 downto 0);
                else
                    loaded_value <= (31 downto 16 => mem_data(15)) & mem_data(15 downto 0);
                end if;

            when "1111" => -- LW
                loaded_value <= mem_data;

            when others =>
                loaded_value <= (others => '0');
        end case;
    end process;
end Behavioural;

