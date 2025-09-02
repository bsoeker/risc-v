# RISC-V RV32I Softcore CPU (Basys3)

This project contains a complete softcore CPU implementing the **RV32I** RISC-V instruction set, written in VHDL. While the implementation was tested on the **Basys3 FPGA board**, the design is **fully portable to any FPGA board** — as long as the user provides a compatible **constraints file** mapping their board’s pins (e.g., clock, UART, reset, etc.). The softcore includes memory-mapped **UART** and **SPI Master** peripheral interfaces, and comes with a minimal **bare-metal toolchain** to compile and load C programs into ROM.

---

## TL;DR (Plain English)

A simple but complete **computer from scratch**:  
- Designed a CPU in VHDL  
- Wrote a toolchain to compile and run C programs  
- Programmed it onto an FPGA with Vivado  
- Connected it to peripherals like UART and SPI for real-world I/O  

---

## Highlights

- **Custom CPU core**: Single-cycle RV32I softcore written in VHDL  
- **Bare-metal C toolchain**: Startup assembly, linker script, and Python utilities to generate FPGA ROM init files  
- **Peripheral integration**: Memory-mapped UART and SPI Master interfaces  
- **Full FPGA workflow**: Synthesized, placed, routed, and bitstream generated with **Xilinx Vivado Design Suite**  
- **End-to-end learning project**: From instruction set to running firmware on hardware  

---

## What’s Inside?

- **VHDL implementation** of a single-cycle RV32I CPU with UART and SPI_Master peripheral interfaces  
- **Bare-metal C toolchain** for compiling programs  
- Ready for simulation & deployment on **Basys3**  
- Educational, simple, and modifiable — ideal for learning how CPUs work from the ground up  

---

## Folder Structure

```
project-root/
│
├── toolchain/
│   ├── main.c           # Bare-metal test code
│   ├── start.s          # Startup assembly
│   ├── linker.ld        # Custom linker script
│   ├── convert.py       # ELF -> .mem
│   ├── prepare_rom.py   # .mem -> VHDL ROM init
│   └── fill_rom.py      # Fill the ROM with the machine code
│
├── build/               # Generated after using the toolchain!
│   ├── dump.txt
│   ├── main.elf
│   ├── main.bin
│   ├── rom.mem
│   └── rom_init.txt
│
├── src/
│   ├── rom.vhd          # VHDL ROM module to be initialized
│   └── <...other VHDL components...>
│
├── build.sh             # Build script for the baremetal C toolchain
│   
├── Basys-3-Master.xdc   # Constraints file for Basys3 Board
│   
└── README.md
```

---

## Toolchain Setup (Linux)

This project uses the **xPack prebuilt RISC-V GCC** toolchain:

### 1. Download
```bash
wget https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/\
v14.2.0-3/xpack-riscv-none-elf-gcc-14.2.0-3-linux-x64.tar.gz

tar -zxvf xpack-riscv-none-elf-gcc-14.2.0-3-linux-x64.tar.gz
```

### 2. Add to PATH
Add this to the end of `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$PATH:$HOME/xpack-riscv-none-elf-gcc-14.2.0-3/bin/"
```
Then:
```bash
source ~/.bashrc
```

### 3. Confirm
```bash
riscv-none-elf-gcc --version
```

---

## Quickstart

This section walks through the full flow:  
1. **Programming the FPGA with Vivado**  
2. **Building and updating firmware with the custom toolchain**

---

### 1. FPGA Programming Flow (Vivado)

1. Open **Vivado Design Suite** and create a new project for your Xilinx board (e.g., Basys3).  
2. Add all files inside the `src/` directory as **source files**.  
   - Set the VHDL standard to **2008**.  
3. Add the provided constraints file (`Basys-3-Master.xdc`) to match pin assignments (clock, UART, reset, etc.).  
4. (Optional but recommended) Add the testbench file `test/tb_top.vhd` as a **simulation source**.  
   - Run Vivado’s built-in simulation environment to observe the CPU behavior.  
   - Inspect **waveforms** (e.g., PC, instructions, memory bus, UART signals) to verify functionality before programming hardware.  
5. Run the following Vivado flow for hardware programming:  
   - **Synthesis**  
   - **Implementation**  
   - **Bitstream Generation**  
6. Open **Hardware Manager**, connect to the FPGA board, and program it with the generated `.bit` file.

⚠️ **Important**: The instruction ROM (`rom.vhd`) is initialized at synthesis time.  
Whenever you change your firmware (e.g., new program compiled with the toolchain), you must re-run the Vivado flow (Synthesis → Implementation → Bitstream Generation → Program Device).  

---

### 2. Toolchain Usage (from Root)

You can build and load your C/assembly programs into the ROM using the provided script:

```bash
./build.sh
```

This script will:

- Compile your C and assembly source files using **riscv-none-elf-gcc**
- Convert the output to a flat binary
- Generate a `.mem` file
- Format it into a VHDL-friendly ROM initialization file and replace the contents of `rom.vhd`

---

## Python Requirements

- Python 3.x
- No external libraries required

---

## Target Hardware

- Digilent **Basys3 FPGA Board** or an FPGA Board of your choice  
- 100 MHz clock (you may need a clock divider)  
- 4K RAM, 4K ROM (configurable via linker script)  
- Built and deployed with the **Xilinx Vivado Design Suite**  

