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
        data : out std_logic_vector(data_width - 1 downto 0)  -- Full 32-bit instruction
    );
end rom;

architecture rom_arch of rom is

    -- Byte-addressable ROM: Each address holds 1 byte
    type rom_type is array (0 to 2**addr_width - 1) of std_logic_vector(7 downto 0);
    signal rom_array : rom_type := (
        -- ADDI x1, x0, 5
        0 => x"93", 1 => x"00", 2 => x"50", 3 => x"00",
        -- SLTI x2, x0, 3
        4 => x"13", 5 => x"21", 6 => x"30", 7 => x"00",
        -- ADD x3, x1, x2
        8 => x"B3", 9 => x"81", 10 => x"20", 11 => x"00",
        -- SUB x4, x1, x2
        12 => x"33", 13 => x"82", 14 => x"20", 15 => x"40",
        -- AND x5, x1, x2
        16 => x"B3", 17 => x"F2", 18 => x"20", 19 => x"00",
        -- OR x6, x1, x2
        20 => x"33", 21 => x"E3", 22 => x"20", 23 => x"00",
        -- XOR x7, x1, x2
        24 => x"B3", 25 => x"C3", 26 => x"20", 27 => x"00",
        -- SLT x8, x1, x2
        28 => x"33", 29 => x"A4", 30 => x"20", 31 => x"00",
        -- SLTU x9, x2, x1
        32 => x"B3", 33 => x"B4", 34 => x"20", 35 => x"00",
        -- SLL x10, x1, x2
        36 => x"33", 37 => x"95", 38 => x"20", 39 => x"00",
        -- SRL x11, x1, x2
        40 => x"B3", 41 => x"D5", 42 => x"20", 43 => x"00",
        -- SRA x12, x1, x2
        44 => x"33", 45 => x"D6", 46 => x"20", 47 => x"40",
        -- SLTIU x13, x1, 6
        48 => x"93", 49 => x"B6", 50 => x"60", 51 => x"00",
        -- XORI x14, x1, 7
        52 => x"13", 53 => x"C7", 54 => x"70", 55 => x"00",
        -- ORI x15, x1, 2
        56 => x"93", 57 => x"E7", 58 => x"20", 59 => x"00",
        -- ANDI x1, x15, 5
        60 => x"93", 61 => x"F0", 62 => x"57", 63 => x"00",
        -- SLLI x1, x1, 1
        64 => x"93", 65 => x"90", 66 => x"10", 67 => x"00",
        -- SRLI x1, x1, 1 
        68 => x"93", 69 => x"D0", 70 => x"10", 71 => x"00",
        -- SRAI x1, x1, 1
        72 => x"93", 73 => x"D0", 74 => x"10", 75 => x"40",
        -- LUI x1, 01234
        76 => x"B7", 77 => x"40", 78 => x"23", 79 => x"01",
        -- AUIPC x1, 0000A
        80 => x"97", 81 => x"A0", 82 => x"00", 83 => x"00",
        -- JAL x1, 20
        84 => x"EF", 85 => x"00", 86 => x"40", 87 => x"01",
        -- JALR x0, x0,  16
        -- 104 => x"67", 105 => x"00", 106 => x"00", 107 => x"01",
        -- BEQ x20, x21, 16
        104 => x"63", 105 => x"08", 106 => x"5A", 107 => x"01",
        -- ADD x1, x1, x2
        120 => x"B3", 121 => x"80", 122 => x"20", 123 => x"00",
        -- BNE BEQ x0, x1, -4
        124 => x"E3", 125 => x"1E", 126 => x"10", 127 => x"FE",


        others => x"00"
    );

begin

    -- Assemble 32-bit instruction from 4 consecutive bytes (little-endian)
    data <= rom_array(to_integer(unsigned(addr) + 3)) &
            rom_array(to_integer(unsigned(addr) + 2)) &
            rom_array(to_integer(unsigned(addr) + 1)) &
            rom_array(to_integer(unsigned(addr)));

end rom_arch;

