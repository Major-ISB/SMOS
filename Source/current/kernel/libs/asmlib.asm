;;asmlib.asm => usefull functions for kernel.c

bits 32

global outb
global inb

section .text

outb:
    push ebp

    mov ebp, esp
    mov dx, [ebp+8]    ;port
    mov ax, [ebp+12]   ;value

    out dx, al

    pop ebp
    ret

inb:
    push ebp

    mov ebp, esp
    mov dx, [ebp+8]    ;port
    in al, dx
    ;value stored in EAX
    pop ebp
    ret
