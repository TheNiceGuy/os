global fb_clear
global fb_scroll_up
global fb_move_cursor_coor
global fb_move_cursor_pos
global fb_write

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
; stack: [esp] return address
;
; register used: [ecx]
;
; return: nothing
fb_clear:
    mov ecx, FB_START               ; set eax to the start of the fb

.loop:
    cmp ecx, FB_END                 ; check if the eax is at the end of the fb
    je .end                         ; if it is, jump to the end of the loop
    mov word [ecx], 0x0F20          ; else, move a black space into the char
    add ecx, 0x2                    ; increase eax for the next char
    jmp .loop                       ; return at the start of the loop

.end:
    ret                             ; return to the caller

; fb_scroll_up - scroll the framebuffer by one line
;
; stack: [esp] return address
;
; register used: [eax] [ebx] [ecx] [edx]
;
; return: nothing
fb_scroll_up:
    mov eax, FB_WIDTH               ; move the width of the fb into eax
    mov ebx, FB_START               ; move the start of the fb into ebx
    mov ecx, FB_END                 ; move the end of the fb into ecx

    mov edx, 2
    mul edx                         ; (FB_WIDTH*2)
    sub ecx, eax                    ; (FB_END)-(FB_WIDTH*2)
    add eax, FB_START               ; (FB_START)+(FB_WIDTH*2)

.loop:
    cmp ebx, ecx                    ; if we are the (last line)-1 of the fb
    je .loop_fill                   ; then, we need to fill the last line

    mov edx, [eax]                  ; read two chars into edx
    mov [ebx], edx                  ; put them one line before

    add eax, 4                      ; increase eax by 4
    add ebx, 4                      ; increase ebx by 4
    jmp .loop

.loop_fill:
    cmp ebx, FB_END                 ; if the end of the fb
    je .end                         ; then, we can exit the function

    mov word [ebx], 0x0F20          ; replace the char by a black space
    add ebx, 2                      ; increase ebx by 2
    jmp .loop_fill

.end:
    ret                             ; return to the caller

; fb_move_cursor_coor - specify the position of the cursor in the
;                       framebuffer using coordinates
;
; stack: [ebp+8] y position
;        [ebp+4] x position
;        [ebp  ] return address
;
; register used: [eax] [ebx] [edx]
;
; return: [0] no error
;         [1] wrong width
;         [2] wrong height
;
; note: the x position must be in [0, 80[
;       the y position must be in [0, 25[
fb_move_cursor_coor:
    mov ebx, [esp+4]                ; move the y position in ebx
    mov eax, [esp+8]                ; move the x position in eax

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

    push eax                        ; push the argument
    call fb_move_cursor_pos         ; change the position
    add esp, 4                      ; remove the argument

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
; stack: [ebp+8] position of the cursor
;        [ebp+4] old ebp
;        [ebp  ] return address
;        [ebp-4] first byte to send
;        [ebp-8] second byte to send
;
; register used: [eax] [al] [dx]
;
; return: [0] no error
;         [1] wrong position
;
; note: the position must be in [0, 2000[
fb_move_cursor_pos:
    push ebp                        ; push the old ebp
    mov ebp, esp                    ; make ebp point to esp
    sub esp, 8                      ; allocate storage for variables

    mov eax, [ebp+8]                ; move the position into eax

    cmp eax, FB_SIZE                ; if the position >= FB_SIZE
    jge .end_err                    ; then, exit with an error code

    cmp eax, 0x0                    ; if the position < FB_SIZE
    jl .end_err                     ; then, exit with and error code

    mov [cursor], eax               ; change the cursor's position

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
    jmp .end                        ; exit the function

.end_err:
    mov eax, 0x1                    ; error code if the position is wrong

.end:
    mov esp, ebp                    ; restore esp
    pop ebp                         ; restore ebp
    ret                             ; return to the caller

; fb_write - write a null-terminated string into the framebuffer
;
; stack: [ebp+8] pointer to a null-terminated string
;        [ebp+4] old ebp
;        [ebp  ] return address
;
; register used: [eax] [ebx] [ecx] [edx]
;
; return: nothing
fb_write:
    push ebp                        ; push the old ebp
    mov ebp, esp                    ; make ebp point to esp

    mov eax, [cursor]               ; move the cursor's offset into eax
    mov ebx, FB_START               ; move the fb pointer into eax
    mov ecx, [ebp+8]                ; move the string pointer into ecx
    mov edx, 2                      ; move 2 into edx
    mul edx                         ; multiply eax by edx [2]
    add eax, ebx                    ; add the fb pointer into eax

.loop:
    mov dx, [ecx]                   ; move a word of the string into dx

    cmp dl, 00                      ; if the lower byte is a null char
    je .end                         ; then, exit the function since we
                                    ; are at the end of the string

.print_byte:
    and edx, 0x00FF                 ; prepare the register for the color
    or edx, 0x0F00                  ; add color into the register
    mov word [eax], dx              ; print the character

    add word [cursor], 1            ; increase the cursor by 1
    add eax, 2                      ; increase the fb's offset by 2
    add ecx, 1                      ; increase the string's offset by 1

    cmp word [cursor], FB_SIZE      ; if the cursor isn't at the end
    jne .loop                       ; then, we can add another character
                                    ; else, we need to scroll up
    sub word [cursor], FB_WIDTH     ; we put the cursor at the start of
                                    ; the line a substracting the width
    sub eax, FB_WIDTH*2             ; we substract to pointer

    ; we save all current register before calling fb_scroll_up
    push eax
    push ebx
    push ecx
    push edx
    call fb_scroll_up
    pop edx
    pop ecx
    pop ebx
    pop eax

    jmp .loop

.end:
    push dword [cursor]             ; push the new position of the cursor
    call fb_move_cursor_pos         ; change the cursor's position
    add esp, 4                      ; remove the argument from the stack

    mov esp, ebp                    ; restore esp
    pop ebp                         ; restore ebp
    ret                             ; return to the caller
