#include "arch.asm"



main:
    ; initial constants
    ldi r0, 1
    ldi r1, 1
    ; main loop
.loop:
    ; sequence ...
    mov r2, r1
    add r2, r0
    ; check for carry, if so exit (found 16-bit max)
    j c .found_max
    ; setup for next sequence ...
    mov r0, r1
    mov r1, r2
    ; output
    st r2 -> [PORTA]
    ; repeat
    jmp .loop
.found_max:
    hlt