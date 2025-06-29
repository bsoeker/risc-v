library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_reg_file is
end tb_reg_file;

architecture Behavioral of tb_reg_file is

    -- DUT signals
    signal clk        : std_logic := '0';
    signal rs1_addr   : std_logic_vector(4 downto 0);
    signal rs2_addr   : std_logic_vector(4 downto 0);
    signal rd_addr    : std_logic_vector(4 downto 0);
    signal rd_data    : std_logic_vector(31 downto 0);
    signal reg_write  : std_logic;
    signal rs1_data   : std_logic_vector(31 downto 0);
    signal rs2_data   : std_logic_vector(31 downto 0);

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin

    -- Clock process
    clk_process : process
    begin
        clk <= '1'; -- start high
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process;


    -- Instantiate DUT
    UUT: entity work.reg_file
        port map (
            clk       => clk,
            rs1_addr  => rs1_addr,
            rs2_addr  => rs2_addr,
            rd_addr   => rd_addr,
            rd_data   => rd_data,
            reg_write => reg_write,
            rs1_data  => rs1_data,
            rs2_data  => rs2_data
        );

    -- Test sequence
    stim_proc: process
    begin
        -- Initial values
        reg_write <= '0';
        rs1_addr <= (others => '0');
        rs2_addr <= (others => '0');
        rd_addr  <= (others => '0');
        rd_data  <= (others => '0');
        wait for clk_period;

        -- Write 0x12345678 to register x5
        rd_addr   <= "00101"; -- x5
        rd_data   <= x"12345678";
        reg_write <= '1';
        wait for clk_period;

        -- Disable writing
        reg_write <= '0';

        -- Read back from x5
        rs1_addr <= "00101";
        rs2_addr <= "00101";
        wait for clk_period;

        -- Try to write to x0 (should be ignored)
        rd_addr   <= "00000";
        rd_data   <= x"DEADBEEF";
        reg_write <= '1';
        wait for clk_period;

        -- Read back x0 (should still be zero)
        rs1_addr <= "00000";
        wait for clk_period;

        wait;
    end process;

end Behavioral;

