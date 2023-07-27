#include "include/arch.asm"
#include "include/io.asm"
#include "include/mem.asm"



__test:
    #d utf16le("Hello World!\0")
__test_end:

#bank sram
__test_sram:
#res (__test_end-__test)
__test_sram_end:
__test_memcpy_sram:
#res (__test_end-__test)
__test_memcpy_sram_end:

#bank pflash





main:


    ldi r0, 1
    st r0 -> [GIMSK]

    ldi r0, __test
    ldi r1, __test_sram
    ldi r2, __test_end - __test

    call p2s_memcpy

    ldi r0, __test_memcpy_sram
    ldi r1, __test_sram
    ldi r2, __test_end - __test

    call memcpy

    ldi r0, __test_memcpy_sram
    call puts

    ret