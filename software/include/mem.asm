#once 
#include "arch.asm"
#bank pflash


p2s_memcpy: ; void p2s_memcpy(void* paddr, void* saddr, size_t size)
    push r5
    st r1 -> [WRITER]
.loop:
        elpm r5, r0
        write r5
        inc r0
        dec r2
        j nz .loop

    pop r5
    ret


memcpy: ; void memcpy(void* dest, const void* src, size_t size)
    push r3
    st r0 -> [WRITER]
    st r1 -> [READER]
.loop:
        read r3
        write r3
        dec r2
        j nz .loop

    pop r3
    ret

memset: ; void memset(void* dest, int value, size_t size)
    st r0 -> [WRITER]
    .loop:
        write r1
        dec r2
        j nz .loop
    ret