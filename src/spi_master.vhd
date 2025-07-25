library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    Port (
        clk       : in  std_logic;  -- 25 MHz system clock
        reset     : in  std_logic;
        spi_en    : in  std_logic;
        start     : in  std_logic;
        mosi_data : in  std_logic_vector(31 downto 0); -- only lower 8 bits used
        miso      : in  std_logic;
        mosi      : out std_logic;
        sclk      : out std_logic;
        scs       : out std_logic;
        done      : out std_logic;
        rx_data   : out std_logic_vector(7 downto 0)
    );
end spi_master;

architecture Behavioral of spi_master is

    type state_type is (IDLE, ASSERT_SCS, BIT_SEND, DONE_STATE);
    signal state     : state_type := IDLE;

    signal shift_tx  : std_logic_vector(7 downto 0);
    signal shift_rx  : std_logic_vector(7 downto 0);
    signal bit_cnt   : unsigned(3 downto 0);
    signal sclk_reg  : std_logic := '0';
    signal mosi_reg  : std_logic := '0';
    signal scs_reg   : std_logic := '1';

begin

    sclk <= sclk_reg;
    mosi <= mosi_reg;
    scs  <= scs_reg;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state     <= IDLE;
                done      <= '0';
                sclk_reg  <= '0';
                scs_reg   <= '1';
                mosi_reg  <= '0';
                rx_data   <= (others => '0');
                shift_tx  <= (others => '0');
                shift_rx  <= (others => '0');
                bit_cnt   <= (others => '0');

            else
                case state is
                    when IDLE =>
                        done     <= '0';
                        sclk_reg <= '0';
                        if start = '1' and spi_en = '1' then
                            shift_tx  <= mosi_data(7 downto 0);
                            bit_cnt   <= "0000";
                            scs_reg   <= '0';
                            mosi_reg  <= mosi_data(7);
                            state     <= ASSERT_SCS;
                        end if;

                    when ASSERT_SCS =>
                        state <= BIT_SEND;

                    when BIT_SEND =>
                        ------------------------------------------------------
                        -- 1. Toggle clock
                        ------------------------------------------------------
                        sclk_reg  <= not sclk_reg;
                    
                        ------------------------------------------------------
                        -- 2. Rising or falling edge *after* toggle?
                        ------------------------------------------------------
                        if sclk_reg = '1' then           -- << rising edge  (new state)
                            --------------------------------------------------
                            -- sample MISO  (bit arrives from slave)
                            --------------------------------------------------
                            shift_rx <= shift_rx(6 downto 0) & miso;
                    
                            if bit_cnt = 8 then
                                state <= DONE_STATE;
                            else
                                bit_cnt <= bit_cnt + 1;
                            end if;
                    
                        else                              -- falling edge  (sclk_reg = '0')
                            --------------------------------------------------
                            -- put next MOSI bit on the line
                            --------------------------------------------------
                            mosi_reg <= shift_tx(6);              -- send next bit
                            shift_tx <= shift_tx(6 downto 0) & '0';
                        end if;

                    when DONE_STATE =>
                        scs_reg  <= '1';
                        sclk_reg <= '0';
                        rx_data  <= shift_rx;
                        done     <= '1';
                        state    <= IDLE;
                end case;
            end if;
        end if;
    end process;

end Behavioral;

