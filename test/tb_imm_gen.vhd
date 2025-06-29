library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_imm_gen is
end tb_imm_gen;

architecture Behavioral of tb_imm_gen is
    -- DUT
    component imm_gen
        Port (
            instr     : in  std_logic_vector(31 downto 0);
            imm_type  : in  std_logic_vector(2 downto 0);
            imm_out   : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals
    signal instr     : std_logic_vector(31 downto 0);
    signal imm_type  : std_logic_vector(2 downto 0);
    signal imm_out   : std_logic_vector(31 downto 0);
begin
    -- Instantiate DUT
    UUT: imm_gen
        port map (
            instr    => instr,
            imm_type => imm_type,
            imm_out  => imm_out
        );

    -- Test process
    process
    begin
        -- Test I-type: ADDI x1, x2, -5 → imm = 0xFFFFFFFB
        -- 1111 1111 1011 0001 0000 0001 0001 0011 => 1111 1111 1011
        instr <= x"FFB10113";  -- imm[11:0] = 0xFFB → -5
        imm_type <= "000";     -- I-type
        wait for 10 ns;

        -- Test S-type: SW x3, -12(x2) → imm = 0xFFFFFF44
        -- 1111 0100 0011 1010 0000 0010 0010 0011 => 1111 0100 0100
        instr <= x"F43A0223";  -- imm = 1111111 0100 (hi:31-25) & 00100 (low:11-7)
        imm_type <= "001";     -- S-type
        wait for 10 ns;

        -- Test SB-type: BEQ x1, x2, 8 → imm = 0x0000000C
        -- 0000 0000 0010 0000 1000 0110 0110 0011 => 0 0000 0000 1100 
        instr <= x"00208663";  -- imm = 0000000 010 (hi), 00110 (low)
        imm_type <= "010";     -- SB-type
        wait for 10 ns;

        -- Test U-type: LUI x1, 0x12345 → imm = 0x12345000
        instr <= x"12345037";
        imm_type <= "011";     -- U-type
        wait for 10 ns;

        -- Test UJ-type: JAL x1, -4 → imm = 0xFFFFFFF4
        -- 1111 1111 0101 1111 1111 0000 0110 1111 => 1 1111 1111 1111 1111 0100
        instr <= x"FF5FF06F";
        imm_type <= "100";     -- UJ-type
        wait for 10 ns;

        wait;
    end process;
end Behavioral;

