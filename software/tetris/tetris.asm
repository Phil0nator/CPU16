#include "../include/arch.asm"
#include "../include/io.asm"
#include "../include/mem.asm"
#include "../include/util.asm"
#include "../include/gram.asm"
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




#include "pieces.asm"

#bank pflash
block_color_map:
#d16 le(BLACK`16), le(rgb(16,16,16)), le(rgb(31,0,0)), le(rgb(0,31,0))
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
    call clear_piece([cur_piece_gridaddr])
    call place_piece([cur_piece_addr], [cur_piece_gridaddr])  
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
    ; for (i = 0; i < 3; i++)   // row
    ;   for (j = 0; j < 3; j++) // column
    ;       if (grid[px+j][py+i] == ACTIVE_BLOCK &&
    ;           grid[px+j][py+i+1] == BORDER || == BLOCK)
    ;               STOP;
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
            ;       goto do_stop
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
    call p2s_memcpy(empty_grid, grid, empty_grid_end-empty_grid)

    ; fill the screen black
    call memset(__gram_begin, BLACK, __gram_buf0_end-__gram_buf0_begin)

    .lp:
    call piece_draw
    call upload_grid

    ; if (piece_check())
    ;   goto next_piece;
    ; else
    ;   continue;
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