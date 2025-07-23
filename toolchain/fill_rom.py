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
        output.append(f'    {addr} => x"{line.upper()}",')
        addr += 1  # increment by word size

    output.append('    others => x"00000000"')

    with open(output_path, 'w') as f_out:
        f_out.write('\n'.join(output))

    print(f"✅ VHDL ROM array data saved to: {output_path}")

# Example usage
format_rom_vhdl("build/rom.mem")

