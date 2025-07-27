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
    2 => x"14800513",
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
    21 => x"050000EF",
    22 => x"0000006F",
    23 => x"FE010113",
    24 => x"00112E23",
    25 => x"00812C23",
    26 => x"02010413",
    27 => x"FEA42623",
    28 => x"00000013",
    29 => x"300007B7",
    30 => x"00878793",
    31 => x"0007A783",
    32 => x"FE078AE3",
    33 => x"300007B7",
    34 => x"FEC42703",
    35 => x"00E7A023",
    36 => x"00000013",
    37 => x"01C12083",
    38 => x"01812403",
    39 => x"02010113",
    40 => x"00008067",
    41 => x"FE010113",
    42 => x"00112E23",
    43 => x"00812C23",
    44 => x"02010413",
    45 => x"FE042423",
    46 => x"0100006F",
    47 => x"FE842783",
    48 => x"00178793",
    49 => x"FEF42423",
    50 => x"FE842703",
    51 => x"002627B7",
    52 => x"59F78793",
    53 => x"FEE7D4E3",
    54 => x"000407B7",
    55 => x"40278513",
    56 => x"F7DFF0EF",
    57 => x"00040537",
    58 => x"F75FF0EF",
    59 => x"FE042223",
    60 => x"0100006F",
    61 => x"FE442783",
    62 => x"00178793",
    63 => x"FEF42223",
    64 => x"FE442703",
    65 => x"002627B7",
    66 => x"59F78793",
    67 => x"FEE7D4E3",
    68 => x"300007B7",
    69 => x"00478793",
    70 => x"0007A783",
    71 => x"FEF407A3",
    72 => x"FEF44783",
    73 => x"04178713",
    74 => x"200007B7",
    75 => x"00E7A023",
    76 => x"00000793",
    77 => x"00078513",
    78 => x"01C12083",
    79 => x"01812403",
    80 => x"02010113",
    81 => x"00008067",
    others => x"00000000"
);

begin
    instr_word_addr <= to_integer(shift_right(unsigned(instr_addr), 2));
    data_word_addr <= to_integer(shift_right(unsigned(data_addr), 2));

    instr_data <= rom_array(instr_word_addr);
    data_data  <= rom_array(data_word_addr);

end rom_arch;

