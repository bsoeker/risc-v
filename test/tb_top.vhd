library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end tb_top;

architecture Behavioral of tb_top is

    -- Signals for the ports we actually want to drive/observe
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal uart_tx : std_logic;

    -- Clock period: 100 MHz -> 10 ns period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the top module 
    uut: entity work.top
        port map (
            clk   => clk,
            reset => reset,
            RsTx  => uart_tx,      -- connected to a TB signal
            -- Unused outputs:
            sclk        => open,
            scs         => open,
            mosi        => open,
            reset_slave => open,
            -- Unused input:
            miso        => '0',
            led => open
        );

    -- Clock generation
    clk_process : process
    begin
        while now < 10 us loop
            clk <= '0';
            wait for clk_period / 2;  -- 20 ns low
            clk <= '1';
            wait for clk_period / 2;  -- 20 ns high
        end loop;
        wait;
    end process;

    -- Reset sequence
    stim_proc: process
    begin
        wait for 100 ns;   -- hold reset a bit
        reset <= '0';      -- release reset
        wait;
    end process;

end Behavioral;

