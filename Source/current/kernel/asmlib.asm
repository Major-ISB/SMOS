bits 16

section .text

global cprint

cprint:
    lodsb
    or al, al
    jz .cp_done
    mov ah, 0x0E
    int 0x10
    jmp cprint

.cp_done:
    ret
