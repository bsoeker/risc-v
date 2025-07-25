library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end tb_top;

architecture Behavioral of tb_top is

    -- Component Under Test
    component top
        port (
            clk   : in std_logic;
            reset : in std_logic
        );
    end component;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    -- Clock period: 25 MHz -> 40 ns period
    constant clk_period : time := 2500 ps;

begin

    -- Instantiate the top module
    uut: top
        port map (
            clk   => clk,
            reset => reset
        );

    -- Clock generation
    clk_process : process
    begin
        while now < 10000 ns loop
            clk <= '0';
            wait for clk_period / 2;  -- 20 ns
            clk <= '1';
            wait for clk_period / 2;  -- 20 ns
        end loop;
        wait;
    end process;

    -- Reset sequence
    stim_proc: process
    begin
        wait for 20 ns;
        reset <= '0';  -- Deassert reset after half a clock cycle

        wait for 10000 ns;
        wait;
    end process;

end Behavioral;

