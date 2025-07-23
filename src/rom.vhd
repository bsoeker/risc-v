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
    2 => x"10C00513",
    3 => x"10000597",
    4 => x"FF458593",
    5 => x"10000617",
    6 => x"FF960613",
    7 => x"00C58C63",
    8 => x"00054283",
    9 => x"00558023",
    10 => x"00150513",
    11 => x"00158593",
    12 => x"FEDFF06F",
    13 => x"10000517",
    14 => x"FD950513",
    15 => x"10000597",
    16 => x"FD158593",
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
    27 => x"FE042623",
    28 => x"0100006F",
    29 => x"FEC42783",
    30 => x"00178793",
    31 => x"FEF42623",
    32 => x"FEC42703",
    33 => x"3E700793",
    34 => x"FEE7D6E3",
    35 => x"00000013",
    36 => x"00000013",
    37 => x"01C12083",
    38 => x"01812403",
    39 => x"02010113",
    40 => x"00008067",
    41 => x"FE010113",
    42 => x"00112E23",
    43 => x"00812C23",
    44 => x"02010413",
    45 => x"FE042623",
    46 => x"0300006F",
    47 => x"FA1FF0EF",
    48 => x"100007B7",
    49 => x"00078713",
    50 => x"FEC42783",
    51 => x"00F707B3",
    52 => x"0007C703",
    53 => x"200007B7",
    54 => x"00E7A023",
    55 => x"FEC42783",
    56 => x"00178793",
    57 => x"FEF42623",
    58 => x"FEC42703",
    59 => x"00C00793",
    60 => x"FCE7F6E3",
    61 => x"00000793",
    62 => x"00078513",
    63 => x"01C12083",
    64 => x"01812403",
    65 => x"02010113",
    66 => x"00008067",
    67 => x"6C6C6548",
    68 => x"6F57206F",
    69 => x"21646C72",
    70 => x"00000000",
    others => x"00000000"
    );

begin
    instr_word_addr <= to_integer(shift_right(unsigned(instr_addr), 2));
    data_word_addr <= to_integer(shift_right(unsigned(data_addr), 2));

    instr_data <= rom_array(instr_word_addr);
    data_data  <= rom_array(data_word_addr);

end rom_arch;

