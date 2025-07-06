library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
        op_a       : in  std_logic_vector(31 downto 0);
        op_b       : in  std_logic_vector(31 downto 0);
        alu_control: in  std_logic_vector(3 downto 0);
        result     : out std_logic_vector(31 downto 0);
        zero       : out std_logic               -- result == 0 flag
    );
end alu;

architecture Behavioral of alu is
    signal a, b : signed(31 downto 0);
    signal r    : signed(31 downto 0);
begin
    a <= signed(op_a);
    b <= signed(op_b);

    process(a, b, alu_control)
    begin
        case alu_control is
            when "0000" =>  -- ADD
                r <= a + b;
            when "0001" =>  -- SUB
                r <= a - b;
            when "0010" =>  -- AND
                r <= a and b;
            when "0011" =>  -- OR
                r <= a or b;
            when "0100" =>  -- XOR
                r <= a xor b;
            when "0101" =>  -- SLL (logical shift left)
                r <= shift_left(a, to_integer(unsigned(b(4 downto 0))));
            when "0110" =>  -- SRL (logical shift right)
                r <= signed(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
            when "0111" =>  -- SRA (arithmetic shift right)
                r <= shift_right(a, to_integer(unsigned(b(4 downto 0))));
            when "1000" =>  -- SLT (signed less than)
                if a < b then
                    r <= (others => '0'); r(0) <= '1';
                else
                    r <= (others => '0');
                end if;
            when "1001" =>  -- SLTU (unsigned less than)
                if unsigned(op_a) < unsigned(op_b) then
                    r <= (others => '0'); r(0) <= '1';
                else
                    r <= (others => '0');
                end if;

            when others =>
                r <= (others => '0');
        end case;
    end process;

    result <= std_logic_vector(r);
    zero   <= '1' when r = 0 else '0';
end Behavioral;

