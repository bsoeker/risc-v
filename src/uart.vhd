library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        addr        : in  std_logic_vector(1 downto 0); -- 0x00 = data, 0x01 = status
        wr_en       : in  std_logic;
        write_data  : in  std_logic_vector(31 downto 0);
        read_data   : out std_logic_vector(31 downto 0);
        RsTx        : out std_logic
    );
end uart;

architecture Behavioral of uart is
    constant CLOCK_FREQ : integer := 25_000_000;
    constant BAUD_RATE  : integer := 115200;
    constant BAUD_TICKS : integer := CLOCK_FREQ / BAUD_RATE;

    type state_type is (IDLE, START, DATA, STOP);
    signal state         : state_type := IDLE;
    signal bit_index     : integer range 0 to 7 := 0;
    signal baud_counter  : integer := 0;
    signal shift_reg     : std_logic_vector(7 downto 0);
    signal tx_reg        : std_logic := '1';

    signal tx_ready      : std_logic := '0';

    signal uart_wr_en    : std_logic;
    signal uart_data     : std_logic_vector(7 downto 0);

    signal read_data_reg : std_logic_vector(31 downto 0) := (others => '0');
begin

    -- Output TX pin
    RsTx <= tx_reg;

    -- FSM Ready flag 
    tx_ready <= '1' when state = IDLE else '0';

    -- UART TX FSM
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state        <= IDLE;
                tx_reg       <= '1';
                baud_counter <= 0;
                bit_index    <= 0;
            else
                case state is
                    when IDLE =>
                        if uart_wr_en = '1' then
                            shift_reg    <= uart_data;
                            baud_counter <= 0;
                            state        <= START;
                        end if;

                    when START =>
                        if baud_counter = BAUD_TICKS - 1 then
                            baud_counter <= 0;
                            tx_reg <= '0'; -- Start bit
                            state <= DATA;
                        else
                            baud_counter <= baud_counter + 1;
                        end if;

                    when DATA =>
                        if baud_counter = BAUD_TICKS - 1 then
                            baud_counter <= 0;
                            tx_reg <= shift_reg(bit_index);
                            if bit_index = 7 then
                                bit_index <= 0;
                                state <= STOP;
                            else
                                bit_index <= bit_index + 1;
                            end if;
                        else
                            baud_counter <= baud_counter + 1;
                        end if;

                    when STOP =>
                        if baud_counter = BAUD_TICKS - 1 then
                            baud_counter <= 0;
                            tx_reg <= '1'; -- Stop bit
                            state <= IDLE;
                        else
                            baud_counter <= baud_counter + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

    -- MMIO: extract write data
    uart_data  <= write_data(7 downto 0);

    -- Allow write only when TX is ready
    uart_wr_en <= '1' when (wr_en = '1' and addr = "00" and tx_ready = '1') else '0';

    -- MMIO read response (latched)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                read_data_reg <= (others => '0');
            else
                case addr is
                    when "00" =>  -- TX register (dummy read)
                        read_data_reg <= (others => '0');
                    when "01" =>  -- STATUS register
                        read_data_reg <= (31 downto 1 => '0') & tx_ready;
                    when others =>
                        read_data_reg <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    -- Connect latched read data to output
    read_data <= read_data_reg;

end Behavioral;

