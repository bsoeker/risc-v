import os
os.makedirs("build", exist_ok=True)

def format_rom_vhdl(mem_file_path, output_path="build/rom_init.txt", addr_offset=0):
    with open(mem_file_path, 'r') as f:
        lines = f.readlines()

    output = []
    addr = addr_offset

    for line in lines:
        line = line.strip()
        if not line:
            continue
        word = int(line, 16)
        bytes_le = [
            (word >> (8 * i)) & 0xFF for i in range(4)
        ]  # Little-endian

        for b in bytes_le:
            output.append(f'    {addr} => x"{b:02X}",')
            addr += 1

    output.append('    others => x"00"')

    with open(output_path, 'w') as f_out:
        f_out.write('\n'.join(output))

    print(f"✅ VHDL ROM array data saved to: {output_path}")

# Example usage
format_rom_vhdl("build/rom.mem")

