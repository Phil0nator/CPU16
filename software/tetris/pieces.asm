#once
#include "../include/arch.asm"
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
#d16    le(piece0_0`16)
#d16    le(piece1_0`16)
#d16    le(piece2_0`16)
#d16    le(piece3_0`16)
#d16    le(piece4_0`16)
#d16    le(piece5_0`16)

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

place_piece: ; void place_piece( place_addr, grid_addr)
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