#include "arch.asm"


myTestFunction:
    add r0, r1
    ret


main:
    ldi r0, 10
    st r0 -> [PORTA]
    
    
    
    ldi r1, 1
    ldi r2, 5

    .lp:
        call myTestFunction
        st r0 -> [PORTA]
        sub r2, r1
        j nz .lp

    hlt