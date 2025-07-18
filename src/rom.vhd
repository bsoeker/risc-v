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
        -- lui x1, 0x20000
        0 => x"B7", 1 => x"00", 2 => x"00", 3 => x"20",
        -- addi x1, x1, 4
        4 => x"93", 5 => x"80", 6 => x"40", 7 => x"00",
        -- lw x2, 0(x1)
        8 => x"03", 9 => x"A1", 10 => x"00", 11 => x"00",
        -- andi x2, x2, 1
        12 => x"13", 13 => x"71", 14 => x"11", 15 => x"00",
        -- beq x2, x0, -8
        16 => x"E3", 17 => x"0C", 18 => x"01", 19 => x"FE",
        -- lui x3, 0x20000
        20 => x"B7", 21 => x"01", 22 => x"00", 23 => x"20",
        -- addi x4, x0, 72
        24 => x"13", 25 => x"02", 26 => x"80", 27 => x"04",
        -- sw x4, 0(x3)
        28 => x"23", 29 => x"A0", 30 => x"41", 31 => x"00",

        others => x"00"
    );

begin

    -- Assemble 32-bit instruction from 4 consecutive bytes (little-endian)
    data <= rom_array(to_integer(unsigned(addr) + 3)) &
            rom_array(to_integer(unsigned(addr) + 2)) &
            rom_array(to_integer(unsigned(addr) + 1)) &
            rom_array(to_integer(unsigned(addr)));

end rom_arch;

