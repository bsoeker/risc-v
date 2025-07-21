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
        0 => x"17",
    1 => x"11",
    2 => x"00",
    3 => x"10",
    4 => x"13",
    5 => x"01",
    6 => x"01",
    7 => x"00",
    8 => x"EF",
    9 => x"00",
    10 => x"80",
    11 => x"00",
    12 => x"6F",
    13 => x"00",
    14 => x"00",
    15 => x"00",
    16 => x"13",
    17 => x"01",
    18 => x"01",
    19 => x"FF",
    20 => x"23",
    21 => x"26",
    22 => x"11",
    23 => x"00",
    24 => x"23",
    25 => x"24",
    26 => x"81",
    27 => x"00",
    28 => x"13",
    29 => x"04",
    30 => x"01",
    31 => x"01",
    32 => x"B7",
    33 => x"07",
    34 => x"00",
    35 => x"20",
    36 => x"13",
    37 => x"07",
    38 => x"80",
    39 => x"04",
    40 => x"23",
    41 => x"A0",
    42 => x"E7",
    43 => x"00",
    44 => x"93",
    45 => x"07",
    46 => x"10",
    47 => x"00",
    48 => x"13",
    49 => x"85",
    50 => x"07",
    51 => x"00",
    52 => x"83",
    53 => x"20",
    54 => x"C1",
    55 => x"00",
    56 => x"03",
    57 => x"24",
    58 => x"81",
    59 => x"00",
    60 => x"13",
    61 => x"01",
    62 => x"01",
    63 => x"01",
    64 => x"67",
    65 => x"80",
    66 => x"00",
    67 => x"00",


        others => x"00"
    );

begin

    -- Assemble 32-bit instruction from 4 consecutive bytes (little-endian)
    data <= rom_array(to_integer(unsigned(addr) + 3)) &
            rom_array(to_integer(unsigned(addr) + 2)) &
            rom_array(to_integer(unsigned(addr) + 1)) &
            rom_array(to_integer(unsigned(addr)));

end rom_arch;

