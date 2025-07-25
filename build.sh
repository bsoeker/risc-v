#!/bin/bash

set -e  # Exit on error

# === Config ===
ELF=build/main.elf
BIN=build/main.bin
DUMP=build/dump.txt

# === Compilation ===
echo "[1/6] Compiling main.c and start.s..."
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 \
  -T toolchain/linker.ld -nostartfiles -ffreestanding \
  -o "$ELF" toolchain/start.s toolchain/main.c

# === ELF to Binary ===
echo "[2/6] Generating binary..."
riscv-none-elf-objcopy -O binary "$ELF" "$BIN"

# === Dump disassembly ===
echo "[3/6] Generating dump..."
riscv-none-elf-objdump -d "$ELF" > "$DUMP"

# === Convert binary to hex/byte rows for ROM init ===
echo "[4/6] Converting binary..."
python3 toolchain/convert.py

# === Fill ROM with padded values or formatted lines ===
echo "[5/6] Filling ROM..."
python3 toolchain/fill_rom.py
python3 toolchain/update_rom.py

echo "✅ Build completed!"

