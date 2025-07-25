library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    generic (
        addr_width  : integer := 10  -- 1024 words = 4KB
    );
    port (
        instr_addr : in  std_logic_vector(addr_width + 1 downto 0); -- Byte address (PC)
        instr_data : out std_logic_vector(31 downto 0);  -- Full 32-bit instruction
        data_addr  : in  std_logic_vector(addr_width + 1 downto 0); -- Byte address (ALU)
        data_data  : out std_logic_vector(31 downto 0)  -- Full 32-bit data
    );
end rom;

architecture rom_arch of rom is
    signal instr_word_addr : integer range 0 to 2**addr_width - 1;
    signal data_word_addr  : integer range 0 to 2**addr_width - 1;

    type rom_type is array (0 to 2**addr_width - 1) of std_logic_vector(31 downto 0);
    signal rom_array : rom_type := (
    0 => x"10001117",
    1 => x"00010113",
    2 => x"16C00513",
    3 => x"10000597",
    4 => x"FF458593",
    5 => x"10000617",
    6 => x"FEC60613",
    7 => x"00C58C63",
    8 => x"00054283",
    9 => x"00558023",
    10 => x"00150513",
    11 => x"00158593",
    12 => x"FEDFF06F",
    13 => x"10000517",
    14 => x"FCC50513",
    15 => x"10000597",
    16 => x"FC458593",
    17 => x"00B50863",
    18 => x"00052023",
    19 => x"00450513",
    20 => x"FF5FF06F",
    21 => x"0CC000EF",
    22 => x"0000006F",
    23 => x"FD010113",
    24 => x"02112623",
    25 => x"02812423",
    26 => x"03010413",
    27 => x"00050793",
    28 => x"FCF40FA3",
    29 => x"300007B7",
    30 => x"FDF44703",
    31 => x"00E7A023",
    32 => x"FE042623",
    33 => x"0100006F",
    34 => x"FEC42783",
    35 => x"00178793",
    36 => x"FEF42623",
    37 => x"FEC42703",
    38 => x"01300793",
    39 => x"FEE7D6E3",
    40 => x"00000013",
    41 => x"00000013",
    42 => x"02C12083",
    43 => x"02812403",
    44 => x"03010113",
    45 => x"00008067",
    46 => x"FD010113",
    47 => x"02112623",
    48 => x"02812423",
    49 => x"03010413",
    50 => x"00050793",
    51 => x"FCF40FA3",
    52 => x"300007B7",
    53 => x"FDF44703",
    54 => x"00E7A023",
    55 => x"FE042623",
    56 => x"0100006F",
    57 => x"FEC42783",
    58 => x"00178793",
    59 => x"FEF42623",
    60 => x"FEC42703",
    61 => x"01300793",
    62 => x"FEE7D6E3",
    63 => x"300007B7",
    64 => x"00478793",
    65 => x"0007A783",
    66 => x"0FF7F793",
    67 => x"00078513",
    68 => x"02C12083",
    69 => x"02812403",
    70 => x"03010113",
    71 => x"00008067",
    72 => x"FE010113",
    73 => x"00112E23",
    74 => x"00812C23",
    75 => x"02010413",
    76 => x"00000513",
    77 => x"F29FF0EF",
    78 => x"03900513",
    79 => x"F21FF0EF",
    80 => x"00000513",
    81 => x"F19FF0EF",
    82 => x"00000513",
    83 => x"F6DFF0EF",
    84 => x"00050793",
    85 => x"FEF407A3",
    86 => x"FEF44783",
    87 => x"04278713",
    88 => x"200007B7",
    89 => x"00E7A023",
    90 => x"0000006F",
    others => x"00000000"
);

begin
    instr_word_addr <= to_integer(shift_right(unsigned(instr_addr), 2));
    data_word_addr <= to_integer(shift_right(unsigned(data_addr), 2));

    instr_data <= rom_array(instr_word_addr);
    data_data  <= rom_array(data_word_addr);

end rom_arch;

