library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk   : in  std_logic;
        reset : in  std_logic;
        RsTx  : out std_logic;
        led   : out std_logic_vector(15 downto 0);
        JA    : out std_logic_vector(7 downto 0)
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
    signal mem_data         : std_logic_vector(31 downto 0);
    signal ram_read_data    : std_logic_vector(31 downto 0);
    signal ram_write_en     : std_logic;
    signal byte_offset      : std_logic_vector(1 downto 0);
    signal store_misaligned : std_logic;
    signal loaded_value     : std_logic_vector(31 downto 0);
    signal ram_en           : std_logic;
    signal ram_addr         : std_logic_vector(11 downto 0);
    signal store_write_data : std_logic_vector(31 downto 0);
    signal store_write_mask : std_logic_vector(3 downto 0);
    signal rom_en           : std_logic;
    signal rom_addr         : std_logic_vector(11 downto 0);
    signal rom_read_data    : std_logic_vector(31 downto 0);


    -- UART
    signal uart_addr      : std_logic_vector(1 downto 0);
    signal uart_en        : std_logic;
    signal uart_read_data : std_logic_vector(31 downto 0);
    signal uart_write_en  : std_logic;

    -- SPI
    signal spi_addr      : std_logic_vector(1 downto 0);
    signal spi_en        : std_logic;
    signal spi_start     : std_logic;
    signal spi_miso      : std_logic;
    signal spi_read_data : std_logic_vector(7 downto 0);
    signal spi_rx_reg    : std_logic_vector(7 downto 0) := (others => '0');
    signal spi_done      : std_logic;
    signal spi_done_reg  : std_logic := '0';



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
    signal read_mask   : std_logic_vector(3 downto 0);
    signal stall       : std_logic; -- from control unit

    signal stall_active : std_logic;  -- Whether we're currently in a stall
    signal stall_delay  : std_logic;  -- Whether we just started the stall

    -- Clock Divider
    signal slow_clk : std_logic;
    -- Sync external reset into slow_clk domain
    signal internal_reset : std_logic;
    signal reset_sync_0 : std_logic := '1';
    signal reset_sync_1 : std_logic := '1';

begin

    -- Clock Divider
    clkdiv_inst: entity work.clock_divider
        generic map (
            DIVIDE_BY => 2  -- each toggle = 2 cycles, full period = 4 → 25 MHz
        )
        port map (
            clk_in  => clk,
            reset   => '0',
            clk_out => slow_clk
        );

    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            reset_sync_0 <= reset;
            reset_sync_1 <= reset_sync_0;
        end if;
    end process;
    
    internal_reset <= reset_sync_1;

    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            if internal_reset = '1' then
                stall_active <= '0';
                stall_delay  <= '0';
            else
                -- First time we see a stall, activate for one cycle
                if stall = '1' and stall_active = '0' then
                    stall_active <= '1';
                    stall_delay  <= '1';
                -- Stall already active, deactivate
                elsif stall_active = '1' then
                    stall_active <= '0';
                    stall_delay  <= '0';
                -- Normal case
                else
                    stall_delay <= '0';
                end if;
            end if;
        end if;
    end process;



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

    next_pc <= pc when stall = '1' and stall_delay = '0' else
        jalr_target   when (jump = '1' and opcode = "1100111") else
        alu_result    when (jump = '1') else
        branch_target when (branch_taken = '1') else
        pc_plus_four;

    -- === Program Counter ===
    pc_unit: entity work.ProgramCounter
        port map (
            clk    => slow_clk,
            reset  => internal_reset,
            pc_in  => next_pc,  -- For jumps and branches
            pc_out => pc
        );

    -- === Instruction ROM ===
    rom_inst: entity work.rom
        port map (
            instr_addr => pc(11 downto 0),
            instr_data => instr,
            data_addr  => rom_addr,
            data_data  => rom_read_data
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
            stall       => stall
        );

    -- === Register File ===
    regfile_inst: entity work.reg_file
        port map (
            clk       => slow_clk,
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

    addr_dec_inst: entity work.address_decoder
    port map (
        addr      => alu_result,
        ram_en    => ram_en,
        ram_addr  => ram_addr,
        uart_en   => uart_en,
        uart_addr => uart_addr,
        rom_en    => rom_en,
        rom_addr  => rom_addr,
        spi_en    => spi_en,
        spi_addr  => spi_addr
    );

    byte_offset <= alu_result(1 downto 0);
    store_unit_inst: entity work.store_unit
    port map (
        funct3      => funct3,
        addr_offset => byte_offset,
        store_data  => rs2_data,

        write_mask  => store_write_mask,
        write_data  => store_write_data
    );


    ram_write_en <= '1' when mem_op = '1' and ram_en = '1' else '0';
    -- === RAM (Data Memory) ===
    ram_inst: entity work.ram
        port map (
            clk        => slow_clk,
            addr       => ram_addr,
            write_en   => ram_write_en,
            write_data => store_write_data,
            write_mask => store_write_mask,
            read_data  => ram_read_data
        );

    uart_write_en <= '1' when mem_op = '1' and uart_en = '1' else '0';
    -- === UART ===
    uart_inst: entity work.uart
        port map (
            clk         => slow_clk,
            reset       => internal_reset,
            addr        => uart_addr,
            wr_en       => uart_write_en,
            write_data  => rs2_data,
            read_data   => uart_read_data,
            RsTx        => RsTx
        );

    spi_start <= '1' when mem_op = '1' and spi_en = '1' and spi_addr = "00" else '0';
    JA(4) <= reset;
    spi_master_inst: entity work.spi_master
        port map (
            clk       => slow_clk,
            reset     => JA(4),
            spi_en    => spi_en,
            start     => spi_start,
            mosi_data => store_write_data,
            miso      => JA(3),
            mosi      => JA(2),
            sclk      => JA(0),
            scs       => JA(1),
            done      => spi_done,
            rx_data   => spi_read_data
        );
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                spi_rx_reg   <= (others => '0');
                spi_done_reg <= '0';
            else
                if spi_done = '1' then
                    spi_rx_reg   <= spi_read_data;
                    spi_done_reg <= '1';
                end if;
            end if;
        end if;
    end process;

    mem_data <= ram_read_data when ram_en = '1' else 
                uart_read_data when uart_en = '1' else
                rom_read_data when rom_en = '1' else
                x"000000" & spi_rx_reg when spi_en = '1' and spi_addr = "01" else
                x"0000000" & "000" & spi_done_reg when spi_en = '1' and spi_addr = "10";
    -- === Load Unit ===
    load_unit_inst: entity work.load_unit
        port map (
            funct3       => funct3,
            byte_offset  => byte_offset,
            mem_data     => mem_data,
            loaded_value => loaded_value
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

