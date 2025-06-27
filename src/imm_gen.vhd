library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_gen is
    Port (
        instr    : in  std_logic_vector(31 downto 0);
        imm_type : in  std_logic_vector(2 downto 0); -- selects I, S, SB, U, UJ
        imm_out  : out std_logic_vector(31 downto 0)
    );
end imm_gen;

architecture Behavioral of imm_gen is
    signal imm : signed(31 downto 0);
begin
    process(instr, imm_type)
    begin
        case imm_type is
            when "000" =>  -- I-type
                imm <= resize(signed(instr(31 downto 20)), 32);

            when "001" =>  -- S-type
                imm <= resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32);

            when "010" =>  -- SB-type (branch)
                imm <= resize(
                    signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'),
                    32
                );

            when "011" =>  -- U-type (LUI/AUIPC)
                imm <= signed(instr(31 downto 12) & x"000"); -- shift left 12 (<<12)

            when "100" =>  -- UJ-type (JAL)
                imm <= resize(
                    signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'),
                    32
                );

            when others =>
                imm <= (others => '0');
        end case;
    end process;

    imm_out <= std_logic_vector(imm);
end Behavioral;

