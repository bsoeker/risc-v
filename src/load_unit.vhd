library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity load_unit is
    Port (
        funct3       : in  std_logic_vector(2 downto 0);
        is_unsigned  : in  std_logic;
        byte_offset  : in  std_logic_vector(1 downto 0);
        mem_data     : in  std_logic_vector(31 downto 0);
        loaded_value : out std_logic_vector(31 downto 0)
    );
end load_unit;

architecture Behavioral of load_unit is
    signal byte_sel : integer range 0 to 3;
    signal halfword : std_logic_vector(15 downto 0);
    signal byte     : std_logic_vector(7 downto 0);
begin
    byte_sel <= to_integer(unsigned(byte_offset));

    process(all)
    begin
        case funct3 is
            when "000" => -- LB
                case byte_sel is
                    when 0 => byte <= mem_data(7 downto 0);
                    when 1 => byte <= mem_data(15 downto 8);
                    when 2 => byte <= mem_data(23 downto 16);
                    when 3 => byte <= mem_data(31 downto 24);
                    when others => byte <= (others => '0');
                end case;

                if is_unsigned = '1' then
                    loaded_value <= x"000000" & byte;
                else
                    loaded_value <= std_logic_vector(resize(signed(byte), 32));
                end if;

            when "001" => -- LH
                case byte_sel is
                    when 0 => halfword <= mem_data(15 downto 0);  -- offset 00
                    when 2 => halfword <= mem_data(31 downto 16); -- offset 10
                    when others => halfword <= (others => '0');
                end case;

                if is_unsigned = '1' then
                    loaded_value <= x"0000" & halfword;
                else
                    loaded_value <= std_logic_vector(resize(signed(halfword), 32));
                end if;

            when "010" => -- LW
                loaded_value <= mem_data;

            when others =>
                loaded_value <= (others => '0');
        end case;
    end process;
end Behavioral;

