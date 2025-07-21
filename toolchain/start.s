.section .text
.global _start
_start:
    la sp, _stack_top

    # Copy .data from ROM to RAM
    la a0, _sidata     # ROM start of init values
    la a1, _sdata      # RAM start of .data
    la a2, _edata      # RAM end of .data
1:
    beq a1, a2, 2f
    lw t0, 0(a0)
    sw t0, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    j 1b
2:

    # Zero .bss section
    la a0, _sbss
    la a1, _ebss
3:
    beq a0, a1, 4f
    sw zero, 0(a0)
    addi a0, a0, 4
    j 3b
4:

    call main
5:  j 5b

