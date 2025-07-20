library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity store_unit is
    port (
        funct3      : in  std_logic_vector(2 downto 0); -- from instruction
        addr_offset : in  std_logic_vector(1 downto 0); -- addr(1 downto 0)
        store_data  : in  std_logic_vector(31 downto 0); -- value to store

        write_mask  : out std_logic_vector(3 downto 0); -- byte enables
        write_data  : out std_logic_vector(31 downto 0) -- aligned data
    );
end entity;

architecture Behavioral of store_unit is
begin
    process(funct3, addr_offset, store_data)
    begin
        -- Default
        write_data <= (others => '0');
        write_mask <= "0000";

        case funct3 is
            when "000" => -- SB
                case addr_offset is
                    when "00" =>
                        write_data <= x"000000" & store_data(7 downto 0);
                        write_mask <= "0001";
                    when "01" =>
                        write_data <= x"0000" & store_data(7 downto 0) & x"00";
                        write_mask <= "0010";
                    when "10" =>
                        write_data <= x"00" & store_data(7 downto 0) & x"0000";
                        write_mask <= "0100";
                    when "11" =>
                        write_data <= store_data(7 downto 0) & x"000000";
                        write_mask <= "1000";
                    when others =>
                        write_data <= (others => '0');
                        write_mask <= "0000";
                end case;

            when "001" => -- SH
                case addr_offset(1) is
                    when '0' => -- aligned to offset 0
                        write_data <= x"0000" & store_data(15 downto 0);
                        write_mask <= "0011";
                    when '1' => -- aligned to offset 2
                        write_data <= store_data(15 downto 0) & x"0000";
                        write_mask <= "1100";
                    when others =>
                        write_data <= (others => '0');
                        write_mask <= "0000";
                end case;

            when "010" => -- SW
                write_data <= store_data;
                write_mask <= "1111";

            when others =>
                write_data <= (others => '0');
                write_mask <= "0000";
        end case;
    end process;
end Behavioral;

