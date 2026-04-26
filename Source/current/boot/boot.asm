; boot.asm
[org 0x7C00]
[bits 16]

KERNEL_OFFSET equ 0x0000
KERNEL_SEG    equ 0x1000

mov [BOOT_DRIVE], dl

xor ax, ax
mov es, ax
mov ds, ax
mov bp, 0x9000
mov ss, bp
mov sp, ax

mov bx, KERNEL_SEG
mov es, bx
mov bx, KERNEL_OFFSET

mov ah, 0x02
mov al, 15
mov ch, 0x00
mov dh, 0x00
mov cl, 0x02
mov dl, [BOOT_DRIVE]
int 0x13

jc disk_error

jmp skip_disk_error

disk_error:
    mov si, boot_msg_err
    call boot_print_string
    
    jmp $
    
skip_disk_error:
    mov si, boot_msg
    call boot_print_string

    jmp KERNEL_SEG:KERNEL_OFFSET

boot_print_string:
    lodsb
    or al, al
    jz .boot_ps_done
    mov ah, 0x0E
    int 0x10
    jmp boot_print_string

.boot_ps_done:
    ret

BOOT_DRIVE: db 0

boot_msg: db 'Bootloader loaded', 0
boot_msg_err: db 'Disk error', 0

times 510-($-$$) db 0
dw 0xAA55                 ; Boot signature
