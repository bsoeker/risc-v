library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    Port (
        clk        : in  std_logic;              -- System clock
        reset      : in  std_logic;
        start      : in  std_logic;              -- One-cycle pulse
        tx_data    : in  std_logic_vector(31 downto 0); -- 32-bit data to send
        done       : out std_logic;              -- High when transaction is done
        rx_data    : out std_logic_vector(31 downto 0); -- Received data

        -- SPI signals
        sclk       : out std_logic;
        mosi       : out std_logic;
        miso       : in  std_logic;
        cs         : out std_logic               -- Active-low
    );
end spi_master;

architecture Behavioral of spi_master is

    type state_type is (IDLE, LOAD, TRANSFER, DONE_STATE);
    signal state      : state_type := IDLE;

    signal shift_tx   : std_logic_vector(31 downto 0) := (others => '0');
    signal shift_rx   : std_logic_vector(31 downto 0) := (others => '0');
    signal bit_cnt    : integer range 0 to 31 := 0;

    signal clk_count  : integer := 0;
    constant CLK_DIV  : integer := 25000000; -- Adjust this for SCLK frequency
    signal sclk_int   : std_logic := '0';
    signal sclk_rise  : std_logic := '0';
    signal sclk_fall  : std_logic := '0';

    signal tx_latch   : std_logic_vector(31 downto 0) := (others => '0');

begin

    -- External outputs
    mosi <= shift_tx(31); -- MSB first
    sclk <= sclk_int when state = TRANSFER else '0';
    cs   <= '0' when state = LOAD or state = TRANSFER else '1';
    rx_data <= shift_rx;

    -- Clock divider: generate SPI clock with rise/fall detection
    process(clk)
    begin
        if rising_edge(clk) then
            sclk_rise <= '0';
            sclk_fall <= '0';

            if state = TRANSFER then
                if clk_count = CLK_DIV - 1 then
                    clk_count   <= clk_count + 1;
                    sclk_int  <= '0';
                    sclk_fall <= '1';
                elsif clk_count = CLK_DIV * 2 - 1 then
                    clk_count   <= 0;
                    sclk_int  <= '1';
                    sclk_rise <= '1';
                else
                    clk_count <= clk_count + 1;
                end if;
            else
                clk_count <= 0;
                sclk_int  <= '0';
            end if;
        end if;
    end process;

    -- FSM: handles shifting, sampling, and transaction
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state      <= IDLE;
                bit_cnt    <= 0;
                shift_tx   <= (others => '0');
                shift_rx   <= (others => '0');
                tx_latch   <= (others => '0');
                done       <= '0';
            else
                case state is
                    when IDLE =>
                        done <= '0';
                        if start = '1' then
                            tx_latch <= tx_data;
                            state <= LOAD;
                        end if;

                    when LOAD =>
                        shift_tx <= tx_latch;
                        shift_rx <= (others => '0');
                        bit_cnt  <= 0;
                        state    <= TRANSFER;

                    when TRANSFER =>
                        if sclk_fall = '1' then
                            -- Shift out MOSI
                            shift_tx <= shift_tx(30 downto 0) & '0';
                        elsif sclk_rise = '1' then
                            -- Sample MISO
                            shift_rx <= shift_rx(30 downto 0) & miso;

                            if bit_cnt = 31 then
                                state <= DONE_STATE;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                        end if;

                    when DONE_STATE =>
                        done <= '1';
                        if start = '0' then
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

end Behavioral;

