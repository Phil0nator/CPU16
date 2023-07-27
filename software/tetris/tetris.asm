#include "../include/arch.asm"
#include "../include/io.asm"
#include "../include/mem.asm"
#include "../include/gram.asm"


#bank sram
grid:
#res (12*22)
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




#include "pieces.asm"

#bank pflash
block_color_map:
#d16 le(BLACK`16), le(rgb(16,16,16)), le(rgb(31,31,31)), le(rgb(31,0,0))
block_color_map_end:
empty_grid:
#include "empty_grid.asm"
empty_grid_end:


BLOCK_EMPTY = 0x00
BLOCK_BORDER = 0x01
BLOCK_PLACED = 0x02
BLOCK_ACTIVE = 0x03

PIECE_STARTX = 6
PIECE_STARTY = 1


upload_grid_pxrow: ; void upload_grid_pxrow( [reader] int *gridaddr, [writer] int* gram_addr )
    ; 12 iterations
    ldi r14, 12
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
        write r12

        ; looping mechanism
        dec r14
        j nz .loop
    
    ; skip to next row
    ld r14 <- [WRITER]
    ldi r13, 100
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
    ldi r9, 22
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
    st  r14 -> [cur_piece_gridaddr]
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
    ldi r0, __gram_begin
    ldi r1, BLACK
    ldi r2, __gram_buf0_end - __gram_buf0_begin
    call memset

    .lp:
    call piece_draw
    call upload_grid
    call piece_fall
    jmp .lp

    ret