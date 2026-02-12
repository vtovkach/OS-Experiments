
BITS 32 

global _start
global e820_ptr 
global e820_count 

extern kernel_main 

SECTION .data
e820_ptr: dd 0 
e820_count: dd 0 

SECTION .text 
_start:

    ; Clear interrupts flag until implementing IDT 
    cli  

    ; Load a data selector into segment registers from gdt 
    ; INDEX:GDT/LDT:PRIVILEGE (13bits:1bit:2bits)
    mov ax, 0x10 
    mov ds, ax 
    mov es, ax 
    mov ss, ax 
    
    ; Save pointer to the e820 data in memory and e820 count
    mov [e820_count], eax  
    mov [e820_ptr], ebx

    ; Set up stack 
    mov esp, 0x0007FFFF
    mov ebp, esp 

    ; Clear direction bit just in case 
    cld 

    ; Call C Entry 
    call kernel_main

.hang:
    hlt 
    jmp .hang 