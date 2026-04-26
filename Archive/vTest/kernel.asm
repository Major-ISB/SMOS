; ============================================================
;  BOOT SECTOR DEMONSTRATION PROGRAM
;  TARGET MACHINE : IBM PC / COMPATIBLE
;  MODE           : REAL MODE, 16 BITS
;  LOAD ADDRESS   : 0000:7C00
; ============================================================

ORG     0x8000          ; BIOS LOAD ADDRESS
BITS    16              ; 16 BIT INSTRUCTIONS

; ------------------------------------------------------------
;  INITIAL SYSTEM SETUP
; ------------------------------------------------------------

MOV     AX, 0           ; INITIALISE SEGMENTS
MOV     DS, AX
MOV     ES, AX
MOV     SS, AX          ; STACK SEGMENT
MOV     SP, 0x8000      ; STACK GROWS DOWNWARD

CALL    clearScreen

MOV     SI, welcome     ; DISPLAY WELCOME MESSAGE
CALL    print_string

; ------------------------------------------------------------
; Constants
; ------------------------------------------------------------

BLOC_SIZE        equ 64 ; Size of 1 bloc in bytes
BLOC_COUNT       equ 32 ; Number of total blocs
FAT_FREE         equ 0x0000 ; Free block
FAT_EOF          equ 0xFFFF ; End Of File

; ------------------------------------------------------------
;  MAIN COMMAND LOOP
; ------------------------------------------------------------

mainloop:
    call init
    
    lodsb
    cmp al, 's'
    jne handle_command

    lodsb
    cmp al, 'u'
    jne handle_command

    lodsb
    cmp al, 'p'
    jne handle_command

    mov byte [allowed], 1
    
    mov si, buffer
    add si, 4
    mov [buffer_ptr], si
    
    jmp handle_command

init:
    mov byte [allowed], 0

    ; mov si, lineRetStr
    ; call print_string
    
    MOV     SI, prompt
    CALL    print_string

    MOV     DI, buffer
    CALL    get_string

    mov si, buffer
    mov [buffer_ptr], si
    ret

handle_command:
    MOV     SI, [buffer_ptr]
    CMP     BYTE [SI], 0        ; EMPTY LINE ?
    JE      mainloop            ; IGNORE IF SO

    MOV     SI, [buffer_ptr]
    MOV     DI, cmd_shutdown    ; COMMAND : SHUTDOWN
    CALL    strcmp
    JC      shutdowncmd

    MOV     SI, [buffer_ptr]
    MOV     DI, cmd_restart     ; COMMAND : RESTART
    CALL    strcmp
    JC      restartcmd

    MOV     SI, [buffer_ptr]
    MOV     DI, cmd_clear       ; COMMAND : CLEAR
    CALL    strcmp
    JC      clearcmd

    MOV     SI, [buffer_ptr]
    MOV     DI, cmd_time        ; COMMAND : TIME
    CALL    strcmp
    JC      printtime

    MOV     SI, [buffer_ptr]
    MOV     DI, cmd_returnVersion
    CALL    strcmp
    JC      returnVersionCmd

    mov si, [buffer_ptr]
    
    lodsb
    cmp al, 's'
    je check_sv

    cmp al, 'l'
    je check_ld

    MOV     SI, badcommand
    CALL    print_string
    JMP     mainloop

check_sv:
    lodsb
    cmp al, 'v'
    je storeCmd
    jmp badCmd

check_ld:
    lodsb
    cmp al, 'd'
    je loadCmd
    jmp badCmd

badCmd:
    mov si, badcommand
    call print_string
    jmp mainloop

; ------------------------------------------------------------
;  COMMAND HANDLERS
; ------------------------------------------------------------

loadCmd:
    lodsb
    call parse_number
    mov si, cx
    
    call print_string
    call lineReturning
    jmp mainloop

storeCmd:
    cmp byte [allowed], 0
    je perms_denied_msg
        
    lodsb
    call parse_number
    mov di, cx

    cpy_loop:
        lodsb
        stosb

        test al, al
        jnz cpy_loop
        
    jmp mainloop

perms_denied_msg:
    mov si, perms_denied
    call print_string
    jmp mainloop

returnVersionCmd:
    MOV SI, msg_returnVersion
    CALL print_string
    JMP mainloop

shutdowncmd:
    MOV     SI, msg_shutdown
    CALL    print_string
    JMP     halt_all

restartcmd:
    MOV     SI, msg_restart
    CALL    print_string
    CALL    clearScreen
    JMP     0x7C00

clearcmd:
   CALL     clearScreen
   JMP      mainloop

printtimeh:
   MOV      AH, 02h
   int 1Ah

   ; Afficher les heures (CH)
   mov al, ch
   call display_bcd
   ret

printtimem:
   mov ah, 02h
   int 1Ah

   mov al,cl
   call display_bcd
   ret

printtimes:
   mov ah, 02h
   int 1Ah

   mov al, dh
   call display_bcd
   ret

printtime:
   call printtimeh
   mov si, timeSeparator
   call print_string
   
   call printtimem
   mov si, timeSeparator
   call print_string
   
   call printtimes
   
   call lineReturning
   
display_bcd:
    ; AL contient la valeur BCD (ex: 0x12 pour 12)
    mov bh, al       ; Copie dans BH
    and al, 0x0F     ; AL = unités (garder les 4 bits bas)
    shr bh, 4        ; BH = dizaines (shift 4 bits à droite)
    
    ; Convertir en ASCII
    add bh, '0'      ; Dizaine en ASCII
    add al, '0'      ; Unité en ASCII
    
    ; Mettre dans le buffer
    mov [buffertime], bh
    mov [buffertime+1], al
    mov byte [buffertime+2], 0  ; Null terminator
    
    ; Afficher
    mov si, buffertime
    call print_string
    ret

clearScreen:
    PUSHA

    ;clear screen
    MOV    AX, 0x0700        ;function 07, AL=0 means scroll whole window
    MOV    BH, 0x07          ;character attribute = white on black
    MOV    CX, 0x0000        ;row = 0, col=0
    MOV    DX, 0x184F        ;row = 24 (0x18), col = 79 (0x4F)
    int 0x10                 ;BIOS video interrupt

    ;set cursor position to (0, 0)
    MOV    DX, 0x0000
    MOV    BH, 0x00          ;page 0
    MOV    AH, 0x02          ;set cursor position
    int 0x10                 ;BIOS video interrupt

    POPA
    RET

lineReturning:
    MOV SI, lineRetStr
    CALL print_string
    JMP mainloop

;; Convert the pointed string written number into a real number, exemple '256' to 256
;; Assuming SI points to the first digit (eg.: '2')
;; The result is stored in cx
parse_number:
    xor cx, cx

.loop:
    lodsb
    cmp al, ' '
    je .skip
    cmp al, 0
    je .skip

    sub al, '0' ; Convert to number
    imul cx, 10
    xor ah, ah
    add cx, ax
    jmp .loop

.skip:
    ret

; ============================================================
;  STATIC DATA AREA
; ============================================================

; ------------------------------------------------------------
;  GENERAL VALUEES
; ------------------------------------------------------------

welcome    db "  ____    __  __    _____    ____  ",13,10
           db " / ___|  |  \/  |  /  _  \  / ___| ",13,10
           db " \___ \  | |\/| | |  | |  | \___ \ ",13,10
           db "  ___) | | |  | | |  |_|  |  ___) |",13,10
           db " |____/  |_|  |_|  \_____/  |____/ ",13,10
           db " ",13,10
           db "Lycee Saint Marc (C). SMOS Corp",13,10
           db " ",13,10
           db "Welcome on SMOS ! Type <help> to have more informations.",13,10,0
           
badcommand      DB  'Bad command entered.',0x0D,0x0A,0
prompt          DB  '>> ',0
lineRetStr:     DB  '',0x0D,0x0A,0

; ------------------------------------------------------------
;  Shutdown  COMMAND
; ------------------------------------------------------------

cmd_shutdown    DB  'endall',0
msg_shutdown    DB  'Shutdowning system...',0x0D,0x0A,0

; ------------------------------------------------------------
; Restart COMMAND
; ------------------------------------------------------------

cmd_restart     DB 'restart',0
msg_restart     DB 'Restarting system...',0x0D,0x0A,0

; ------------------------------------------------------------
; Clear COMMAND
; ------------------------------------------------------------

cmd_clear       DB 'clear',0

; ------------------------------------------------------------
; Time COMMAND
; ------------------------------------------------------------

cmd_time       DB 'gettime',0
buffertime:    TIMES 3  DB 0
timeSeparator: db ':',0

; ------------------------------------------------------------
; Version COMMAND
; ------------------------------------------------------------

cmd_returnVersion: DB 'getversion',0
msg_returnVersion: DB 'Version: Ultra Beta',0x0D,0x0A,0

; ------------------------------------------------------------
; File Allocation Tables
; ------------------------------------------------------------

fat         times 32   dw 0 ; The FAT, 32 words (2 bytes)
repertories times 160  db 0 ; 10 files x 16 bytes
blocs       times 2048 db 0 ; 32 x 64 bytes of data

; ------------------------------------------------------------
; Buffer
; ------------------------------------------------------------

buffer          TIMES 64 DB 0

; ------------------------------------------------------------
; User system
; ------------------------------------------------------------

;; Super user systems
super_usr_passwd: db 'usatoday2025', 0
super_usr_dialog: db 'Password for SUPER: ', 0
perms_denied: db 'Permissions denied', 0x0D, 0x0A, 0
allowed db 0
buffer_ptr: dw 0

; ============================================================
;  SUBROUTINES
; ============================================================

; ------------------------------------------------------------
;  PRINT ZERO-TERMINATED STRING (SI)
; ------------------------------------------------------------

print_string:
    LODSB                   ; LOAD CHARACTER
    OR      AL, AL
    JZ      ps_done

    MOV     AH, 0x0E
    INT     0x10             ; TELETYPE OUTPUT
    JMP     print_string

ps_done:
    RET

; ------------------------------------------------------------
;  READ LINE FROM KEYBOARD INTO BUFFER (DI)
; ------------------------------------------------------------

get_string:
    XOR     CL, CL

gs_loop:
    MOV     AH, 0
    INT     0x16             ; WAIT FOR KEY

    CMP     AL, 0x08
    JE      gs_backspace

    CMP     AL, 0x0D
    JE      gs_done

    CMP     CL, 0x3F
    JE      gs_loop

    MOV     AH, 0x0E
    INT     0x10

    STOSB
    INC     CL
    JMP     gs_loop

gs_backspace:
    CMP     CL, 0
    JE      gs_loop

    DEC     DI
    MOV     BYTE [DI], 0
    DEC     CL

    MOV     AH, 0x0E
    MOV     AL, 0x08
    INT     0x10

    MOV     AL, ' '
    INT     0x10

    MOV     AL, 0x08
    INT     0x10

    JMP     gs_loop

gs_done:
    MOV     AL, 0
    STOSB

    MOV     AH, 0x0E
    MOV     AL, 0x0D
    INT     0x10
    MOV     AL, 0x0A
    INT     0x10

    RET

; ------------------------------------------------------------
;  STRING COMPARE (SI vs DI)
;  RETURNS : CARRY SET IF EQUAL
; ------------------------------------------------------------

strcmp:
sc_loop:
    MOV     AL, [SI]
    MOV     BL, [DI]
    CMP     AL, BL
    JNE     sc_notequal

    CMP     AL, 0
    JE      sc_done

    INC     SI
    INC     DI
    JMP     sc_loop

sc_notequal:
    CLC
    RET

sc_done:
    STC
    RET

halt_all:
    CLI
    HLT
