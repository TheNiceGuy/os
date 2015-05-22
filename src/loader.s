global loader                  ; the entry symbol for ELF

MAGIC_NUMBER equ 0x1BADB002    ; define the magic number constant
FLAGS        equ 0x0           ; multiboot flags
CHECKSUM     equ -MAGIC_NUMBER ; calculate the checksum
                               ; (MAGIC_NUMBER+CHECKSUM+FLAGS = 0)

section .text:                 ; start of the text section
align 4                        ; the code must be 4 byte aligned
    dd MAGIC_NUMBER            ; write MAGIC_NUMBER
    dd FLAGS                   ; write FLAGS
    dd CHECKSUM                ; write CHECKSUM

loader:                        ; this is the entry point in the linker script
    mov eax, 0xCAFEBABE        ; move 0xCAFEBABE in the register eax
.loop:
    jmp .loop                  ; loop forever
    
