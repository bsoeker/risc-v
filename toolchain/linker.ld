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

    .data : {
        *(.data*)
    } > RAM

    .bss : {
        *(.bss*)
        *(COMMON)
    } > RAM

    . = ORIGIN(RAM) + LENGTH(RAM);
    _stack_top = .;
}

