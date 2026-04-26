[bits 16]

[extern kmain]
[global _start]

_start:
    ; After jump CS=0x1000. Updating stack
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFF

    call kmain

%include "asmlib.asm"
