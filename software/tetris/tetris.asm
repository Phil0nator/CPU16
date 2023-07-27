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
update_counter:
#res 1
piece_counter:
#res 1



#include "pieces.asm"
#include "logo.asm"

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

PIECE_STARTX = 5
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
    ld r14 <- [piece_counter]
    inc r14
    st r14 -> [piece_counter]

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

    ; every 3 ticks ....
    ld r14 <- [update_counter]
    ldi r13, 3
    divrem r14, r13
    and r14, r14
    j nz .return


    ld r14 <- [cur_piece_gridaddr]
    ldi r13, 12
    add r14, r13
    st r14 -> [cur_piece_gridaddr]
    ld r14 <- [cur_piece_y]
    inc r14
    st r14 -> [cur_piece_y]
    .return:
    ret

piece_clear:
    push r0
    push r1
    call fill_piece_with([cur_piece_gridaddr], BLOCK_EMPTY)
    pop r1
    pop r0
    ret

piece_draw: ; void piece_draw()
    push r0
    push r1
    call place_piece([cur_piece_addr], [cur_piece_gridaddr])  
    pop r1
    pop r0
    ret

piece_rot: ; void piece_rot()
    push r0
    push r1

    ld r0 <- [cur_piece_rotnum]
    inc r0
    ldi r1, 0x3
    and r0, r1 ; sets flag
    st r0 -> [cur_piece_rotnum]
    ld r0 <- [cur_piece_addr]
    j nz .no_reset ; uses flag
    ldi r1, (PIECE_SIZE * 3)
    sub r0, r1
    jmp .done
    .no_reset:
    ldi r1, PIECE_SIZE
    add r0, r1
    .done:
    st r0 -> [cur_piece_addr]

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
    ldi r10, 2 ; i: row (checks below too)
    ; for (i = 2; i >= 0; i++)   // row
    ;   for (j = 2; j >= 0; j++) // column
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
            j ne .is_not_active
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
            j e .do_stop
            pop r12
            push r12
            sub r12, r2
            j e .do_stop
            pop r12
            jmp .jcontinue

            .do_stop:
            pop r0  ; clear stack from above
            ldi r0, 1
            jmp .return

            .is_not_active:
            .jcontinue:
            dec r11
            j nn .jlp
        dec r10
        j nn .ilp


    xor r0, r0
    .return:
    pop r2
    pop r1
    ret


collect_input: ; void collect_input()
    push r0
    push r1
    push r2

    ; switch (getc()) {
    ; case spacebar:
    ; case 'a': ...
    ; case 'd': ...
    ;}
    .re_collect:
    call getc
    mov r2, r0
    and r2, r2
    j z .return
    ldi r1, 32 ; spacebar
    sub r2, r1
    j e .rotate
    mov r2, r0
    ldi r1, 0x61 ; 'a'
    sub r2, r1
    j e .left
    mov r2, r0
    ldi r1, 0x64 ; 'd'
    sub r2, r1
    j e .right
    mov r2, r0
    ldi r1, 0x73 ; 's'
    sub r2, r1
    j e .down

    and r2, r2  ; is anything... collect again
    j nz .re_collect
    jmp .return ; default

    .rotate:
    call piece_rot
    jmp .return

    .left:
    ; if (cur_piece_x != 1)
    ;   cur_piece_x --
    ld r0 <- [cur_piece_x]
    ldi r1, 1
    sub r0, r1
    j e .re_collect ; go no further left than x=1

    ld r0 <- [cur_piece_gridaddr]
    dec r0
    st r0 -> [cur_piece_gridaddr]
    jmp .re_collect


    .right:
    ; if (cur_piece_x != 8)
    ;   cur_piece_x ++
    ld r0 <- [cur_piece_x]
    ldi r1, (GRID_WIDTH - 1 - 3)
    sub r0, r1
    j e .re_collect ; go no further right than x=8

    ld r0 <- [cur_piece_gridaddr]
    inc r0
    st r0 -> [cur_piece_gridaddr]
    jmp .re_collect


    .down:
    ldi r0, 2
    st r0 -> [update_counter]
    jmp .re_collect
        

    .return:
    pop r2
    pop r1
    pop r0
    ret


shift_down: ; void shift_down(int from_y)

    push r1
    push r2
    push r3
    push r4
    push r5
    ; for (;from_y > 0; from_y --)
    ;   for (col = 11; col > 0; col --)
    ;       grid[col][from_y] = grid[col][from_y-1]
    ;
    ;   grid[1..=11][1] = EMPTY

    .lprow:
        ldi r1, 11
        .lpcol:    
            
            ; r2 = &grid[row][col]
            ldi r2, GRID_WIDTH
            mul r2, r0
            add r2, r1
            ldi r3, grid
            add r2, r3
            
            ; r5 = &grid[row-1][col]
            mov r5, r2
            ldi r4, GRID_WIDTH
            sub r5, r4
            ; r5 = grid[row-1][col]
            ld r5 <- r5
            st r5 -> r2

            dec r1
            j nz .lpcol
        dec r0
        j nz .lprow

    ldi r0, grid + GRID_WIDTH + 1
    st r0 -> [WRITER]
    xor r0, r0

    write r0
    write r0
    write r0
    write r0
    write r0
    write r0
    write r0
    write r0
    write r0
    write r0

    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    ret

check_for_complete_strip: ; void check_for_complete_strip()

    ; for (int row = 21; row > 0; row--)
    ;   for (int col = 10; col > 0; col--) {
    ;       if (grid[row][col] != PLACED)
    ;           continue;
    ;       shift_down();
    ;       row ++; // this row needs to be re-done
    ;   }
    push r0
    push r1
    push r2
    push r3

    ldi r0, 20 ; row
    .lprow:
        ldi r1, 10 ; column
        .lpcol:

            ; r2 = &grid[row][col]
            ldi r2, GRID_WIDTH
            mul r2, r0
            add r2, r1
            ldi r3, grid
            add r2, r3
            ; r2 = grid[row][col]
            ld r2 <- r2
            and r2, r2
            j z .continue_col 

            dec r1
            j nz .lpcol
            .post_lpcol:
            push r0
            call shift_down
            pop r0
            inc r0

            .continue_col:
        dec r0
        j nz .lprow


    pop r3
    pop r2
    pop r1
    pop r0
    ret


main:

    ldi r0, __gram_buf0_begin
    st r0 -> [cur_gbuf_addr]
    
    call reset_piece

    ; fill the grid with the starting pattern
    call p2s_memcpy(empty_grid, grid, empty_grid_end-empty_grid)

    ; fill the screen black
    call memset(__gram_begin, BLACK, __gram_buf0_end-__gram_buf0_begin)

    ; draw logo
    call gram_blit_p(logo_begin, __gram_buf0_begin + (GRAM_WIDTH * 15) + (GRID_WIDTH * GRID_SCALE + 30), LOGO_HEIGHT, LOGO_WIDTH)


    .lp:

    ld r14 <- [update_counter]
    inc r14
    st r14 -> [update_counter]

    call upload_grid
    call piece_clear
    call piece_fall
    call collect_input
    call piece_draw
    
    

    
    ; if (piece_check())
    ;   goto next_piece;
    ; else
    ;   continue;
    call piece_check
    and r0, r0
    j nz .next_piece    
    jmp .lp
    .next_piece:
    call fill_piece_with([cur_piece_gridaddr], BLOCK_PLACED)
    call check_for_complete_strip
    call reset_piece
    jmp .lp

    ret