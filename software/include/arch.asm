; #ifndef __ARCH
; #define __ARCH
#once

IOMEM_BASE = 0x00
IOMEM_SIZE = 0x20
SRAM_BASE = 0x20
GRAM_WIDTH = 160
GRAM_HEIGHT = 120
GRAM_SIZE = (GRAM_WIDTH * GRAM_HEIGHT * 2)
SRAM_SIZE = (0xffff-IOMEM_SIZE-GRAM_SIZE)
GRAM_BEGIN = (SRAM_BASE + SRAM_SIZE)

PFLASH_SIZE = 0xffff
VECTORS_SIZE = 64
BOOT_SIZE = 0x100
PBOOT_SIZE = (VECTORS_SIZE + BOOT_SIZE)

#bankdef boot {
    #bits 16
    #addr 0x0000
    #addr_end PBOOT_SIZE
    #outp 0x0000
    #fill
}

#bankdef pflash {
    #bits 16
    #addr PBOOT_SIZE
    #addr_end 0xffff
    #outp 16*PBOOT_SIZE
}

#bankdef sram {
    #addr SRAM_BASE
    #size SRAM_SIZE
    #bits 16
}

#bankdef gram {
    #addr GRAM_BEGIN
    #addr_end 0xffff
    #bits 16
}

#bank gram
__gram_begin:
__gram_buf0_begin:
#res (GRAM_WIDTH*GRAM_HEIGHT)
__gram_buf0_end:
__gram_buf1_begin:
#res (GRAM_WIDTH*GRAM_HEIGHT)
__gram_buf1_end:
__gram_end:

#bank sram
__GIT_begin:
__int_pina_vect:
#res 1
__int_pinb_vect:
#res 1
__int_t0ovf_vect:
#res 1
__int_t0oca_vect:
#res 1
__int_t0ocb_vect:
#res 1
__GIT_end:
#bank pflash


#fn paddr(bytes) => (bytes)





SP = 0x01
FLAGS = 0x02

RAND = 0xa
WRITER = 0xc
READER = 0xd
PCAMSK = 0x1b
PCBMSK = 0x1c
GIMSK = 0x1d
IRETA = 0x1e
INTNO = 0x1f



MODE_ALU = 0x00`2
MODE_MEM = 0x01`2
MODE_BRANCH = 0x02`2
MODE_MISC = 0x03`2

CCC = 0`3
CCZ = 1`3
CCN = 2`3
CCV = 3`3
CCI = 7`3
#ruledef cc {
    c => 1`1 @ CCC
    z => 1`1 @ CCZ
    e => 1`1 @ CCZ
    n => 1`1 @ CCN
    v => 1`1 @ CCV
    i => 1`1 @ CCI
    nc => 0`1 @ CCC
    nz => 0`1 @ CCZ
    ne => 0`1 @ CCZ
    nn => 0`1 @ CCN
    nv => 0`1 @ CCV
    ni => 0`1 @ CCI
}

#ruledef register 
{
    r0 => 0
    r1 => 1
    r2 => 2
    r3 => 3
    r4 => 4
    r5 => 5
    r6 => 6
    r7 => 7
    r8 => 8
    r9 => 9
    r10 => 10
    r11 => 11
    r12 => 12
    r13 => 13
    r14 => 14
    r15 => 15
}



#ruledef
{
    nop => asm { 0`16 | (MODE_MISC << 14) }
    mov {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 0`4 @ 0`1 @ r`4 @ d`4)
    add {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 1`4 @ 0`1 @ r`4 @ d`4)
    adc {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 1`4 @ 1`1 @ r`4 @ d`4)
    sub {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 2`4 @ 0`1 @ r`4 @ d`4)
    sbc {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 2`4 @ 1`1 @ r`4 @ d`4)
    mul {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 3`4 @ 0`1 @ r`4 @ d`4)
    imul {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 3`4 @ 1`1 @ r`4 @ d`4)
    lsh {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 4`4 @ 0`1 @ r`4 @ d`4)
    rol {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 4`4 @ 1`1 @ r`4 @ d`4)
    rsh {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 5`4 @ 0`1 @ r`4 @ d`4)
    ror {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 5`4 @ 1`1 @ r`4 @ d`4)
    not {d: register}               => le(MODE_ALU  @ 0`1 @ 6`4 @ 0`1 @ 0`4 @ d`4)
    or {d: register}, {r: register} => le(MODE_ALU  @ 0`1 @ 7`4 @ 0`1 @ r`4 @ d`4) 
    xor {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 8`4 @ 0`1 @ r`4 @ d`4)
    and {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 9`4 @ 0`1 @ r`4 @ d`4)
    lea [{d: register} + {r:register}*2] => le(MODE_ALU @ 0`1 @ 10`4 @ 0`1 @ r`4 @ d`4)
    lea [{d: register} + {r:register}*4] => le(MODE_ALU @ 0`1 @ 11`4 @ 0`1 @ r`4 @ d`4)
    lea [{d: register} + {r:register}*8] => le(MODE_ALU @ 0`1 @ 12`4 @ 0`1 @ r`4 @ d`4)
    div {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 13`4 @ 0`1 @ r`4 @ d`4)
    idiv {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 13`4 @ 1`1 @ r`4 @ d`4)
    divrem {d: register}, {r: register} => le(MODE_ALU @ 1`1 @ 13`4 @ 0`1 @ r`4 @ d`4)
    idivrem {d: register}, {r: register} => le(MODE_ALU @ 1`1 @ 13`4 @ 1`1 @ r`4 @ d`4)
    inc {d: register} => le(MODE_ALU @ 0`1 @ 14`4 @ 0`1 @ 0`4 @ d`4)
    dec {d: register} => le(MODE_ALU @ 0`1 @ 14`4 @ 1`1 @ 0`4 @ d`4)
    cmp {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 15`4 @ 0`1 @ r`4 @ d`4)

    ld {d: register} <- {a: register} =>  le(MODE_MEM @ 0`1 @ 0`1 @ 0`3 @ 0`1 @ a`4 @ d`4 )
    st {d: register} -> {a: register} =>  le(MODE_MEM @ 0`1 @ 0`1 @ 0`3 @ 1`1 @ a`4 @ d`4 )
    ld {d: register} <- [{a: u16}] => le(MODE_MEM @ 0`1 @ 1`1 @ 0`3 @ 0`1 @ 0`4 @ d`4 ) @ le(a)
    st {d: register} -> [{a: u16}] => le(MODE_MEM @ 0`1 @ 1`1 @ 0`3 @ 1`1 @ 0`4 @ d`4) @ le(a)

    write {r: register} => le(MODE_MEM @ 0`1 @ 0`1 @ 5`3 @ 1`1 @ 0`4 @ r`4)
    read {d: register} => le(MODE_MEM @ 0`1 @ 0`1 @ 5`3 @ 0`1 @ 0`4 @ d`4)

    ldi {d:register}, {i: i16} => le(MODE_MEM @ 0`1 @ 1`1 @ 6`3 @ 0`1 @ 0`4 @ d`4) @ le(i)
    elpm {d: register}, {a: register} => le(MODE_MEM @ 0`1 @ 1`1 @ 7`3 @ 0`1 @ a`4 @ d`4) @ le(0`16)

    jmp {a: u16} => le(MODE_BRANCH @ 0x00`14) @ le(paddr(a)`16)
    j {c: cc} {a: u16} => le(MODE_BRANCH @ 0`1 @ 0`4 @ 1`1 @ c`4 @ 0`4) @ le(paddr(a)`16)
    jmp {r: register} => le(MODE_BRANCH @ 0`1 @ 1`4 @ 0`1 @ 0`1 @ 0`3 @ r`4)
    j {c: cc} {r: register} => le(MODE_BRANCH @ 0`1 @ 1`4 @ 1`1 @ c`4 @ r`4 )

    push {r: register} => le(MODE_MEM @ 0`1 @ 0`1 @ 4`3 @ 1`1 @ 0`4 @ r`4)
    ; push {i: i16} => le(MODE_MEM @ 0`1 @ 1`1 @ 4`3 @ 1`1 @ 0`4 @ 0`4) @ le(i)

    pop {d: register} => le(MODE_MEM @ 0`1 @ 0`1 @ 4`3 @ 0`1 @ 0`4 @ d`4) 

}



#ruledef {

    hlt => { 
        hlt_addr = $ 
        asm { jmp {hlt_addr} }
    }
    ld {d: register} <- SRAM [{a: u16}] => asm { ld {d} <- [{a} + SRAM_BASE] }
    st {d: register} -> SRAM [{a: u16}] => asm { st {d} -> [{a} + SRAM_BASE] }

    zero {d: register} => asm { xor {d}, {d} }

    call {i: u16} => {
        retaddr = paddr($)+5
        asm { 
            ldi r15, {retaddr}
            push r15
            jmp {i}
        }
    }

    call {r: register} => {
        retaddr = paddr($)+5
        asm {
            ldi r15, {retaddr}
            push r15
            jmp {r}
        }
    }
        

    ret => 
        asm {
            pop r15
            jmp r15
        }

    

}




#bank pflash
__prog_begin:
#bank boot
jmp __start
__interrupt_dispatch:
    push r0     ; allocate return address
    push r15
    push r14
    push r13

    ; fill return address
    ldi r14, 5
    ld r13 <- [SP]
    sub r13, r14    ; r13 = &(SP-5)
    ld r14 <- [IRETA]
    st r14 -> r13   ; *(&(SP-5)) = IRETA
    
    
    ; jump to interrupt
    ld r14 <- [INTNO]
    ldi r13, __GIT_begin
    add r13, r14
    ld r14 <- r13
    call r14

    pop r13
    pop r14
    pop r15

    ret ; to return address added above

__start:
    ; setup stack
    ldi r15, 0xffff
    st r15 -> [SP]
    ; call with __stop as return address
    ldi r15, paddr(__stop)
    push r15
    jmp main
__stop:
    jmp __stop



; #endif