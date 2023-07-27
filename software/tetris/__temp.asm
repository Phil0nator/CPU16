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
    not {d: register} => le(MODE_ALU @ 0`1 @ 6`4 @ 0`1 @ 0`4 @ d`4)
    or {d: register}, {r: register} => le(MODE_ALU @ 0`1 @ 7`4 @ 0`1 @ r`4 @ d`4)
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
    ld {d: register} <- {a: register} => le(MODE_MEM @ 0`1 @ 0`1 @ 0`3 @ 0`1 @ a`4 @ d`4 )
    st {d: register} -> {a: register} => le(MODE_MEM @ 0`1 @ 0`1 @ 0`3 @ 1`1 @ a`4 @ d`4 )
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
    push r0 ; allocate return address
    push r15
    push r14
    push r13
    ; fill return address
    ldi r14, 5
    ld r13 <- [SP]
    sub r13, r14 ; r13 = &(SP-5)
    ld r14 <- [IRETA]
    st r14 -> r13 ; *(&(SP-5)) = IRETA
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
#once
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
putchar: ; void putchar(char16 c)
    st r0 -> [TTX]
    ldi r0, sbmsk(0)
    st r0 -> [PULSE]
    ret
put_ps: ; void put_ps(void* paddr)
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
#once
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
#once
#ruledef {
    mov {d: register}, {q: i16} => asm {
        ldi {d}, {q}
    }
    mov {d: register}, [{a: u16}] => asm {
        ld d <- [{a}]
    }
    call {fn: u16} ({a}) => {
        asm {
            mov r0, {a}
            call {fn}
        }
    }
    call {fn: u16} ({a}, {b}) => {
        asm {
            mov r0, {a}
            mov r1, {b}
            call {fn}
        }
    }
    call {fn: u16} ({a}, {b}, {c}) => {
        asm {
            mov r0, {a}
            mov r1, {b}
            mov r2, {c}
            call {fn}
        }
    }
}
#fn call3(fn, arg0, arg1, arg2) => {
    asm { mov r0, arg0
    mov r1, arg1
    mov r2, arg2
    call fn }
}
#once
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
gram_flip: ; gram_addr* gram_flip()
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
GRID_WIDTH = 12
GRID_HEIGHT = 22
GRID_SCALE = 4
#bank sram
grid:
#res (GRID_WIDTH*GRID_HEIGHT)
grid_end:
#res 1
cur_gbuf_addr:
#res 1
#res 20 ; padding (shrug)
cur_piece_x:
#res 1
cur_piece_y:
#res 1
cur_piece_rotnum:
#res 1
cur_piece_addr:
#res 1
cur_piece_gridaddr:
#res 1
#once
#bank pflash
#const(noemit) blk = le(0x03`16)
#const(noemit) ___ = le(0x00`16)
PIECE_SIZE = 9
PIECE_TOTAL_SIZE = 4*PIECE_SIZE
piece0_0:
#d16 le(___), le(___), le(blk)
#d16 le(___), le(___), le(blk)
#d16 le(___), le(___), le(blk)
piece0_1:
#d16 le(___), le(___), le(___)
#d16 le(blk), le(blk), le(blk)
#d16 le(___), le(___), le(___)
piece0_2:
#d16 le(___), le(___), le(blk)
#d16 le(___), le(___), le(blk)
#d16 le(___), le(___), le(blk)
piece0_3:
#d16 le(___), le(___), le(___)
#d16 le(blk), le(blk), le(blk)
#d16 le(___), le(___), le(___)
piece1_0:
#d16 le(___), le(___), le(___)
#d16 le(blk), le(blk), le(blk)
#d16 le(___), le(___), le(blk)
piece1_1:
#d16 le(___), le(___), le(blk)
#d16 le(___), le(___), le(blk)
#d16 le(___), le(blk), le(blk)
piece1_2:
#d16 le(blk), le(___), le(___)
#d16 le(blk), le(blk), le(blk)
#d16 le(___), le(___), le(___)
piece1_3:
#d16 le(___), le(blk), le(blk)
#d16 le(___), le(blk), le(___)
#d16 le(___), le(blk), le(___)
piece2_0:
#d16 le(___), le(___), le(___)
#d16 le(blk), le(blk), le(blk)
#d16 le(blk), le(___), le(___)
piece2_1:
#d16 le(___), le(blk), le(blk)
#d16 le(___), le(___), le(blk)
#d16 le(___), le(___), le(blk)
piece2_2:
#d16 le(___), le(___), le(blk)
#d16 le(blk), le(blk), le(blk)
#d16 le(___), le(___), le(___)
piece2_3:
#d16 le(___), le(blk), le(___)
#d16 le(___), le(blk), le(___)
#d16 le(___), le(blk), le(blk)
piece3_0:
#d16 le(___), le(___), le(___)
#d16 le(___), le(blk), le(blk)
#d16 le(blk), le(blk), le(___)
piece3_1:
#d16 le(___), le(blk), le(___)
#d16 le(___), le(blk), le(blk)
#d16 le(___), le(___), le(blk)
piece3_2:
#d16 le(___), le(___), le(___)
#d16 le(___), le(blk), le(blk)
#d16 le(blk), le(blk), le(___)
piece3_3:
#d16 le(___), le(blk), le(___)
#d16 le(___), le(blk), le(blk)
#d16 le(___), le(___), le(blk)
piece4_0:
#d16 le(___), le(___), le(___)
#d16 le(blk), le(blk), le(___)
#d16 le(___), le(blk), le(blk)
piece4_1:
#d16 le(___), le(___), le(blk)
#d16 le(___), le(blk), le(blk)
#d16 le(___), le(blk), le(___)
piece4_2:
#d16 le(___), le(___), le(___)
#d16 le(blk), le(blk), le(___)
#d16 le(___), le(blk), le(blk)
piece4_3:
#d16 le(___), le(___), le(blk)
#d16 le(___), le(blk), le(blk)
#d16 le(___), le(blk), le(___)
piece5_0:
#d16 le(___), le(___), le(___)
#d16 le(blk), le(blk), le(blk)
#d16 le(___), le(blk), le(___)
piece5_1:
#d16 le(___), le(___), le(blk)
#d16 le(___), le(blk), le(blk)
#d16 le(___), le(___), le(blk)
piece5_2:
#d16 le(___), le(blk), le(___)
#d16 le(blk), le(blk), le(blk)
#d16 le(___), le(___), le(___)
piece5_3:
#d16 le(___), le(blk), le(___)
#d16 le(___), le(blk), le(blk)
#d16 le(___), le(blk), le(___)
pieces_map:
#d16 le(piece0_0`16)
#d16 le(piece1_0`16)
#d16 le(piece2_0`16)
#d16 le(piece3_0`16)
#d16 le(piece4_0`16)
#d16 le(piece5_0`16)
clear_piece: ; void clear_piece (grid_addr)
    xor r14, r14
    ldi r13, 10 ; add 10 to skip to next line
    st r14 -> r0
    inc r0
    st r14 -> r0
    inc r0
    st r14 -> r0
    add r0, r13
    st r14 -> r0
    inc r0
    st r14 -> r0
    inc r0
    st r14 -> r0
    add r0, r13
    st r14 -> r0
    inc r0
    st r14 -> r0
    inc r0
    st r14 -> r0
    ret
place_piece: ; void place_piece( piece_addr, grid_addr)
    ldi r13, 10 ; add 10 to skip to next line
    ; write one row
    elpm r14, r0
    st r14 -> r1
    inc r0
    inc r1
    elpm r14, r0
    st r14 -> r1
    inc r0
    inc r1
    elpm r14, r0
    st r14 -> r1
    inc r0
    add r1, r13
    ; write one row
    elpm r14, r0
    st r14 -> r1
    inc r0
    inc r1
    elpm r14, r0
    st r14 -> r1
    inc r0
    inc r1
    elpm r14, r0
    st r14 -> r1
    inc r0
    add r1, r13
    ; write one row
    elpm r14, r0
    st r14 -> r1
    inc r0
    inc r1
    elpm r14, r0
    st r14 -> r1
    inc r0
    inc r1
    elpm r14, r0
    st r14 -> r1
    ret
solidify_piece: ; void solidify_piece(grid_addr)
    ldi r13, 10 ; add 10 to skip to next line
    ldi r12, BLOCK_ACTIVE
    ldi r11, BLOCK_PLACED
    ld r14 <- r0
    sub r14, r12
    j nz .next00
    st r11 -> r0
    .next00:
    inc r0
    ld r14 <- r0
    sub r14, r12
    j nz .next10
    st r11 -> r0
    .next10:
    inc r0
    ld r14 <- r0
    sub r14, r12
    j nz .next20
    st r11 -> r0
    .next20:
    add r0, r13
    ld r14 <- r0
    sub r14, r12
    j nz .next01
    st r11 -> r0
    .next01:
    inc r0
    ld r14 <- r0
    sub r14, r12
    j nz .next11
    st r11 -> r0
    .next11:
    inc r0
    ld r14 <- r0
    sub r14, r12
    j nz .next21
    st r11 -> r0
    .next21:
    add r0, r13
    ld r14 <- r0
    sub r14, r12
    j nz .next02
    st r11 -> r0
    .next02:
    inc r0
    ld r14 <- r0
    sub r14, r12
    j nz .next12
    st r11 -> r0
    .next12:
    inc r0
    ld r14 <- r0
    sub r14, r12
    j nz .next22
    st r11 -> r0
    .next22:
    ret
#bank pflash
block_color_map:
#d16 le(BLACK`16), le(rgb(16,16,16)), le(rgb(31,0,0)), le(rgb(0,31,0))
block_color_map_end:
empty_grid:
#once
#d16 le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(0`16),le(1`16)
#d16 le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16),le(1`16)
empty_grid_end:
BLOCK_EMPTY = 0x00
BLOCK_BORDER = 0x01
BLOCK_PLACED = 0x02
BLOCK_ACTIVE = 0x03
PIECE_STARTX = 6
PIECE_STARTY = 1
upload_grid_pxrow: ; void upload_grid_pxrow( [reader] int *gridaddr, [writer] int* gram_addr )
    ; 12 iterations
    ldi r14, GRID_WIDTH
    .loop:
        ; read next block
        read r13
        ; load color for block
        ldi r12, block_color_map
        add r13, r12
        elpm r12, r13
        ; write 5
        write r12
        write r12
        write r12
        write r12
        ; looping mechanism
        dec r14
        j nz .loop
    ; skip to next row
    ld r14 <- [WRITER]
    ldi r13, (160 - GRID_SCALE * GRID_WIDTH)
    add r14, r13
    st r14 -> [WRITER]
    ret
upload_grid:
    ; setup writer to write to current buffer
    ld r14 <- [cur_gbuf_addr]
    st r14 -> [WRITER]
    ; setup reader to read from the grid
    ldi r8, grid
    st r8 -> [READER]
    ; 22 loop iterations
    ldi r9, GRID_HEIGHT
    .loop:
        ; preserve reader for each of the 5 rows (drawing 5x5 square)
        ld r8 <- [READER]
        call upload_grid_pxrow
        st r8 -> [READER]
        call upload_grid_pxrow
        st r8 -> [READER]
        call upload_grid_pxrow
        st r8 -> [READER]
        call upload_grid_pxrow
        ; looping mechanism
        dec r9
        j nz .loop
    ret
reset_piece: ; void reset_piece()
    ; reset rotation
    xor r14, r14
    st r14 -> [cur_piece_rotnum]
    ; reset grid address
    ldi r14, grid + (PIECE_STARTX + (PIECE_STARTY * 12))
    st r14 -> [cur_piece_gridaddr]
    ; reset x, y
    ldi r14, PIECE_STARTX
    st r14 -> [cur_piece_x]
    ldi r14, PIECE_STARTY
    st r14 -> [cur_piece_y]
    ; select random piece
    ld r14 <- [RAND]
    ; piece = piece_map[ rand() % 6 ]
    ldi r13, 6
    divrem r14, r13
    ldi r13, pieces_map
    add r13, r14
    elpm r14, r13
    nop
    st r14 -> [cur_piece_addr]
    ret
piece_fall: ; void piece_fall()
    ld r14 <- [cur_piece_gridaddr]
    ldi r13, 12
    add r14, r13
    st r14 -> [cur_piece_gridaddr]
    ld r14 <- [cur_piece_y]
    inc r14
    st r14 -> [cur_piece_y]
    ret
piece_draw: ; void piece_draw()
    push r0
    push r1
    ld r0 <- [cur_piece_gridaddr]
    call clear_piece
    ld r0 <- [cur_piece_addr]
    ld r1 <- [cur_piece_gridaddr]
    call place_piece
    pop r1
    pop r0
    ret
piece_check: ; void piece_check()
    push r1
    push r2
    ldi r0, BLOCK_ACTIVE
    ldi r1, BLOCK_PLACED
    ldi r2, BLOCK_BORDER
    ; r14 = grid[px][py]
    ld r14 <- [cur_piece_gridaddr]
    ldi r10, 3 ; i: row (checks below too)
    ; for (i = 0; i < 3; i++) // row
    ; for (j = 0; j < 3; j++) // column
    ; if (grid[px+j][py+i] == ACTIVE_BLOCK &&
    ; grid[px+j][py+i+1] == BORDER || == BLOCK)
    ; STOP;
    .ilp:
        ldi r11, 2 ; j: column
        .jlp:
            ; r13 = &grid[px+j][py+i]
            ldi r13, GRID_WIDTH
            mul r13, r10
            add r13, r11
            add r13, r14
            ; r12 = grid[px+j][py+i]
            ld r12 <- r13
            sub r12, r0 ; cmp r12, BLOCK_ACTIVE
            j nz .is_not_active
            .is_active:
            ; r13 = &grid[px+j][py+i+1]
            ldi r12, GRID_WIDTH
            add r13, r12
            ; r12 = grid[px+j][py+i+1]
            ld r12 <- r13
            ; if (r12 == BLOCK_PLACED || r12 == BLOCK_BORDER)
            ; goto do_stop
            push r12
            sub r12, r1
            j z .do_stop
            pop r12
            sub r12, r2
            j z .do_stop
            jmp .jcontinue
            .do_stop:
            ldi r0, 1
            jmp .return
            .is_not_active:
            .jcontinue:
            dec r11
            j nz .jlp
        dec r10
        j nz .ilp
    pop r2
    pop r1
    xor r0, r0
    .return:
    ret
main:
    ldi r0, __gram_buf0_begin
    st r0 -> [cur_gbuf_addr]
    call reset_piece
    ; fill the grid with the starting pattern
    ldi r0, empty_grid
    ldi r1, grid
    ldi r2, empty_grid - empty_grid_end
    call p2s_memcpy
    ; fill the screen black
    ; ldi r0, __gram_begin
    ; ldi r1, BLACK
    ; ldi r2, __gram_buf0_end - __gram_buf0_begin
    ; call memset
    call memset(__gram_begin, BLACK, __gram_buf0_end-__gram_buf0_begin)
    .lp:
    call piece_draw
    call upload_grid
    ; if (piece_check())
    ; goto next_piece;
    ; else
    ; continue;
    call piece_check
    and r0, r0
    j nz .next_piece
    call piece_fall
    jmp .lp
    .next_piece:
    ld r0 <- [cur_piece_gridaddr]
    call solidify_piece
    call reset_piece
    jmp .lp
    ret
