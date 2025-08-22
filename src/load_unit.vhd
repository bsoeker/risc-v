library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity load_unit is
    Port (
        funct3       : in  std_logic_vector(2 downto 0);
        byte_offset  : in  std_logic_vector(1 downto 0);
        mem_data     : in  std_logic_vector(31 downto 0);
        loaded_value : out std_logic_vector(31 downto 0)
    );
end load_unit;

architecture Behavioral of load_unit is
    signal byte_sel  : integer range 0 to 3;
    signal byte_val  : std_logic_vector(7 downto 0);
    signal halfword  : std_logic_vector(15 downto 0);
begin
    byte_sel <= to_integer(unsigned(byte_offset));

    process(all)
    begin
        -- defaults to avoid latch inference
        byte_val <= (others => '0');
        halfword <= (others => '0');
        loaded_value <= (others => '0');

        case funct3 is
            -- LB (signed byte)
            when "000" =>
                case byte_sel is
                    when 0 => byte_val <= mem_data(7 downto 0);
                    when 1 => byte_val <= mem_data(15 downto 8);
                    when 2 => byte_val <= mem_data(23 downto 16);
                    when 3 => byte_val <= mem_data(31 downto 24);
                    when others => byte_val <= (others => '0');
                end case;
                loaded_value <= std_logic_vector(resize(signed(byte_val), 32));

            -- LH (signed halfword)
            when "001" =>
                case byte_sel is
                    when 0 => halfword <= mem_data(15 downto 0);
                    when 2 => halfword <= mem_data(31 downto 16);
                    when others => halfword <= (others => '0');
                end case;
                loaded_value <= std_logic_vector(resize(signed(halfword), 32));

            -- LW (full word)
            when "010" =>
                loaded_value <= mem_data;

            -- LBU (unsigned byte)
            when "100" =>
                case byte_sel is
                    when 0 => byte_val <= mem_data(7 downto 0);
                    when 1 => byte_val <= mem_data(15 downto 8);
                    when 2 => byte_val <= mem_data(23 downto 16);
                    when 3 => byte_val <= mem_data(31 downto 24);
                    when others => byte_val <= (others => '0');
                end case;
                loaded_value <= x"000000" & byte_val;

            -- LHU (unsigned halfword)
            when "101" =>
                case byte_sel is
                    when 0 => halfword <= mem_data(15 downto 0);
                    when 2 => halfword <= mem_data(31 downto 16);
                    when others => halfword <= (others => '0');
                end case;
                loaded_value <= x"0000" & halfword;

            -- default
            when others =>
                loaded_value <= (others => '0');
        end case;
    end process;
end Behavioral;

