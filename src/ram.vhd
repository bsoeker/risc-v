library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram is
    generic (
        addr_width : integer := 12;  -- 2^12 = 4096 = 4KB
        data_width : integer := 32
    );
    port (
        clk        : in  std_logic;
        addr       : in  std_logic_vector(addr_width - 1 downto 0);
        write_en   : in  std_logic; -- '0' => read, '1' => write
        write_data : in  std_logic_vector(data_width - 1 downto 0);
        write_mask : in std_logic_vector(3 downto 0);
        read_data  : out std_logic_vector(data_width - 1 downto 0)
    );
end ram;

architecture Behavioral of ram is
    type ram_type is array(0 to 2**addr_width - 1) of std_logic_vector(7 downto 0);
    signal mem : ram_type := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                if write_mask(0) = '1' then
                    mem(to_integer(unsigned(addr)))     <= write_data(7 downto 0);
                end if;
                if write_mask(1) = '1' then
                    mem(to_integer(unsigned(addr)) + 1) <= write_data(15 downto 8);
                end if;
                if write_mask(2) = '1' then
                    mem(to_integer(unsigned(addr)) + 2) <= write_data(23 downto 16);
                end if;
                if write_mask(3) = '1' then
                    mem(to_integer(unsigned(addr)) + 3) <= write_data(31 downto 24);
                end if;
            end if;
        end if;
    end process;

    -- Asynchronous read
    read_data <= 
        mem(to_integer(unsigned(addr)) + 3) &
        mem(to_integer(unsigned(addr)) + 2) &
        mem(to_integer(unsigned(addr)) + 1) &
        mem(to_integer(unsigned(addr)));

end Behavioral;

