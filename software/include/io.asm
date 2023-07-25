#once
#include "arch.asm"
#bank pflash


#fn sbmsk(bit) => (1 << bit)
#fn cbmsk(bit) => (!(1 << bit))



PORTA = 0x03
PORTB = 0x04
PINA = 0x05
PINB = 0x06
TTX = 0x07
TRX = 0x08
PULSE = 0x09







putchar:    ; void putchar(char16 c)
    st r0 -> [TTX]
    ldi r0, sbmsk(0)
    st r0 -> [PULSE]
    ret

put_ps:     ; void put_ps(void* paddr)
    push r2
    push r3

    mov r2, r0
.loop:
        elpm r3, r2
        and r3, r3
        j z .end_loop
        inc r2
        mov r0, r3
        call putchar
        jmp .loop
.end_loop:

    pop r3
    pop r2
    ret

puts: ; void puts(void* saddr)
    push r1

    mov r1, r0
    
.loop:
        ld r0 <- r1
        and r0, r0
        j z .end_loop
        call putchar
        inc r1
        jmp .loop 
.end_loop:

    pop r1
    ret
