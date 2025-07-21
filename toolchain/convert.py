import os
os.makedirs("build", exist_ok=True)

with open("build/main.bin", "rb") as f:
    binary = f.read()

rom_bytes = [f"{b:02x}" for b in binary]

with open("build/rom.mem", "w") as f:
    for i in range(0, len(rom_bytes), 4):
        word = rom_bytes[i:i+4]
        word = word + ['00'] * (4 - len(word))  # pad last word if needed
        f.write("".join(reversed(word)) + "\n")  # Little endian!

