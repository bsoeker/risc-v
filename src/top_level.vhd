library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk   : in std_logic;
        reset : in std_logic
    );
end top;

architecture Behavioral of top is

    -- === Signals ===

    -- PC
    signal pc            : std_logic_vector(31 downto 0);
    signal pc_plus_four  : std_logic_vector(31 downto 0);
    signal next_pc       : std_logic_vector(31 downto 0);
    signal jalr_target   : std_logic_vector(31 downto 0);
    signal branch_target : std_logic_vector(31 downto 0);
    signal branch_taken  : std_logic;

    -- Instruction
    signal instr    : std_logic_vector(31 downto 0);
    signal opcode   : std_logic_vector(6 downto 0);
    signal funct3   : std_logic_vector(2 downto 0);
    signal funct7   : std_logic_vector(6 downto 0);
    signal rs1_addr : std_logic_vector(4 downto 0);
    signal rs2_addr : std_logic_vector(4 downto 0);
    signal rd_addr  : std_logic_vector(4 downto 0);

    -- RegFile
    signal rs1_data, rs2_data : std_logic_vector(31 downto 0);
    signal reg_write_data     : std_logic_vector(31 downto 0);

    -- Immediate
    signal imm : std_logic_vector(31 downto 0);

    -- ALU
    signal alu_in_a, alu_in_b : std_logic_vector(31 downto 0);
    signal alu_result         : std_logic_vector(31 downto 0);
    signal zero_flag          : std_logic;

    -- Memory
    signal mem_data_out     : std_logic_vector(31 downto 0);
    signal ram_write_en     : std_logic;
    signal byte_offset      : std_logic_vector(1 downto 0);
    signal store_misaligned : std_logic;
    signal loaded_value     : std_logic_vector(31 downto 0);

    -- Control signals
    signal alu_control : std_logic_vector(3 downto 0);
    signal alu_src_a   : std_logic_vector(1 downto 0);
    signal alu_src_b   : std_logic;
    signal reg_write   : std_logic;
    signal mem_op      : std_logic;
    signal wb_sel      : std_logic_vector(1 downto 0);
    signal imm_type    : std_logic_vector(2 downto 0);
    signal jump        : std_logic;
    signal branch      : std_logic;
    signal write_mask  : std_logic_vector(3 downto 0);
    signal read_mask   : std_logic_vector(3 downto 0);
    signal is_unsigned : std_logic;

begin
    pc_plus_four  <= std_logic_vector(unsigned(pc) + 4);
    jalr_target   <= alu_result and x"FFFFFFFE";  -- Clear LSB for JALR
    branch_target <= std_logic_vector(signed(pc) + signed(imm));
    branch_taken  <= '1' when branch = '1' and (
        (funct3 = "000" and zero_flag = '1') or -- BEQ
        (funct3 = "001" and zero_flag = '0') or -- BNE
        (funct3 = "100" and alu_result = x"00000001") or -- BLT (SLT output 1)
        (funct3 = "101" and alu_result = x"00000000") or -- BGE (SLT output 0)
        (funct3 = "110" and alu_result = x"00000001") or -- BLTU
        (funct3 = "111" and alu_result = x"00000000")    -- BGEU
    ) else '0';

    
    next_pc <=
        jalr_target   when (jump = '1' and opcode = "1100111") else
        alu_result    when (jump = '1') else
        branch_target when (branch_taken = '1') else
        pc_plus_four;


    -- === Program Counter ===
    pc_unit: entity work.ProgramCounter
        port map (
            clk    => clk,
            reset  => reset,
            pc_in  => next_pc,  -- For jumps and branches
            pc_out => pc
        );

    -- === Instruction ROM ===
    rom_inst: entity work.rom
        port map (
            addr => pc(9 downto 0),
            data => instr
        );

    -- === Decode Fields ===
    opcode   <= instr(6 downto 0);
    rd_addr  <= instr(11 downto 7);
    funct3   <= instr(14 downto 12);
    rs1_addr <= instr(19 downto 15);
    rs2_addr <= instr(24 downto 20);
    funct7   <= instr(31 downto 25);

    -- === Control Unit ===
    cu: entity work.control_unit
        port map (
            opcode      => opcode,
            funct3      => funct3,
            funct7      => funct7,
            alu_control => alu_control,
            alu_src_a   => alu_src_a,
            alu_src_b   => alu_src_b,
            reg_write   => reg_write,
            mem_op      => mem_op,
            wb_sel      => wb_sel,
            imm_type    => imm_type,
            jump        => jump,
            branch      => branch,
            write_mask  => write_mask,
            read_mask   => read_mask,
            is_unsigned => is_unsigned
        );

    -- === Register File ===
    regfile_inst: entity work.reg_file
        port map (
            clk       => clk,
            rs1_addr  => rs1_addr,
            rs2_addr  => rs2_addr,
            rd_addr   => rd_addr,
            rd_data   => reg_write_data,
            reg_write => reg_write,
            rs1_data  => rs1_data,
            rs2_data  => rs2_data
        );

    -- === Immediate Generator ===
    immgen_inst: entity work.imm_gen
        port map (
            instr    => instr,
            imm_type => imm_type,
            imm_out  => imm
        );

    -- === ALU Source Muxes ===
    mux_a_inst: entity work.mux_a
        port map (
            sel    => alu_src_a,
            rs1    => rs1_data,
            pc     => pc,
            result => alu_in_a
        );

    mux_b_inst: entity work.mux_b
        port map (
            sel    => alu_src_b,
            rs2    => rs2_data,
            imm    => imm,
            result => alu_in_b
        );

    -- === ALU ===
    alu_inst: entity work.alu
        port map (
            op_a        => alu_in_a,
            op_b        => alu_in_b,
            alu_control => alu_control,
            result      => alu_result,
            zero        => zero_flag
        );

    -- Misaligned write prevention logic
    byte_offset <= alu_result(1 downto 0);
    store_misaligned <= '1' when 
        (funct3 = "001" and byte_offset(0) = '1') or   -- SH misaligned
        (funct3 = "010" and byte_offset /= "00")       -- SW misaligned
    else '0';

    ram_write_en <= '1' when mem_op = '1' and alu_result(31 downto 12) = x"00000"
                    and store_misaligned = '0' else '0';
    -- === RAM (Data Memory) ===
    ram_inst: entity work.ram
        port map (
            clk        => clk,
            addr       => alu_result(11 downto 0),
            write_en   => ram_write_en,
            write_data => rs2_data,
            write_mask => write_mask,
            read_data  => mem_data_out
        );

    -- === Load Unit ===
    load_unit_inst: entity work.load_unit
        port map (
            read_mask     => read_mask,
            is_unsigned   => is_unsigned,
            mem_data      => mem_data_out,
            loaded_value  => loaded_value
        );

    -- === Writeback Mux ===
    mux_wb_inst: entity work.mux_wb
        port map (
            sel => wb_sel,
            a   => alu_result,
            b   => loaded_value,
            c   => pc_plus_four,
            y   => reg_write_data
        );

end Behavioral;

