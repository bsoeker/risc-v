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
    2 => x"0F800513",
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
    21 => x"060000EF",
    22 => x"0000006F",
    23 => x"FD010113",
    24 => x"02112623",
    25 => x"02812423",
    26 => x"03010413",
    27 => x"FCA42E23",
    28 => x"300007B7",
    29 => x"FDC42703",
    30 => x"00E7A023",
    31 => x"FE042623",
    32 => x"0100006F",
    33 => x"FEC42783",
    34 => x"00178793",
    35 => x"FEF42623",
    36 => x"FEC42703",
    37 => x"3E700793",
    38 => x"FEE7D6E3",
    39 => x"00000013",
    40 => x"00000013",
    41 => x"02C12083",
    42 => x"02812403",
    43 => x"03010113",
    44 => x"00008067",
    45 => x"FE010113",
    46 => x"00112E23",
    47 => x"00812C23",
    48 => x"02010413",
    49 => x"FE042623",
    50 => x"0100006F",
    51 => x"FEC42783",
    52 => x"00178793",
    53 => x"FEF42623",
    54 => x"FEC42703",
    55 => x"017D87B7",
    56 => x"83F78793",
    57 => x"FEE7D4E3",
    58 => x"003907B7",
    59 => x"00178513",
    60 => x"F6DFF0EF",
    61 => x"0000006F",
    others => x"00000000"
);

begin
    instr_word_addr <= to_integer(shift_right(unsigned(instr_addr), 2));
    data_word_addr <= to_integer(shift_right(unsigned(data_addr), 2));

    instr_data <= rom_array(instr_word_addr);
    data_data  <= rom_array(data_word_addr);

end rom_arch;

