library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    Port (
        opcode       : in  std_logic_vector(6 downto 0);
        funct3       : in  std_logic_vector(2 downto 0);
        funct7       : in  std_logic_vector(6 downto 0);

        alu_control  : out std_logic_vector(3 downto 0);
        alu_src_a    : out std_logic_vector(1 downto 0); -- 00 = reg, 01 = PC, 10 = 0x00000000
        alu_src_b    : out std_logic; -- 0 = reg, 1 = imm
        reg_write    : out std_logic;
        mem_op       : out std_logic; -- 0 = read, 1 = write
        wb_sel       : out std_logic_vector(1 downto 0);
        imm_type     : out std_logic_vector(2 downto 0);
        jump         : out std_logic;
        branch       : out std_logic;
        stall        : out std_logic; -- stall flag for RAM LOAD instructions
        load_phase1  : out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is
begin
    process(opcode, funct3, funct7)
    begin
        -- Set defaults
        alu_control  <= "0000";
        alu_src_a    <= "00";
        alu_src_b    <= '0';
        reg_write    <= '0';
        mem_op       <= '0';
        wb_sel       <= "00";
        imm_type     <= "000";
        jump         <= '0';
        branch       <= '0';
        stall        <= '0';
        load_phase1  <= '0';

        case opcode is

            -- R-type (e.g., ADD, SUB, AND, OR, etc.)
            when "0110011" =>
                alu_src_a <= "00"; -- reg
                alu_src_b <= '0'; -- reg
                reg_write <= '1';

                case funct3 is
                    when "000" =>
                        if funct7 = "0000000" then
                            alu_control <= "0000"; -- ADD
                        elsif funct7 = "0100000" then
                            alu_control <= "0001"; -- SUB
                        end if;
                    when "001" => alu_control <= "0101"; -- SLL
                    when "010" => alu_control <= "1000"; -- SLT
                    when "011" => alu_control <= "1001"; -- SLTU
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

            -- I-type (e.g., ADDI, ORI)
            when "0010011" =>  -- ALU imm
                alu_src_a <= "00"; -- reg
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
                load_phase1  <= '1';
                stall        <= '1';
                alu_src_a    <= "00";
                alu_src_b    <= '1';
                alu_control  <= "0000"; -- ADD
                reg_write    <= '1';
                mem_op       <= '0'; -- read
                wb_sel       <= "01";
                imm_type     <= "000"; -- I-type

            -- Store
            when "0100011" => -- SW
                alu_src_a   <= "00";
                alu_src_b   <= '1';
                alu_control <= "0000"; -- ADD
                mem_op      <= '1'; -- write
                wb_sel      <= "01";
                imm_type    <= "001"; -- S-type

            -- Branch
            when "1100011" => -- All branches
                branch      <= '1';
                alu_src_a   <= "00";
                alu_src_b   <= '0';
                imm_type    <= "010"; -- SB-type
                alu_control <= 
                    "0001" when funct3 = "000" or funct3 = "001" else -- SUB for BEQ/BNE
                    "1000" when funct3 = "100" or funct3 = "101" else -- SLT  for BLT/BGE
                    "1001";                                           -- SLTU for BLTU/BGEU


            -- JAL
            when "1101111" =>
                jump        <= '1';
                alu_src_a   <= "01"; -- PC
                alu_src_b   <= '1'; -- imm
                alu_control <= "0000"; -- PC + imm
                reg_write   <= '1';
                imm_type    <= "100"; -- UJ-type
                wb_sel      <= "10"; -- PC+4

            -- JALR
            when "1100111" =>
                jump        <= '1';
                alu_src_a   <= "00"; -- reg
                alu_src_b   <= '1'; -- imm
                alu_control <= "0000"; -- reg + imm
                reg_write   <= '1';
                imm_type    <= "000"; -- I-type
                wb_sel      <= "10"; -- PC+4

            -- LUI / AUIPC
            when "0110111" => -- LUI
                alu_src_a   <= "10"; -- 0x00000000
                alu_src_b   <= '1';
                alu_control <= "0000"; 
                reg_write   <= '1';
                imm_type    <= "011"; -- U-type

            when "0010111" => -- AUIPC
                alu_src_a   <= "01"; -- PC
                alu_src_b   <= '1';
                alu_control <= "0000"; 
                reg_write   <= '1';
                imm_type    <= "011"; -- U-type

            when others =>
                null;
        end case;
    end process;
end Behavioral;



