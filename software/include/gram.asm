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


