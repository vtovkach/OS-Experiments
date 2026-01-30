
org 0x7c00 
bits 16 

; Initialize CS:IP
cs_init:
    jmp 0x0000:start

start:
    ; Initialize Memory Segments 
    cli 
    xor ax, ax 
    mov ds, ax 
    mov es, ax 
    mov ss, ax 
    mov sp, 0x7c00 
    sti

    ; enable text mode 80x25 
    mov ax, 0x0003
    int 0x10 

    mov si, success_msg

verify_boot:
    cld 
    lodsb 
    test al, al 
    jz a20_disable_fast
    mov ah, 0x0E
    mov bh, 0x00 
    int 0x10 
    jmp verify_boot

a20_disable_fast:
    in   al, 0x92
    and  al, 0xFD        ; clear bit 1 (A20)
    ; keep bit 0 as-is (important)
    out  0x92, al
    
check_a20:
    pushf 
    push ds
    push es
    push di
    push si 

    cli 

    xor ax, ax 
    mov es, ax

    not ax ; ax -> 0xFFFF
    mov ds, ax 

    mov di, 0x0500
    mov si, 0x0510

    mov al, byte [es:di]
    push ax 

    mov al, byte [ds:si]
    push ax 

    mov byte [es:di], 0x00
    mov byte [ds:si], 0xff 
    
    cmp byte [es:di], 0xff 

    pop ax 
    mov [ds:si], al 

    pop ax 
    mov [es:di], al 

    mov ax, 0 
    je check_a20_exit

    mov ax, 1 

check_a20_exit:
    pop si 
    pop di
    pop es 
    pop ds
    popf 

    cmp ax, 1
    mov si, a20_ne_msg
    jne a20_not_enabled

    mov si, a20_e_msg

a20_enabled:
    cld
    lodsb 
    test al, al 
    jz done 
    mov ah, 0x0e
    mov bh, 0x00 
    int 0x10 
    jmp a20_enabled

a20_not_enabled:
    cld
    lodsb 
    test al, al 
    jz done 
    mov ah, 0x0e
    mov bh, 0x00 
    int 0x10 
    jmp a20_not_enabled

done: 
    jmp $

; Message to indicate successful boot 
success_msg:
    db "Boot Success", 0 
a20_e_msg:
    db "A20 address line is enabled", 0
a20_ne_msg:
    db "A20 is not enabled", 0

; Boot signature 
times 510-($-$$) db 0 
dw 0xAA55