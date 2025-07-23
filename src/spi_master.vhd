library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    Port (
        clk       : in  std_logic;  -- 25 MHz system clock
        reset     : in  std_logic;
        start     : in  std_logic;  -- start signal from CPU
        mosi_data : in  std_logic_vector(7 downto 0);  -- data to send
        miso      : in  std_logic;  -- data from slave
        mosi      : out std_logic;  -- data to slave
        sclk      : out std_logic;  -- SPI clock
        cs        : out std_logic;  -- active-low chip select
        done      : out std_logic;  -- 1 when transfer finishes
        rx_data   : out std_logic_vector(7 downto 0) -- received data
    );
end spi_master;

architecture Behavioral of spi_master is

    signal clk_count  : unsigned(5 downto 0) := (others => '0');  -- for clock division
    signal clk_en     : std_logic := '0';  -- toggles when clk_count hits divider
    signal bit_cnt    : unsigned(2 downto 0) := (others => '0');  -- 3 bits = count 0–7
    signal shift_tx   : std_logic_vector(7 downto 0) := (others => '0');
    signal shift_rx   : std_logic_vector(7 downto 0) := (others => '0');
    signal sclk_int   : std_logic := '0';
    signal state      : (IDLE, TRANSFER, DONE) := IDLE;

begin

        process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clk_count  <= (others => '0');
                clk_en     <= '0';
                bit_cnt    <= (others => '0');
                shift_tx   <= (others => '0');
                shift_rx   <= (others => '0');
                sclk_int   <= '0';
                sclk       <= '0';
                cs         <= '1';
                mosi       <= '0';
                done       <= '0';
                rx_data    <= (others => '0');
                state      <= IDLE;

            else
                ---------------------------
                -- Clock Divider
                ---------------------------
                if clk_count = 11 then  -- divide 25MHz by 12 = ~2MHz
                    clk_en <= '1';
                    clk_count <= (others => '0');
                else
                    clk_en <= '0';
                    clk_count <= clk_count + 1;
                end if;

                ---------------------------
                -- FSM Logic
                ---------------------------
                case state is

                    when IDLE =>
                        cs <= '1';
                        sclk <= '0';
                        done <= '0';
                        if start = '1' then
                            shift_tx <= mosi_data;
                            shift_rx <= (others => '0');
                            bit_cnt  <= (others => '0');
                            state <= TRANSFER;
                            cs <= '0';  -- activate slave
                        end if;

                    when TRANSFER =>
                        if clk_en = '1' then
                            -- Toggle SCLK
                            sclk_int <= not sclk_int;
                            sclk <= sclk_int;

                            if sclk_int = '0' then
                                -- Falling edge: shift out next bit
                                mosi <= shift_tx(7);
                                shift_tx <= shift_tx(6 downto 0) & '0';
                            else
                                -- Rising edge: sample MISO
                                shift_rx <= shift_rx(6 downto 0) & miso;
                                if bit_cnt = 7 then
                                    state <= DONE;
                                else
                                    bit_cnt <= bit_cnt + 1;
                                end if;
                            end if;
                        end if;

                    when DONE =>
                        cs <= '1';
                        done <= '1';
                        rx_data <= shift_rx;
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

end Behavioral;

