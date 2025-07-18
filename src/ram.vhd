library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram is
    generic (
        addr_width : integer := 12  -- 4096 words = 16KB
    );
    port (
        clk        : in  std_logic;
        addr       : in  std_logic_vector(addr_width - 1 downto 0);
        write_en   : in  std_logic;
        write_data : in  std_logic_vector(31 downto 0);
        write_mask : in  std_logic_vector(3 downto 0);
        read_data  : out std_logic_vector(31 downto 0)
    );
end ram;

architecture Behavioral of ram is
    -- Split into 4 byte-wide RAMs
    type ram_byte is array(0 to 2**addr_width - 1) of std_logic_vector(7 downto 0);
    signal mem0, mem1, mem2, mem3 : ram_byte := (others => (others => '0'));

    signal rdata : std_logic_vector(31 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                if write_mask(0) = '1' then
                    mem0(to_integer(unsigned(addr))) <= write_data(7 downto 0);
                end if;
                if write_mask(1) = '1' then
                    mem1(to_integer(unsigned(addr))) <= write_data(15 downto 8);
                end if;
                if write_mask(2) = '1' then
                    mem2(to_integer(unsigned(addr))) <= write_data(23 downto 16);
                end if;
                if write_mask(3) = '1' then
                    mem3(to_integer(unsigned(addr))) <= write_data(31 downto 24);
                end if;
            end if;

            -- Synchronous read
            rdata(7 downto 0)   <= mem0(to_integer(unsigned(addr)));
            rdata(15 downto 8)  <= mem1(to_integer(unsigned(addr)));
            rdata(23 downto 16) <= mem2(to_integer(unsigned(addr)));
            rdata(31 downto 24) <= mem3(to_integer(unsigned(addr)));
        end if;
    end process;

    read_data <= rdata;

end Behavioral;

