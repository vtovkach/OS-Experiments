ENTRY(_start)

SECTIONS
{
    . = 0x00009600;
    
    .text   : ALIGN(16) { *(.text*) }
    .rodata : ALIGN(16) { *(.rodata*) }
    .data   : ALIGN(16) { *(.data*) }
    .bss    : ALIGN(16) { *(COMMON) *(.bss*) }

    __kernel_end = .;
}