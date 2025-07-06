library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    Port (
        opcode      : in  std_logic_vector(6 downto 0);
        funct3      : in  std_logic_vector(2 downto 0);
        funct7      : in  std_logic_vector(6 downto 0);

        alu_control : out std_logic_vector(3 downto 0);
        alu_src_a   : out std_logic; -- 0 = reg, 1 = PC
        alu_src_b   : out std_logic; -- 0 = reg, 1 = imm
        reg_write   : out std_logic;
        mem_read    : out std_logic;
        mem_write   : out std_logic;
        mem_to_reg  : out std_logic;
        pc_src      : out std_logic;
        imm_type    : out std_logic_vector(2 downto 0)
    );
end control_unit;

architecture Behavioral of control_unit is
begin
    process(opcode, funct3, funct7)
    begin
        -- Set defaults
        alu_control <= "0000";
        alu_src_a   <= '0';
        alu_src_b   <= '0';
        reg_write   <= '0';
        mem_read    <= '0';
        mem_write   <= '0';
        mem_to_reg  <= '0';
        pc_src      <= '0';
        imm_type    <= "000";

        case opcode is

            -- R-type (e.g., ADD, SUB, AND, OR, etc.)
            when "0110011" =>
                alu_src_a <= '0'; -- reg
                alu_src_b <= '0'; -- reg
                reg_write <= '1';
                imm_type  <= "000"; -- irrelevant

                case funct3 is
                    when "000" =>
                        if funct7 = "0000000" then
                            alu_control <= "0000"; -- ADD
                        elsif funct7 = "0100000" then
                            alu_control <= "0001"; -- SUB
                        end if;
                    when "001" => alu_control <= "0101"; -- SLL
                    when "010" => alu_control <= "1000"; -- SLT
                    when "100" => alu_control <= "0100"; -- XOR
                    when "101" =>
                        if funct7 = "0000000" then
                            alu_control <= "0110"; -- SRL
                        elsif funct7 = "0100000" then
                            alu_control <= "0111"; -- SRA
                        end if;
                    when "110" => alu_control <= "0011"; -- OR
                    when "111" => alu_control <= "0010"; -- AND
                    when others => alu_control <= "0000";
                end case;

            -- I-type (e.g., ADDI, ORI, LW)
            when "0010011" =>  -- ALU imm
                alu_src_a <= '0'; -- reg
                alu_src_b <= '1'; -- imm
                reg_write <= '1';
                imm_type  <= "000"; -- I-type

                case funct3 is
                    when "000" => alu_control <= "0000"; -- ADDI
                    when "001" => alu_control <= "0101"; -- SLLI
                    when "010" => alu_control <= "1000"; -- SLTI
                    when "011" => alu_control <= "1001"; -- SLTIU
                    when "100" => alu_control <= "0100"; -- XORI
                    when "101" =>
                        if funct7 = "0000000" then
                            alu_control <= "0110"; -- SRLI
                        elsif funct7 = "0100000" then
                            alu_control <= "0111"; -- SRAI
                        end if;
                    when "110" => alu_control <= "0011"; -- ORI
                    when "111" => alu_control <= "0010"; -- ANDI
                    when others => alu_control <= "0000";
                end case;

            -- Load
            when "0000011" => -- LW
                alu_src_a   <= '0';
                alu_src_b   <= '1';
                alu_control <= "0000"; -- ADD
                reg_write   <= '1';
                mem_read    <= '1';
                mem_to_reg  <= '1';
                imm_type    <= "000"; -- I-type

            -- Store
            when "0100011" => -- SW
                alu_src_a   <= '0';
                alu_src_b   <= '1';
                alu_control <= "0000"; -- ADD
                mem_write   <= '1';
                imm_type    <= "001"; -- S-type

            -- Branch
            when "1100011" => -- BEQ, BNE
                alu_src_a   <= '0';
                alu_src_b   <= '0';
                alu_control <= "0001"; -- SUB
                pc_src      <= '1';
                imm_type    <= "010"; -- SB-type

            -- JAL
            when "1101111" =>
                alu_src_a   <= '1'; -- PC
                alu_src_b   <= '1'; -- imm
                alu_control <= "0000"; -- PC + imm
                reg_write   <= '1';
                pc_src      <= '1';
                imm_type    <= "100"; -- UJ-type

            -- JALR
            when "1100111" =>
                alu_src_a   <= '0'; -- reg
                alu_src_b   <= '1'; -- imm
                alu_control <= "0000"; -- reg + imm
                reg_write   <= '1';
                pc_src      <= '1';
                imm_type    <= "000"; -- I-type

            -- LUI / AUIPC
            when "0110111" => -- LUI
                alu_src_a   <= '0';
                alu_src_b   <= '1';
                alu_control <= "0000"; 
                reg_write   <= '1';
                imm_type    <= "011"; -- U-type

            when "0010111" => -- AUIPC
                alu_src_a   <= '1';
                alu_src_b   <= '1';
                alu_control <= "0000"; 
                reg_write   <= '1';
                imm_type    <= "011"; -- U-type

            when others =>
                -- All defaults already set above
                null;
        end case;
    end process;
end Behavioral;



