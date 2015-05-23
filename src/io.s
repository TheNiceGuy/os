global outb
global inb

section .text
align 4
; outb - sent a byte to an I/O port
;
; stack: [esp+8] [ byte] the data byte
;        [esp+4] [ word] the I/O port
;        [esp  ] [dword] the return address
outb:
    mov al, [esp+8]   ; move the data byte into al
    mov dx, [esp+4]   ; move the address into dx
    out dx, al        ; send the byte into the I/O port
    ret               ; return to the caller

; inb - returns a byte from the given I/O port
;
; stack: [esp+4] [ word]the I/O port
;        [esp  ] [dword]the return address
inb:
    mov dx, [esp+4]   ; move the address into dx
    in al, dx         ; read a byte from the I/O port into al
    ret               ; return to the caller
