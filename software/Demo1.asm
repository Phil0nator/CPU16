#include "include/arch.asm"
#include "include/io.asm"
#include "include/mem.asm"


; Store the UTF-16, null-terminated string "Hello World!" in program memory
; using __test to mark the starting address.
__test:
    #d utf16le("Hello World!\0")
__test_end:

; Switch address space to data memory SRAM
#bank sram
; reserve space to copy Hello World
__test_sram:
#res (__test_end-__test)
__test_sram_end:
; reserve space to copy Hello World again
__test_memcpy_sram:
#res (__test_end-__test)
__test_memcpy_sram_end:

; Switch address space back to program memory
#bank pflash





main:

    ; load parameters for p2s_memcpy to copy Hello World
    ; into the space reserved at __test_sram
    ldi r0, __test
    ldi r1, __test_sram
    ldi r2, __test_end - __test

    call p2s_memcpy

    ; load parameters for memcpy to copy Hello World
    ; from the first reserved buffer to __test_memcpy_sram
    ldi r0, __test_memcpy_sram
    ldi r1, __test_sram
    ldi r2, __test_end - __test

    call memcpy

    ; load call puts on the finally copied value to print it to the terminal
    ldi r0, __test_memcpy_sram
    call puts

    ret