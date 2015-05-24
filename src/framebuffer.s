global fb_clear
global fb_move_cursor_coor
global fb_move_cursor_pos

FB_START   equ 0x000B8000
FB_END     equ 0x000B8FA0
FB_WIDTH   equ 80
FB_HEIGHT  equ 25
FB_SIZE    equ FB_WIDTH*FB_HEIGHT
FB_IO_CALL equ 0x03D4
FB_IO_BYTE equ 0x03D5

section .bss
align 4
cursor:
    resb 2

section .text
align 4
; fb_clear - clear the framebuffer
;
; stack: [esp] the return address
;
; return: nothing
fb_clear:
    mov eax, FB_START               ; set eax to the start of the fb

.loop:
    cmp eax, FB_END                 ; check if the eax is at the end of the fb
    je .end                         ; if it is, jump to the end of the loop
    mov word [eax], 0x0F20          ; else, move a black space into the char
    add eax, 0x2                    ; increase eax for the next char
    jmp .loop                       ; return at the start of the loop

.end:
    ret                             ; return to the caller

; fb_move_cursor_coor - specify the position of the cursor in the
;                       framebuffer using coordinates
;
; stack: [ebp+8] y position
;        [ebp+4] x position
;        [ebp  ] return address
;
; return: [0] no error
;         [1] wrong width
;         [2] wrong height
;
; note: the x position must be in [0, 80[
;       the y position must be in [0, 25[
fb_move_cursor_coor:
    mov ebx, [esp+8]                ; move the x position in ebx
    mov eax, [esp+4]                ; move the y position in eax

    cmp ebx, FB_WIDTH               ; if x position >= FB_WIDTH
    jge .end_x_err                  ; then, exit with an error code

    cmp ebx, 0x0                    ; if x position < 0
    jl .end_x_err                   ; then, exit with an error code

    cmp eax, FB_HEIGHT              ; if y position >= FB_HEIGHT
    jge .end_y_err                  ; then, exit with an error code
    
    cmp eax, 0x0                    ; if y position < 0
    jl .end_y_err                   ; then, exit with an error code

    ; calculate the position in the framebuffer
    mov edx, FB_WIDTH               ; put FB_WIDTH into edx
    mul edx                         ; multiply the height by edx
    add eax, ebx                    ; add the width to the height

    call fb_move_cursor_pos         ; eax already contains the position

    mov eax, 0x0                    ; error code if everything went well
    jmp .end                        ; exit the function

.end_x_err:
    mov eax, 0x1                    ; error code if the x position is wrong
    jmp .end                        ; exit the function

.end_y_err:
    mov eax, 0x2                    ; error code if the y position is wrong

.end:
    ret                             ; return to the caller


; fb_move_cursor_pos - specify the position of the cursor in the
;                      framebuffer
;
; register: [eax] position of the cursor
;
; stack: [esp+4] old ebp
;        [esp  ] return address
;        [esp-4] first byte to send
;        [esp-8] second byte to send
;
; return: [0] no error
;         [1] wrong position
;
; note: the position must be in [0, 2000[
fb_move_cursor_pos:
    sub esp, 8                      ; allocate storage for variables

    cmp eax, FB_SIZE                ; if the position >= FB_SIZE
    jge .end_err                    ; then, exit with an error code

    cmp eax, 0x0                    ; if the position < FB_SIZE
    jl .end_err                     ; then, exit with and error code

    mov [cursor], eax               ; change the cursor's position

    ; split the position in the framebuffer into 2 bytes
    mov [esp-4], eax                ; store the first byte into [ebp-4]
    shr eax, 8                      ; shift the second byte into the first
    mov [esp-8], eax                ; store the second byte into [ebp-8]

    ; send the first byte to the framebuffer
    mov dx, FB_IO_CALL              ; address of the I/O port for calls
    mov al, 14                      ; we are going to send the first byte
    out dx, al                      ; send the call to the I/O port

    mov dx, FB_IO_BYTE              ; address of the I/O port for bytes
    mov al, [esp-8]                 ; the first byte
    out dx, al                      ; send the byte to the I/O port

    ; send the second byte to the framebuffer
    mov dx, FB_IO_CALL              ; address of the I/O port for calls
    mov al, 15                      ; we are going to send the second byte
    out dx, al

    mov dx, FB_IO_BYTE              ; address of the I/O port for bytes
    mov al, [esp-4]                 ; the second byte
    out dx, al                      ; send the byte to the I/O port

    mov eax, 0x0                    ; error code if everything went well
    jmp .end                        ; exit the function

.end_err:
    mov eax, 0x1                    ; error code if the position is wrong

.end:
    add esp, 8                      ; remove allocated variables
    ret                             ; return to the caller
