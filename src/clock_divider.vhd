library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    generic (
        DIVIDE_BY : natural := 4  -- Divide input clock by this much × 2
    );
    Port (
        clk_in  : in  std_logic;
        reset   : in  std_logic;
        clk_out : out std_logic
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal counter : unsigned(31 downto 0) := (others => '0');
    signal clk_buf : std_logic := '0';
begin

    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset = '1' then
                counter <= (others => '0');
                clk_buf <= '0';
            elsif counter = DIVIDE_BY - 1 then
                clk_buf <= not clk_buf;
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_out <= clk_buf;

end Behavioral;

