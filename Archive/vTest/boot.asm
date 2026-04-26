org 0x7C00
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    mov [boot_drive], dl

    mov ax, 0x0000
    mov es, ax
    mov bx, 0x8000          ; destination stage2

    mov ah, 0x02            ; read sectors
    mov al, 8               ; nombre de secteurs à lire (adapter si stage2>512)
    mov ch, 0
    mov cl, 2               ; secteur 2
    mov dh, 0
    mov dl, [boot_drive]
    int 13h
    jc disk_error


    mov si, suc_msg

    printsuccess:
        lodsb
        or al, al
        jz donePrintsuccess
        mov ah, 0x0E
        int 10h
        jmp printsuccess
    donePrintsuccess:
        jmp 0x0000:0x8000       ; saute à stage2

disk_error:
    mov si, err_msg
.print:
    lodsb
    or al, al
    jz halt
    mov ah, 0x0E
    int 0x10
    jmp .print

halt:
    cli
    hlt

boot_drive: db 0
err_msg: db "Disk read error, failed to Load SMOS!",0
suc_msg: db "Loading SMOS. Please Wait..."

times 510-($-$$) db 0
dw 0xAA55
