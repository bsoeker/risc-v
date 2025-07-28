ENTRY(_start)

MEMORY {
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
    RAM (rw)  : ORIGIN = 0x10000000, LENGTH = 4K
}

SECTIONS {
    .text : {
        *(.text*)
    } > ROM

    .rodata : {
        *(.rodata*)
    } > ROM

    .data : {
      _sdata = .;
      *(.data*)
      *(.sdata*)
      _edata = .;
    } > RAM AT > ROM
    _sidata = LOADADDR(.data);


    .bss : {
        _sbss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > RAM

    . = ORIGIN(RAM) + LENGTH(RAM);
    _stack_top = .;
}

