ASM      := nasm
ASMFLAGS :=

CC       := gcc
CFLAGS   := -m16 -ffreestanding -fno-builtin -fno-pic -fno-stack-protector \
            -fno-asynchronous-unwind-tables -O2 -Wall -Wextra

LD       := ld
LDFLAGS  := -m elf_i386 -nostdlib -T stage2.ld

OBJCOPY  := objcopy

SRC_DIR  := src
BIN_DIR  := bin
DISK_DIR := disk

STAGE1   := boot_s1
STAGE2   := boot_s2
CFILE    := e820_print

# Disk layout parameters
SECTOR_SIZE  := 512
TOTAL_SECTORS := 33          # 1 boot sector + 32 sectors stage2
STAGE2_SECTORS := 32

IMG := $(DISK_DIR)/disk.img

# QEMU
QEMU := qemu-system-i386

all: image

# Directories
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(DISK_DIR):
	mkdir -p $(DISK_DIR)

# -------------------------
# Stage 1 (boot sector) raw
# -------------------------
$(BIN_DIR)/$(STAGE1).bin: $(SRC_DIR)/$(STAGE1).asm | $(BIN_DIR)
	$(ASM) -f bin $(ASMFLAGS) $< -o $@

# ---------------------------------------
# Stage 2: asm + C -> .o -> .elf -> .bin
# ---------------------------------------

# Stage2 ASM object (NOTE: no ORG, but BITS 16 inside file is good)
$(BIN_DIR)/$(STAGE2).o: $(SRC_DIR)/$(STAGE2).asm | $(BIN_DIR)
	$(ASM) -f elf32 $(ASMFLAGS) $< -o $@

# C object
$(BIN_DIR)/$(CFILE).o: $(SRC_DIR)/$(CFILE).c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Linked ELF for stage2 (uses ../stage2.ld)
$(BIN_DIR)/stage2.elf: $(BIN_DIR)/$(STAGE2).o $(BIN_DIR)/$(CFILE).o
	$(LD) $(LDFLAGS) -o $@ $^

# Flat binary stage2
$(BIN_DIR)/stage2.bin: $(BIN_DIR)/stage2.elf
	$(OBJCOPY) -O binary $< $@

# ---------------------------------------
# Disk image: stage1 at LBA0, stage2 at LBA1..LBA32
# stage2 is padded/truncated to exactly 32 sectors
# ---------------------------------------
image: $(IMG)

$(IMG): $(BIN_DIR)/$(STAGE1).bin $(BIN_DIR)/stage2.bin | $(DISK_DIR)
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(TOTAL_SECTORS)
	dd if=$(BIN_DIR)/$(STAGE1).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=0
	dd if=$(BIN_DIR)/stage2.bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=1 count=$(STAGE2_SECTORS)

# Run in QEMU (builds the disk image first)
run: image
	$(QEMU) -drive format=raw,file=$(IMG)

clean:
	rm -rf $(BIN_DIR) $(DISK_DIR)

.PHONY: all image run clean
