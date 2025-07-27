library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    Port (
        clk        : in  std_logic;              -- System clock
        reset      : in  std_logic;
        start      : in  std_logic;              -- One-cycle pulse
        tx_data    : in  std_logic_vector(31 downto 0); -- 32-bit data to send
        ready      : out std_logic; 
        rx_data    : out std_logic_vector(7 downto 0); -- Received data

        -- SPI signals
        sclk       : out std_logic;
        mosi       : out std_logic;
        miso       : in  std_logic;
        cs         : out std_logic               -- Active-low
    );
end spi_master;

architecture Behavioral of spi_master is

    type state_type is (IDLE, ASSERT_CS, WAIT_CS, TRANSFER, DEASSERT_CS, DONE_STATE);
    signal state       : state_type := IDLE;

    signal shift_tx    : std_logic_vector(31 downto 0) := (others => '0');
    signal shift_rx    : std_logic_vector(31 downto 0) := (others => '0');
    signal bit_cnt     : integer range 0 to 31 := 0;
    signal clk_count   : integer := 0;

    constant CLK_DIV   : integer := 2;
    signal sclk_int    : std_logic := '0';
    signal cs_int      : std_logic := '1';
    signal tx_latch    : std_logic_vector(31 downto 0) := (others => '0');

begin

    -- Assign outputs
    sclk    <= sclk_int;
    cs      <= cs_int;
    mosi    <= shift_tx(31);
    rx_data <= shift_rx(7 downto 0);
    ready   <= '1' when state = IDLE else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state      <= IDLE;
                bit_cnt    <= 0;
                shift_tx   <= (others => '0');
                shift_rx   <= (others => '0');
                tx_latch   <= (others => '0');
                clk_count  <= 0;
                sclk_int   <= '0';
                cs_int     <= '1';

            else
            case state is

                when IDLE =>
                    cs_int    <= '1';
                    sclk_int  <= '0';
                    clk_count <= 0;
                    bit_cnt   <= 0;

                    if start = '1' then
                        tx_latch  <= tx_data;
                        state     <= ASSERT_CS;
                    end if;

                when ASSERT_CS =>
                    cs_int     <= '0';
                    shift_tx   <= tx_latch;
                    shift_rx   <= (others => '0');
                    clk_count  <= 0;
                    bit_cnt    <= 0;
                    state      <= WAIT_CS;

                when WAIT_CS =>
                    clk_count <= clk_count + 1;
                    if clk_count = (2 * CLK_DIV) - 1 then
                        clk_count <= 0;
                        state <= TRANSFER;
                        sclk_int   <= '1';  
                    end if;

                when TRANSFER =>
                    clk_count <= clk_count + 1;

                    -- SCLK falling edge (shift TX)
                    if clk_count = CLK_DIV - 1 then
                        sclk_int  <= '0';
                        shift_tx  <= shift_tx(30 downto 0) & '0'; -- shift left

                    -- SCLK rising edge (sample MISO)
                    elsif clk_count = (2 * CLK_DIV) - 1 then
                        sclk_int  <= '1';

                        if bit_cnt < 31 then
                            shift_rx  <= shift_rx(30 downto 0) & miso; -- sample in
                            bit_cnt   <= bit_cnt + 1;
                            clk_count <= 0;
                        else
                            sclk_int <= '0';
                            state <= DEASSERT_CS;
                            clk_count <= 0; -- restart
                        end if;
                    end if;

                when DEASSERT_CS =>
                    if clk_count = (2 * CLK_DIV) - 1 then
                        state <= DONE_STATE;
                    else
                        clk_count <= clk_count + 1;
                    end if;

                when DONE_STATE =>
                    cs_int    <= '1';

                    if start = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end if;
    end process;

end Behavioral;



