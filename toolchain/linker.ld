ENTRY(_start)

MEMORY {
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 1K
    RAM (rw)  : ORIGIN = 0x10000000, LENGTH = 4K
}

SECTIONS {
    .text : {
        *(.text*)
    } > ROM

    .rodata : {
        *(.rodata*)
    } > ROM

    .data : AT(ADDR(.text) + SIZEOF(.text)) {
        _sdata = .;
        *(.data*)
        *(.sdata*)
        _edata = .;
    } > RAM
    _sidata = LOADADDR(.data);



    .bss : {
        _sbss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > RAM

    _sidata = LOADADDR(.data);

    . = ORIGIN(RAM) + LENGTH(RAM);
    _stack_top = .;
}

