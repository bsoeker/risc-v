## Open Source Toolchain Commands

### Synthesize
For VHDL:

```bash
yosys -m ghdl -p "ghdl $(echo user_design/*.vhdl) -e sequential_16bit_en; read_verilog user_design/top_wrapper.v; synth_fabulous -top top_wrapper -json out.json"
```

### PNR
FAB_ROOT actually refers to the project root and not the FABulous repo.

```bash
FAB_ROOT=$(pwd) nextpnr-generic --uarch fabulous --json out.json -o fasm=out.fasm
```

### Bitstream generation
From the project root:

```bash
FABulous .
```

And once inside the FABulous shell:

```FABulous>
gen_bitStream_spec
gen_bitStream_bin <your fasm>.fasm
```

### Conversion of VHDL to Verilog (if needed)
```bash
yosys -m ghdl -p "ghdl --std=08 $(echo src/*.vhd) -e top; write_verilog top_level.v"
```
