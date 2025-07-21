# RISC-V RV32I Softcore CPU (Basys3) 🚀

This project contains a complete softcore CPU implementing the **RV32I** RISC-V instruction set, written in **VHDL** and designed to run on the **Basys3 FPGA board**. It also includes a minimal **bare-metal toolchain** to compile and load C programs onto the softcore via ROM.

---

## 🧠 What’s Inside?

- 🧬 **VHDL implementation** of a single-cycle RV32I CPU
- 🧰 **Bare-metal C toolchain** for compiling programs
- 📦 Ready for simulation & deployment on **Basys3**
- 🧠 Educational, simple, and modifiable — ideal for learning how CPUs work from the ground up

---

## 📁 Folder Structure

```
project-root/
│
├── toolchain/
│   ├── main.c           # Bare-metal test code
│   ├── start.s          # Startup assembly
│   ├── linker.ld        # Custom linker script
│   ├── convert.py       # ELF -> .mem
│   └── fill_rom.py      # .mem -> VHDL ROM init
│
├── build/
│   ├── main.elf
│   ├── main.bin
│   ├── rom.mem
│   └── rom_init.txt
│
├── src/
│   └── rom.vhd          # VHDL ROM module to be initialized
│   └── <...other VHDL components...>
│
├── constraints/
│   └── basys3.xdc       # Pin mappings for Basys3
│
└── README.md
```

---

## 🧪 Toolchain Usage (from root)

### 1. Compile Program
```bash
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 \
  -T toolchain/linker.ld -nostartfiles -ffreestanding \
  -o build/main.elf toolchain/start.s toolchain/main.c
```

### 2. Convert to Flat Binary
```bash
riscv-none-elf-objcopy -O binary build/main.elf build/main.bin
```

### 3. Convert to .mem Format
```bash
python3 toolchain/convert.py
```

### 4. Generate VHDL-Friendly ROM Init
```bash
python3 toolchain/fill_rom.py
```

---

## 💾 Load Program into CPU

After generating `build/rom_init.txt`, **manually copy-paste its contents** into the ROM memory array section in:

```
src/rom.vhd
```

Then re-synthesize the project in Vivado and program your Basys3 board.

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

## 🐍 Python Requirements

- Python 3.x
- No external libraries required

---

## 📡 Target Hardware

- ✅ Digilent **Basys3 FPGA Board**
- ✅ 100 MHz clock (you may need a clock divider)
- ✅ 4K RAM, 1K ROM (configurable via linker script)

---

