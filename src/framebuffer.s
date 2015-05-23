global fb_clear
global fb_move_cursor

FB_START   equ 0x000B8000
FB_END     equ 0x000B8FA0
FB_WIDTH   equ 80
FB_HEIGHT  equ 25
FB_IO_CALL equ 0x03D4
FB_IO_BYTE equ 0x03D5

section .text
align 4
; fb_clear - clear the framebuffer
;
; stack: [esp] the return address
;
; return: nothing
fb_clear:
    mov eax, FB_START               ; set eax to the start of the fb

fb_clear_loop:
    cmp eax, FB_END                 ; check if the eax is at the end of the fb
    je fb_clear_end                 ; if it is, jump to the end of the loop
    mov word [eax], 0x0F20          ; else, move a black space into the char
    add eax, 0x2                    ; increase eax for the next char
    jmp fb_clear_loop               ; return at the start of the loop

fb_clear_end:
    ret                             ; return to the caller

; fb_move_cursor - specify the position of the cursor in the framebuffer
;
; stack: [ebp+12] y position
;        [ebp+ 8] x position
;        [ebp+ 4] old ebp
;        [ebp   ] return addres
;        [ebp- 4] first byte to send
;        [ebp- 8] second byte to send
;
; return: [0] no error
;         [1] wrong width
;         [2] wrong height
;
; note: the x position must be in [0, 80[
;       the y position must be in [0, 25[
fb_move_cursor:
    push ebp                        ; save the old base pointer
    mov ebp, esp                    ; make ebp point to esp
    sub esp, 8                      ; allocate storage for variables

    mov ebx, [ebp+12]               ; move the x position in ebx
    mov eax, [ebp+ 8]               ; move the y position in eax

    cmp ebx, FB_WIDTH               ; if x position >= FB_WIDTH
    jge fb_move_cursor_w_err        ; then, exit with an error code

    cmp ebx, 0x0                    ; if x position < 0
    jl fb_move_cursor_w_err         ; then, exit with an error code

    cmp eax, FB_HEIGHT              ; if y position >= FB_HEIGHT
    jge fb_move_cursor_h_err        ; then, exit with an error code
    
    cmp eax, 0x0                    ; if y position < 0
    jl fb_move_cursor_h_err         ; then, exit with an error code

    ; calculate the position in the framebuffer
    mov edx, FB_WIDTH               ; put FB_WIDTH into edx
    mul edx                         ; multiply the height by edx
    add eax, ebx                    ; add the width to the height

    ; split the position in the framebuffer into 2 bytes
    mov [ebp-4], eax                ; store the first byte into [ebp-4]
    shr eax, 8                      ; shift the second byte into the first
    mov [ebp-8], eax                ; store the second byte into [ebp-8]

    ; send the first byte to the framebuffer
    mov dx, FB_IO_CALL              ; address of the I/O port for calls
    mov al, 14                      ; we are going to send the first byte
    out dx, al                      ; send the call to the I/O port

    mov dx, FB_IO_BYTE              ; address of the I/O port for bytes
    mov al, [ebp-8]                 ; the first byte
    out dx, al                      ; send the byte to the I/O port

    ; send the second byte to the framebuffer
    mov dx, FB_IO_CALL              ; address of the I/O port for calls
    mov al, 15                      ; we are going to send the second byte
    out dx, al

    mov dx, FB_IO_BYTE              ; address of the I/O port for bytes
    mov al, [ebp-4]                 ; the second byte
    out dx, al                      ; send the byte to the I/O port

    mov eax, 0x0                    ; error code if everything went well
    jmp fb_move_cursor_end          ; exit the function

fb_move_cursor_w_err:
    mov eax, 0x1                    ; error code if the width is out of bound
    jmp fb_move_cursor_end          ; exit the function

fb_move_cursor_h_err:
    mov eax, 0x2                    ; error code if the height is out of bound
    jmp fb_move_cursor_end          ; exit the function

fb_move_cursor_end:
    mov esp, ebp                    ; restore the stack pointer
    pop ebp                         ; restore ebp
    ret                             ; return to the caller
