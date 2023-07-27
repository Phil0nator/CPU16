#include "include/arch.asm"
#include "include/io.asm"
#include "include/mem.asm"
#bank pflash

PORT_ADDR = PORTA
PORT_DATA = PORTB
PORT_BUFSEL = PORTB

PULSE_TERM = 1
PULSE_DSTR = 2
PULSE_BUFSEL = 4

BUFSEL0 = 0
BUFSEL1 = 1

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

LOGICAL_WIDTH = 12
LOGICAL_HEIGHT = 22
LOGICAL_BUFSIZE = (LOGICAL_WIDTH * LOGICAL_HEIGHT)


RESOLUTION_UPSCALE = 5


WIDTH = (LOGICAL_WIDTH * RESOLUTION_UPSCALE)
HEIGHT = (LOGICAL_HEIGHT * RESOLUTION_UPSCALE)
BUFSIZE = (WIDTH*HEIGHT)
GRAM_END = (BUFSIZE * 2)
BUF0_ADDR = (0)
BUF1_ADDR = (BUFSIZE)




__hello_world:
#d utf16le("Hello World!\n\0")
__hello_world_end:



#bank sram
cur_buf:
#res 1
logical_buf:
#res LOGICAL_BUFSIZE * 2
logical_buf_end:
#bank pflash





flip:   ; void flip()
    ; not the current buffer value (0/1)
    ld r14 <- [cur_buf]
    not r14
    ; store new value, output on port
    st r14 -> [cur_buf]
    st r14 -> [PORT_BUFSEL]
    ; pulse flipflop to update display
    ldi r14, PULSE_BUFSEL
    st r14 -> [PULSE]
    ret

write_px:   ; void write_px(int x, int y, int color)
    ; calculate address

    ;; determine base address for inactive buffer
    xor r14, r14            ; if (!cur_buf) r14 = 1 else r14 = 0
    ld r13 <- [cur_buf]
    and r13, r13
    j nz .buf0
    inc r14
    .buf0:

    ; r14 *= BUFSIZE
    ldi r13, BUFSIZE
    mul r14, r13

    ; r14 now = buffer base address
    ;; pixaddr = (y*width) + x = r1 
    ldi r13, WIDTH
    mul r1, r13
    add r1, r0

    ; scratch r0 (not needed)
    ; final_addr = r0 = &local_buf[pixaddr + buffer_base]
    ldi r0, local_buf
    add r0, r1
    add r0, r14

    ; *final_addr = color
    st r2 -> r0

    ret

upload:     ; void upload()
    ;; determine base address for inactive buffer
    xor r14, r14            ; if (!cur_buf) r14 = 1 else r14 = 0
    ld r13 <- [cur_buf]
    and r13, r13
    j nz .buf0
    inc r14
    .buf0:

    ; r14 *= BUFSIZE
    ldi r13, BUFSIZE
    mul r14, r13

    ldi r12, local_buf
    add r12, r14
    ; r13 = BUFSIZE (counter)
    ; r14 = base addr (out)
    ; r12 = base addr (local)
    ; r11 = scratch (each color)
    .loop:

        ld r11 <- r12 ; load color
        st r11 -> [PORT_DATA]
        st r14 -> [PORT_ADDR]
        ldi r11, PULSE_DSTR ; pulse data store
        st r11 -> [PULSE]

        inc r14
        inc r12
        dec r13
        j nz .loop        
    

    ret



main:
    
    ldi r0, local_buf
    ldi r1, CYAN
    ldi r2, local_buf_end - local_buf
    call memset


    call upload
    call flip

    ldi r0, local_buf
    ldi r1, ORANGE
    ldi r2, local_buf_end - local_buf
    call memset

    call upload
    call flip

    jmp main


    ret