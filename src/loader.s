global loader                       ; the entry symbol for ELF

extern kmain
extern fb_clear
extern fb_move_cursor_coor
extern fb_move_cursor_pos

MAGIC_NUMBER equ 0x1BADB002         ; define the magic number constant
FLAGS        equ 0x0                ; multiboot flags
CHECKSUM     equ -MAGIC_NUMBER      ; calculate the checksum
                                    ; (MAGIC_NUMBER+CHECKSUM+FLAGS = 0)

KERNEL_STACK_SIZE equ 4096          ; size of the kernel stack

section .bss
align 4                             ; the code must be aligned by 4 bytes
kernel_stack:                       ; label points to beginning of memory
    resb KERNEL_STACK_SIZE          ; reserver stack for the kernel

section .text                       ; start of the text section
align 4                             ; the code must be aligned by 4 bytes
    dd MAGIC_NUMBER                 ; write MAGIC_NUMBER
    dd FLAGS                        ; write FLAGS
    dd CHECKSUM                     ; write CHECKSUM

loader:                             ; this is the entry point in the linker script
                                    ; setup the stack pointer
    mov dword esp, kernel_stack+KERNEL_STACK_SIZE

    push 0
    call fb_move_cursor_pos         ; initialise the cursor at the position 0
    call fb_clear                   ; clear the framebuffer
    call kmain

.loop:
    jmp .loop                       ; loop forever
