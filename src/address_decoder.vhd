library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity address_decoder is
    Port (
        addr         : in  std_logic_vector(31 downto 0);  -- alu_result
        ram_en       : out std_logic;
        ram_addr     : out std_logic_vector(11 downto 0);  -- 4KB RAM
        uart_en      : out std_logic;
        uart_addr    : out std_logic_vector(1 downto 0);     -- select data/status
        rom_en       : out std_logic;
        rom_addr     : out std_logic_vector(11 downto 0)  -- 4KB RAM
    );
end address_decoder;

architecture Behavioral of address_decoder is
begin
    -- ROM: 0x00000000 - 0x00000FFF
    rom_en <= '1' when addr(31 downto 12) = x"00000" else '0';
    rom_addr <= addr(11 downto 0);

    -- RAM: 0x10000000 – 0x10000FFF
    ram_en   <= '1' when addr(31 downto 12) = x"10000" else '0';
    ram_addr <= addr(11 downto 0);  -- word-aligned inside RAM

    -- UART: 0x20000000 and 0x20000004 
    uart_en   <= '1' when addr(31 downto 12) = x"20000" else '0';
    uart_addr <= addr(3 downto 2);  -- extract UART register address (00 = data, 01 = status)

end Behavioral;

