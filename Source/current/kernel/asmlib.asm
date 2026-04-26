bits 16
global bprint
section .text

bprint:
    push ebp          ; 32-bit for gcc
    mov  ebp, esp
    push esi

    mov  esi, [ebp+8] ; 1st argument (str)
.loop:
    lodsb
    test al, al
    
    jz   .cp_done
    mov  ah, 0x0E
    int  0x10
    
    jmp  .loop
.cp_done:
    pop  esi
    pop  ebp
    ret
