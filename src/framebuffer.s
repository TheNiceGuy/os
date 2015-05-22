FRAMEBUFFER_S equ 0x000B8000
FRAMEBUFFER_E equ 0x000B8F9F

section .text
global clear
clear:
    mov dword eax, FRAMEBUFFER_S    ; set eax to the start of the fb

clear_loop:
    cmp [FRAMEBUFFER_E], eax        ; check if the eax is at the end of the fb 
    jle clear_end                   ; if it is, jump to the end of the loop
    mov dword [eax], 0x3200         ; else, move a black space into the char
    add eax, 0x1                    ; increase eax for the next char
    jmp clear_loop                  ; return at the start of the loop

clear_end:
    ret                             ; return to the caller
