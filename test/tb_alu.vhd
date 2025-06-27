library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu is
end tb_alu;

architecture Behavioral of tb_alu is
    -- DUT (Device Under Test) component
    component alu
        Port (
            op_a        : in  std_logic_vector(31 downto 0);
            op_b        : in  std_logic_vector(31 downto 0);
            alu_control : in  std_logic_vector(3 downto 0);
            result      : out std_logic_vector(31 downto 0);
            zero        : out std_logic
        );
    end component;

    -- Test signals
    signal op_a        : std_logic_vector(31 downto 0);
    signal op_b        : std_logic_vector(31 downto 0);
    signal alu_control : std_logic_vector(3 downto 0);
    signal result      : std_logic_vector(31 downto 0);
    signal zero        : std_logic;

begin
    -- Instantiate the ALU
    UUT: alu port map (
        op_a => op_a,
        op_b => op_b,
        alu_control => alu_control,
        result => result,
        zero => zero
    );

    -- Test Process
    process
    begin
        -- Test ADD: 5 + 3 = 8
        op_a <= x"00000005";
        op_b <= x"00000003";
        alu_control <= "0000";  -- ADD
        wait for 10 ns;

        -- Test SUB: 10 - 15 = -5
        op_a <= x"0000000A";
        op_b <= x"0000000F";
        alu_control <= "0001";  -- SUB
        wait for 10 ns;

        -- Test AND: 0xF0F0 AND 0x0F0F = 0x00000000
        op_a <= x"0000F0F0";
        op_b <= x"00000F0F";
        alu_control <= "0010";  -- AND
        wait for 10 ns;

        -- Test OR: 0xF0F0 OR 0x0F0F = 0x0000FFFF
        op_a <= x"0000F0F0";
        op_b <= x"00000F0F";
        alu_control <= "0011";  -- OR
        wait for 10 ns;

        -- Test XOR: 0xAAAA XOR 0x5555 = 0xFFFF
        op_a <= x"0000AAAA";
        op_b <= x"00005555";
        alu_control <= "0100";  -- XOR
        wait for 10 ns;
        
        -- Test SLL: 1 << 4 = 16
        op_a <= x"00000001";
        op_b <= x"00000004";
        alu_control <= "0101";  -- SLL
        wait for 10 ns;

        -- Test SRL: 0x00000080 >> 2 = 0x00000020
        op_a <= x"00000080";
        op_b <= x"00000002";
        alu_control <= "0110";  -- SRL (logical)
        wait for 10 ns;

        -- Test SRA: 0xFFFFFFF8 (−8) >> 2 = 0xFFFFFFFE (−2) arithmetic shift
        op_a <= x"FFFFFFF8";  -- -8 in 2's comp
        op_b <= x"00000002";
        alu_control <= "0111";  -- SRA (arithmetic)
        wait for 10 ns;

        -- Test SLT: -3 < 2 → 1
        op_a <= std_logic_vector(to_signed(-3, 32));
        op_b <= std_logic_vector(to_signed(2, 32));
        alu_control <= "1000";  -- SLT
        wait for 10 ns;

        -- Done
        wait;
    end process;
end Behavioral;

