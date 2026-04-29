;; kernel_entry.asm => kernel.c loader

bits 32
section .text
    align 4
    dd 0x1BADB002
    dd 0x00
    dd - (0x1BADB002 + 0x00)

global _start
extern kmain

_start:
    cli
    mov esp, stack_top
    call kmain
    jmp $

%include "libs/asmlib.asm"

section .bss
align 16
stack_bottom:
    resb 16384
stack_top:
