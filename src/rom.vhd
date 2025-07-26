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
    2 => x"10400513",
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
    21 => x"03C000EF",
    22 => x"0000006F",
    23 => x"FE010113",
    24 => x"00112E23",
    25 => x"00812C23",
    26 => x"02010413",
    27 => x"FEA42623",
    28 => x"300007B7",
    29 => x"FEC42703",
    30 => x"00E7A023",
    31 => x"00000013",
    32 => x"01C12083",
    33 => x"01812403",
    34 => x"02010113",
    35 => x"00008067",
    36 => x"FE010113",
    37 => x"00112E23",
    38 => x"00812C23",
    39 => x"02010413",
    40 => x"00390537",
    41 => x"FB9FF0EF",
    42 => x"FE042623",
    43 => x"0100006F",
    44 => x"FEC42783",
    45 => x"00178793",
    46 => x"FEF42623",
    47 => x"FEC42703",
    48 => x"017D87B7",
    49 => x"83F78793",
    50 => x"FEE7D4E3",
    51 => x"300007B7",
    52 => x"00478793",
    53 => x"0007A783",
    54 => x"FEF42423",
    55 => x"200007B7",
    56 => x"FE842703",
    57 => x"04170713",
    58 => x"00E7A023",
    59 => x"00000793",
    60 => x"00078513",
    61 => x"01C12083",
    62 => x"01812403",
    63 => x"02010113",
    64 => x"00008067",
    others => x"00000000"
);

begin
    instr_word_addr <= to_integer(shift_right(unsigned(instr_addr), 2));
    data_word_addr <= to_integer(shift_right(unsigned(data_addr), 2));

    instr_data <= rom_array(instr_word_addr);
    data_data  <= rom_array(data_word_addr);

end rom_arch;

