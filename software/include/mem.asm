#once 
#include "arch.asm"
#bank pflash


p2s_memcpy: ; void p2s_memcpy(void* paddr, void* saddr, size_t size)
    push r5

.loop:
        elpm r5, r0
        st r5 -> r1
        inc r1
        inc r0
        dec r2
        j nz .loop

    pop r5
    ret


memcpy: ; void memcpy(void* dest, const void* src, size_t size)
    push r3
.loop:
        ld r3 <- r1
        st r3 -> r0
        inc r0
        inc r1
        dec r2
        j nz .loop

    pop r3
    ret