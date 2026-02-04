OUTPUT_FORMAT(elf32-i386)
ENTRY(stage2_start)

SECTIONS
{
  . = 0x7E00;

  .text : { *(.text*) }
  .rodata : { *(.rodata*) }
  .data : { *(.data*) }
  .bss : { *(.bss*) *(COMMON) }
}
