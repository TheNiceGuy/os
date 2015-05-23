global clear
global move_cursor

extern outb

FRAMEBUFFER_S equ 0x000B8000
FRAMEBUFFER_E equ 0x000B8FA0

; clear - clear the framebuffer
;
; stack: [esp] the return address
clear:
    mov eax, FRAMEBUFFER_S          ; set eax to the start of the fb

clear_loop:
    cmp eax, FRAMEBUFFER_E          ; check if the eax is at the end of the fb
    je clear_end                    ; if it is, jump to the end of the loop
    mov word [eax], 0x0F20          ; else, move a black space into the char
    add eax, 0x2                    ; increase eax for the next char
    jmp clear_loop                  ; return at the start of the loop

clear_end:
    ret                             ; return to the caller

; move_cursor - specify the position of the cursor in the framebuffer
;
; stack:
move_cursor:
    ret
    push byte 0x14
    push word 0x3D4
    call outb
    add esp, 3

    push byte 0x00
    push word 0x3D5
    call outb
    add esp, 3

    push byte 0x15
    push word 0x3D4
    call outb
    add esp, 3

    push byte 0x50
    push word 0x3D5
    call outb
    add esp, 3

    ret 
