global loader                               ; the entry symbol for ELF

extern sum_of_three

MAGIC_NUMBER equ 0x1BADB002                 ; define the magic number constant
FLAGS        equ 0x0                        ; multiboot flags
CHECKSUM     equ -MAGIC_NUMBER              ; calculate the checksum
                                            ; (MAGIC_NUMBER+CHECKSUM+FLAGS = 0)

KERNEL_STACK_SIZE equ 4096                  ; size of the kernel stack

section .bss
align 4                                     ; the code must be aligned by 4 bytes
kernel_stack:                               ; label points to beginning of memory
    resb KERNEL_STACK_SIZE                  ; reserver stack for the kernel

section .text:                              ; start of the text section
align 4                                     ; the code must be aligned by 4 bytes
    dd MAGIC_NUMBER                         ; write MAGIC_NUMBER
    dd FLAGS                                ; write FLAGS
    dd CHECKSUM                             ; write CHECKSUM

loader:                                     ; this is the entry point in the linker script
    mov esp, kernel_stack+KERNEL_STACK_SIZE ; setup the stack pointer
    mov dword [0x000B8000], 0x4128

    push dword 3
    push dword 3
    push dword 3
    call sum_of_three

.loop:
    jmp .loop                               ; loop forever
