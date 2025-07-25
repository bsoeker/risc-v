rom_vhd_path = "src/rom.vhd"
rom_init_path = "build/rom_init.txt"

# Load replacement ROM data
with open(rom_init_path, "r") as f:
    rom_lines = [line.strip() for line in f if "=>" in line]

# Read rom.vhd lines
with open(rom_vhd_path, "r") as f:
    lines = f.readlines()

updated_lines = []
inside_rom_array = False

for line in lines:
    if not inside_rom_array:
        updated_lines.append(line)
        if ":= (" in line:
            inside_rom_array = True
    else:
        if ")" in line:
            # Insert the rom_init content before the closing )
            for l in rom_lines:
                updated_lines.append("    " + l + "\n")
            updated_lines.append(");\n")
            inside_rom_array = False
        # skip all lines inside the rom_array block

# Write back
with open(rom_vhd_path, "w") as f:
    f.writelines(updated_lines)

print("ROM updated successfully.")

