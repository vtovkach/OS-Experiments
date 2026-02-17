# Naiad

Naiad is a custom x86 operating system developed from scratch in C, that will support both BIOS and UEFI boot environments.

## Architecture

- Custom BIOS bootloader
- UEFI bootloader (planned)
- x86 kernel implemented in C
- Early-stage physical and virtual memory management
- Hardware initialization (GDT, IDT, interrupts)

## Goals

- Unified kernel entry for BIOS and UEFI
- Structured memory management (PMM → VMM)
- Modular and maintainable architecture
- Progressive expansion toward a full operating system

## References

- Intel® 64 and IA-32 Architectures Software Developer’s Manual  
- OSDev Wiki  
- x86 Memory Map Documentation
