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
    signal pc       : std_logic_vector(31 downto 0);
    signal next_pc  : std_logic_vector(31 downto 0);

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
    signal imm        : std_logic_vector(31 downto 0);

    -- ALU
    signal alu_in_a, alu_in_b : std_logic_vector(31 downto 0);
    signal alu_result         : std_logic_vector(31 downto 0);
    signal zero_flag          : std_logic;

    -- Memory
    signal ram_data_out : std_logic_vector(31 downto 0);

    -- Control signals
    signal alu_control : std_logic_vector(3 downto 0);
    signal alu_src_a   : std_logic;
    signal alu_src_b   : std_logic;
    signal reg_write   : std_logic;
    signal mem_read    : std_logic;
    signal mem_write   : std_logic;
    signal mem_to_reg  : std_logic;
    signal pc_src      : std_logic;
    signal imm_type    : std_logic_vector(2 downto 0);

begin

    -- === Program Counter ===
    pc_unit: entity work.ProgramCounter
        port map (
            clk    => clk,
            reset  => reset,
            pc_src => pc_src,
            pc_in  => alu_result,  -- For jumps and branches
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
            mem_read    => mem_read,
            mem_write   => mem_write,
            mem_to_reg  => mem_to_reg,
            pc_src      => pc_src,
            imm_type    => imm_type
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

    -- === RAM (Data Memory) ===
    ram_inst: entity work.ram
        port map (
            clk        => clk,
            addr       => alu_result(9 downto 0),
            write_en   => mem_write,
            write_data => rs2_data,
            read_data  => ram_data_out
        );

    -- === Writeback Mux ===
    mux_wb_inst: entity work.mux_wb
        port map (
            sel => mem_to_reg,
            a   => alu_result,
            b   => ram_data_out,
            y   => reg_write_data
        );

end Behavioral;

