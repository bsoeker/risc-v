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
        -- ADDI x1, x0, 5
        0 => x"93", 1 => x"00", 2 => x"50", 3 => x"00",
        -- ADDI x2, x0, 3
        4 => x"13", 5 => x"01", 6 => x"30", 7 => x"00",
        -- ADD x3, x1, x2
        8 => x"B3", 9 => x"81", 10 => x"20", 11 => x"00",
        -- SUB x4, x1, x2
        12 => x"33", 13 => x"82", 14 => x"20", 15 => x"40",
        -- AND x5, x1, x2
        16 => x"B3", 17 => x"A2", 18 => x"20", 19 => x"00",
        -- OR x6, x1, x2
        20 => x"33", 21 => x"C3", 22 => x"20", 23 => x"00",
        -- XOR x7, x1, x2
        24 => x"B3", 25 => x"E3", 26 => x"20", 27 => x"00",
        -- SLT x8, x1, x2
        28 => x"33", 29 => x"A4", 30 => x"20", 31 => x"00",
        -- SLTU x9, x2, x1
        32 => x"B3", 33 => x"B4", 34 => x"11", 35 => x"00",
        -- SLL x10, x1, x2
        36 => x"33", 37 => x"91", 38 => x"20", 39 => x"00",
        -- SRL x11, x1, x2
        40 => x"B3", 41 => x"D5", 42 => x"20", 43 => x"00",
        -- SRA x12, x1, x2
        44 => x"33", 45 => x"D6", 46 => x"20", 47 => x"40",

        others => x"00"
    );

begin

    -- Assemble 32-bit instruction from 4 consecutive bytes (little-endian)
    data <= rom_array(to_integer(unsigned(addr) + 3)) &
            rom_array(to_integer(unsigned(addr) + 2)) &
            rom_array(to_integer(unsigned(addr) + 1)) &
            rom_array(to_integer(unsigned(addr)));

end rom_arch;

