library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    generic (
        addr_width  : integer := 10;  -- 2^10 = 1KB
        data_width  : integer := 32 
    );
    port (
        addr : in  std_logic_vector(addr_width - 1 downto 0); -- Byte address (PC)
        data : out std_logic_vector(data_width - 1 downto 0)  -- Full 32-bit instruction
    );
end rom;

architecture rom_arch of rom is

    -- Byte-addressable ROM: Each address holds 1 byte
    type rom_type is array (0 to 2**addr_width - 1) of std_logic_vector(7 downto 0);
    signal rom_array : rom_type := (
        -- lui x1, 0x10000
        0 => x"b7", 1 => x"00", 2 => x"00", 3 => x"10",
        -- addi x2, x0, 8
        4 => x"13", 5 => x"01", 6 => x"80", 7 => x"00",
        -- sb x2, 3(x1)
        8 => x"a3", 9 => x"81", 10 => x"20", 11 => x"00",
        -- lw x3, 0(x1)
        -- 12 => x"83", 13 => x"a1", 14 => x"00", 15 => x"00",
        -- lh x4, 2(x1)
        12 => x"03", 13 => x"92", 14 => x"20", 15 => x"00",

        others => x"00"
    );

begin

    -- Assemble 32-bit instruction from 4 consecutive bytes (little-endian)
    data <= rom_array(to_integer(unsigned(addr) + 3)) &
            rom_array(to_integer(unsigned(addr) + 2)) &
            rom_array(to_integer(unsigned(addr) + 1)) &
            rom_array(to_integer(unsigned(addr)));

end rom_arch;

