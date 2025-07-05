library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    generic (
        addr_width  : integer := 10;  -- 2^10 = 1024 words
        data_width  : integer := 32 
    );
    port (
        addr : in  std_logic_vector(addr_width - 1 downto 0); -- Byte address (PC)
        data : out std_logic_vector(data_width - 1 downto 0)            -- Full 32-bit instruction
    );
end rom;

architecture rom_arch of rom is

    -- Byte-addressable ROM: Each address holds 1 byte
    type rom_type is array (0 to 2**addr_width - 1) of std_logic_vector(7 downto 0);
    signal rom_array : rom_type := (
        -- Example:
        0  => x"67",  -- byte 0 of instr 0
        1  => x"45",
        2  => x"23",
        3  => x"01",  -- byte 3 of instr 0 (MSB)
        4  => x"93",  -- byte 0 of instr 1
        5  => x"00",
        6  => x"00",
        7  => x"00",
        others => x"00"
    );

begin

    -- Assemble 32-bit instruction from 4 consecutive bytes (little-endian)
    data <= rom_array(to_integer(unsigned(addr)))     &
            rom_array(to_integer(unsigned(addr + 1))) &
            rom_array(to_integer(unsigned(addr + 2))) &
            rom_array(to_integer(unsigned(addr + 3)));

end rom_arch;

