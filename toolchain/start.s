.section .text
.global _start
_start:
    la sp, _stack_top      # Initialize stack pointer
    call main              # Call main()
1:  j 1b                   # Infinite loop (if main returns)

