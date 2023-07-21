
#once

MODE_ALU = 0x00`2
MODE_MEM = 0x01`2
MODE_BRANCH = 0x02`2
MODE_MISC = 0x03`2

CCC = 0`3
CCZ = 1`3
CCN = 2`3
CCV = 3`3
CCI = 7`3


SP = 0x01
FLAGS = 0x02
PORTA = 0x03
PORTB = 0x04
PINA = 0x05
PINB = 0x06


SRAM_BASE = 0x20

#ruledef cc {
    c => 1`1 @ CCC
    z => 1`1 @ CCZ
    n => 1`1 @ CCN
    v => 1`1 @ CCV
    i => 1`1 @ CCI
    nc => 0`1 @ CCC
    nz => 0`1 @ CCZ
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
    nop => asm { mov r0, r0 }
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
    and {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 8`4 @ 0`1 @ r`4 @ d`4)
    xor {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 9`4 @ 0`1 @ r`4 @ d`4)
    lea [{d: register} + {r:register}*2] => le(MODE_ALU @ 0`1 @ 10`4 @ 0`1 @ r`4 @ d`4)
    lea [{d: register} + {r:register}*4] => le(MODE_ALU @ 0`1 @ 11`4 @ 0`1 @ r`4 @ d`4)
    lea [{d: register} + {r:register}*8] => le(MODE_ALU @ 0`1 @ 12`4 @ 0`1 @ r`4 @ d`4)
    div {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 13`4 @ 0`1 @ r`4 @ d`4)
    idiv {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 13`4 @ 1`1 @ r`4 @ d`4)
    divrem {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 14`4 @ 0`1 @ r`4 @ d`4)
    idivrem {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 14`4 @ 1`1 @ r`4 @ d`4)
    cmp {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 15`4 @ 0`1 @ r`4 @ d`4)

    ld {d: register} <- {a: register} =>  le(MODE_MEM @ 0`1 @ 0`1 @ 0`3 @ 0`1 @ a`4 @ d`4 )
    st {d: register} -> {a: register} =>  le(MODE_MEM @ 0`1 @ 0`1 @ 0`3 @ 1`1 @ a`4 @ d`4 )
    ld {d: register} <- [{a: u16}] => le(MODE_MEM @ 0`1 @ 1`1 @ 0`3 @ 0`1 @ 0`4 @ d`4 ) @ le(a)
    st {d: register} -> [{a: u16}] => le(MODE_MEM @ 0`1 @ 1`1 @ 0`3 @ 1`1 @ 0`4 @ d`4) @ le(a)

    ldi {d:register}, {i: i16} => le(MODE_MEM @ 0`1 @ 1`1 @ 6`3 @ 0`1 @ 0`4 @ d`4) @ le(i)

    jmp {a: u16} => le(MODE_BRANCH @ 0x00`14) @ le((a/2)`16)
    j {c: cc} {a: u16} => le(MODE_BRANCH @ 0`1 @ 0`4 @ 1`1 @ c`4 @ 0`4) @ le((a/2)`16)
    jmp {r: register} => le(MODE_BRANCH @ 0`1 @ 1`4 @ 0`1 @ 0`1 @ 0`3 @ r`4)
    j {c: cc} {r: register} => le(MODE_BRANCH @ 0`1 @ 1`4 @ 1`1 @ c`4 @ r`4 )

    push {r: register} => le(MODE_MEM @ 0`1 @ 0`1 @ 4`3 @ 1`1 @ 0`4 @ r`4)
    ; push {i: i16} => le(MODE_MEM @ 0`1 @ 1`1 @ 4`3 @ 1`1 @ 0`4 @ 0`4) @ le(i)

    pop {d: register} => le(MODE_MEM @ 0`1 @ 0`1 @ 4`3 @ 0`1 @ 0`4 @ d`4) 

}



#ruledef {

    hlt => asm { jmp $ }
    ld {d: register} <- SRAM [{a: u16}] => asm { ld {d} <- [{a} + SRAM_BASE] }
    st {d: register} -> SRAM [{a: u16}] => asm { st {d} -> [{a} + SRAM_BASE] }

    call {i: u16} => 
        asm { 
            ldi r15, paddr($)+5
            push r15
            jmp {i}
        }

    ret => 
        asm {
            pop r15
            jmp r15
        }

}


#fn paddr(bytes) => (bytes / 2)



__start:
    ldi r15, 0xffff
    st r15 -> [SP]
    call main
    hlt