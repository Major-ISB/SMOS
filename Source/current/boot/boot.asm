[org 0x7C00]
[bits 16]

start_boot:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, load_address

    mov [boot_drive], dl
    sti

times 446 - ($ - $$) db 0
times 64 db 0
dw 0xAA55
