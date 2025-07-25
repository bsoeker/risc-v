library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_controller is
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    start     : in  std_logic;
    mosi_data : in  std_logic_vector(31 downto 0);
    miso      : in  std_logic;
    mosi      : out std_logic;
    sclk      : out std_logic;
    scs       : out std_logic;
    rx_data   : out std_logic_vector(7 downto 0);
    done      : out std_logic
  );
end spi_controller;

architecture Behavioral of spi_controller is

  signal tx_dv      : std_logic := '0';
  signal tx_byte    : std_logic_vector(7 downto 0);
  signal tx_ready   : std_logic;
  signal rx_byte    : std_logic_vector(7 downto 0);
  signal rx_dv      : std_logic;
  signal byte_cnt   : unsigned(1 downto 0) := (others => '0');
  signal state      : integer range 0 to 5 := 0;

begin

  spi_master_with_cs : entity work.SPI_Master_With_Single_CS
    generic map (
      SPI_MODE          => 0,
      CLKS_PER_HALF_BIT => 2,
      MAX_BYTES_PER_CS  => 4,
      CS_INACTIVE_CLKS  => 10
    )
    port map (
      i_Rst_L     => not reset,
      i_Clk       => clk,
      i_TX_Count  => "100",  -- 4 bytes
      i_TX_Byte   => tx_byte,
      i_TX_DV     => tx_dv,
      o_TX_Ready  => tx_ready,
      o_RX_Count  => open,
      o_RX_DV     => rx_dv,
      o_RX_Byte   => rx_byte,
      o_SPI_Clk   => sclk,
      i_SPI_MISO  => miso,
      o_SPI_MOSI  => mosi,
      o_SPI_CS_n  => scs
    );

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state     <= 0;
        tx_dv     <= '0';
        byte_cnt  <= (others => '0');
        rx_data   <= (others => '0');
        done      <= '0';
      else
        tx_dv <= '0';  -- default
        done  <= '0';

        case state is
          when 0 =>  -- Wait for start
            if start = '1' then
              byte_cnt <= "00";
              state    <= 1;
            end if;

          when 1 =>  -- Wait for TX ready
            if tx_ready = '1' then
              case byte_cnt is
                when "00" => tx_byte <= mosi_data(31 downto 24);
                when "01" => tx_byte <= mosi_data(23 downto 16);
                when "10" => tx_byte <= mosi_data(15 downto 8);
                when others => tx_byte <= mosi_data(7 downto 0);
              end case;
              tx_dv <= '1';
              state <= 2;
            end if;

          when 2 =>  -- Wait for TX DV pulse to clear
            state <= 3;

          when 3 =>  -- Increment counter
            if byte_cnt = "11" then
              state <= 4;
            else
              byte_cnt <= byte_cnt + 1;
              state <= 1;
            end if;

          when 4 =>  -- Wait for RX_DV of final byte
            if rx_dv = '1' then
              rx_data <= rx_byte;
              done    <= '1';
              state   <= 0;
            end if;

          when others =>
            state <= 0;
        end case;
      end if;
    end if;
  end process;

end Behavioral;

