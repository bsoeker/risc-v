library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram is
    generic (
        addr_width : integer := 10  -- 1024 words = 4KB
    );
    port (
        clk        : in  std_logic;
        addr       : in  std_logic_vector(addr_width + 1 downto 0); -- byte address
        write_en   : in  std_logic;
        write_data : in  std_logic_vector(31 downto 0);
        write_mask : in  std_logic_vector(3 downto 0);
        read_data  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioral of ram is
    type ram_type is array (0 to 2**addr_width - 1) of std_logic_vector(31 downto 0);
    signal mem : ram_type := (others => (others => '0'));

    signal word_addr : integer range 0 to 2**addr_width - 1;
    signal rdata : std_logic_vector(31 downto 0);
begin
    word_addr <= to_integer(shift_right(unsigned(addr), 2));

    process(clk)
    begin
        if rising_edge(clk) then

            if write_en = '1' then
                if write_mask(0) = '1' then
                    mem(word_addr)(7 downto 0) <= write_data(7 downto 0);
                end if;
                if write_mask(1) = '1' then
                    mem(word_addr)(15 downto 8) <= write_data(15 downto 8);
                end if;
                if write_mask(2) = '1' then
                    mem(word_addr)(23 downto 16) <= write_data(23 downto 16);
                end if;
                if write_mask(3) = '1' then
                    mem(word_addr)(31 downto 24) <= write_data(31 downto 24);
                end if;
            end if;

            rdata(7 downto 0) <= mem(word_addr)(7 downto 0);
            rdata(15 downto 8) <= mem(word_addr)(15 downto 8);
            rdata(23 downto 16) <= mem(word_addr)(23 downto 16);
            rdata(31 downto 24) <= mem(word_addr)(31 downto 24);
        end if;
    end process;

    read_data <= rdata;
end Behavioral;

