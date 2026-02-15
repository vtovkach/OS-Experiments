BITS 32 

extern kmain

global e820_ptr
global e820_count 

SECTION .text
_start:
    
    ; Turn off interrupts until IDT implementation 
    cli 

    ; Load Data Selector 
    mov ax, 0x10 
    mov ds, ax 
    mov es, ax 
    mov ss, ax

    ; Save e820 buffer and count from bootloader 
    mov [e820_ptr], ebx 
    mov [e820_count], eax  

    ; Set up stack 
    mov esp, 0x0007FFFF
    mov ebp, esp 

    ; Clear direction bit 
    cld 

    ; Call Kernel main 
    call kmain 

.hang:
    hlt 
    jmp .hang 

SECTION .data
e820_ptr: dd 0
e820_count: dd 0 