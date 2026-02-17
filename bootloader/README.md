# Naiad Bootloader

## Overview

This is a two-stage x86 BIOS bootloader written in NASM. It transitions the system from 16-bit Real Mode into 32-bit Protected Mode and loads a kernel at a predefined physical address. 

---

## Architecture

### Stage 1 (Boot Sector – 512 bytes, loaded at `0x7C00`)

**Responsibilities:**

- Initialize segment registers and stack
- Enable 80×25 text mode
- Print boot status messages using BIOS interrupt `0x10`
- Check the A20 address line
- Load Stage 2 from disk using BIOS interrupt `0x13`
- Preserve boot drive number
- Transfer control to Stage 2 (`0x0000:0x7E00`)

**Characteristics:**

- Uses CHS disk reads
- Performs A20 validation
- Strict 512-byte size constraint

---

### Stage 2 (Loaded at `0x7E00`)

**Responsibilities:**

- Preserve boot drive information
- Retrieve system memory map via BIOS `INT 0x15, E820`
- Load kernel to physical address `0x00009600`
- Construct Global Descriptor Table (GDT)
- Switch CPU to 32-bit Protected Mode
- Pass E820 memory information to the kernel
- Jump to kernel entry point

---

## Memory Layout

| Component        | Address       |
|------------------|---------------|
| Boot Sector      | `0x00007C00`  |
| Stage 2          | `0x00007E00`  |
| Kernel           | `0x00009600`  |
| GDT              | `0x0000BE00`  |
| E820 Buffer      | Below 1MB     |
| VGA Text Memory  | `0x000B8000`  |

All components are loaded below 1MB to comply with BIOS real mode constraints.

---

## Protected Mode Transition

The bootloader performs the standard protected mode switch sequence:

1. Disable interrupts (`cli`)
2. Build minimal GDT: Null, Kernel Code, Kernel Data descriptors (Later in the kernel init process, TLS and user space descriptors will be loaded).  
3. Load GDT using `lgdt`
4. Set the PE bit in `CR0`
5. Perform a far jump to 32-bit code segment

After switching:

- Data segments are initialized
- Stack is configured
- Screen is cleared via direct VGA memory access
- A confirmation message is written in 32-bit mode
- Execution transfers to the kernel (`0x08:0x00009600`)

---

## Kernel Interface

Upon entering Protected Mode:

- `EAX` → Number of E820 memory entries  
- `EBX` → Pointer to E820 memory map buffer  

This provides the kernel with immediate access to physical memory layout data. 
Physical Memory Manger (PMM), Virtual Memory Manger (VMM) will use e820 data to manage memory.  

---

## Features

- BIOS-compatible design
- A20 detection
- E820 memory map retrieval
- Multi-stage disk loading
- Manual GDT construction
- Clean transition to 32-bit Protected Mode
- Direct VGA output in Protected Mode

---

## Build Requirements

- NASM (flat binary output)
- BIOS-based x86 environment

---

## Notes

- Uses CHS disk reads for now (not LBA)
- Operates entirely below 1MB
