library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProgramCounter is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        pc_in   : in  std_logic_vector(31 downto 0);  -- target addr (from ALU or imm)
        pc_out  : out std_logic_vector(31 downto 0)
    );
end ProgramCounter;

architecture Behavioral of ProgramCounter is
    signal pc_reg : std_logic_vector(31 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= (others => '0');
            else
                pc_reg <= pc_in;
            end if;
        end if;
    end process;

    pc_out <= pc_reg;

end Behavioral;

