; #ifndef __GRAM
; #define __GRAM
#once
#include "arch.asm"

BUFSEL0 = 0
BUFSEL1 = 1

GRAM_FLIP = 0xB

WHITE = 0
BLACK = 1
RED = 2 
GREEN = 3
BLUE = 4
YELLOW = 5
CYAN = 6
MAGENTA = 7
ORANGE = 8
PINK = 9

#fn rgb(r,g,b) => ( (1`1 @ r`5 @ g`5 @ b`5) )

#bank sram



#bank pflash

gram_flip:  ; gram_addr* gram_flip()
    ld r14 <- [GRAM_FLIP]
    not r14
    st r14 -> [GRAM_FLIP]
    and r14, r14
    j z .return_0
    .return_1:
    ldi r0, __gram_buf1_begin
    ret
    .return_0:
    ldi r0, __gram_buf0_begin
    ret


gram_blit_p: ; void gram_blit_p(void* paddr, void* gram_addr, int height, int width)

    ldi r14, GRAM_WIDTH
    
    ; for (; height; height --) {
    ;   push gram_addr
    ;   for (; width; width --)
    ;       *gram_addr++ = *paddr++
    ;   pop gram_addr
    ;   gram_addr += GRAM_WIDTH
    ; }
    push r3
    .lpw:
        pop r3
        push r3
        push r1
        .lph:
            elpm r13, r0
            inc r0
            st r13 -> r1
            inc r1

            dec r3
            j nz .lph
        pop r1
        add r1, r14
        dec r2
        j nz .lpw

    pop r3
    ret


; #endif