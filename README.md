# RISC-V RV32I Softcore CPU (Basys3)

This project contains a complete softcore CPU implementing the **RV32I** RISC-V instruction set, written in VHDL. While the implementation was tested on the **Basys3 FPGA board**, the design is **fully portable to any FPGA board** — as long as the user provides a compatible **constraints file** mapping their board’s pins (e.g., clock, UART, reset, etc.). The softcore includes memory-mapped **UART** and **SPI Master** peripheral interfaces, and comes with a minimal **bare-metal toolchain** to compile and load C programs into ROM.

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
│   └── fill_rom.py      # fill the rom with the machine code
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
├── build.sh             # build script for the baremetal C toolchain
│   
├── Basys-3-Master.xdc   # Constraints file for Basys3 Board
│   
│
└── README.md
```

---

## 🛠 Toolchain Setup (Linux)

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

## 🧰 Toolchain Usage (from Root)

You can simply use the provided script:

### ✅ 1. Build the Program
From the root of the project, run:
```bash
./build.sh
```

This script will:

- Compile your C and assembly source files using **riscv-none-elf-gcc**
- Convert the output to a flat binary
- Generate a .mem file
- Format it into a VHDL-friendly ROM initialization file and replace the contents of rom.vhd

---

## Python Requirements

- Python 3.x
- No external libraries required

---

## Target Hardware

- Digilent **Basys3 FPGA Board** or an FPGA Board of your choice
- 100 MHz clock (you may need a clock divider)
- 4K RAM, 4K ROM (configurable via linker script)

---

