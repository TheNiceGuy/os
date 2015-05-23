global outb

section .text
align 4
; outb - sent a byte to an I/O port
;
; stack: [esp+8] [ byte] the data byte
;        [esp+4] [ word] the I/O port
;        [esp  ] [dword] the return address
outb:
    mov al, [esp+8]
    mov dx, [esp+4]
    out dx, al
    ret
