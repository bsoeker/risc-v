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
    2 => x"0E400513",
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
    40 => x"FE042623",
    41 => x"0100006F",
    42 => x"FEC42783",
    43 => x"00178793",
    44 => x"FEF42623",
    45 => x"FEC42703",
    46 => x"002627B7",
    47 => x"59F78793",
    48 => x"FEE7D4E3",
    49 => x"00390537",
    50 => x"F95FF0EF",
    51 => x"00000793",
    52 => x"00078513",
    53 => x"01C12083",
    54 => x"01812403",
    55 => x"02010113",
    56 => x"00008067",
    others => x"00000000"
);

begin
    instr_word_addr <= to_integer(shift_right(unsigned(instr_addr), 2));
    data_word_addr <= to_integer(shift_right(unsigned(data_addr), 2));

    instr_data <= rom_array(instr_word_addr);
    data_data  <= rom_array(data_word_addr);

end rom_arch;

