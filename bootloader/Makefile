ASM := nasm
ASMFLAGS :=

SRC_DIR  := src
BIN_DIR  := bin
DISK_DIR := disk
OBJ_DIR  := obj

STAGE1 := boot_s1
STAGE2 := boot_s2
KERNEL := kernel

# Disk layout
SECTOR_SIZE    := 512
STAGE2_SECTORS := 12
KERNEL_SECTORS := 20
TOTAL_SECTORS  := 33   # 1 + stage2(12) + kernel(20)

# REAL TARGET DISK (DANGEROUS!)
# Use the whole device, e.g. /dev/sdb (NOT /dev/sdb1)
DEV ?= /dev/sda

ASM := nasm
CC := gcc
LD := ld
OBJCOPY := objcopy

CFLAGS := -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -nostdlib
LDFLAGS := -m elf_i386 -T kernel.ld

# -------------------------
# Default: build + flash to real disk
# -------------------------
all: flash

# Directories
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(DISK_DIR):
	mkdir -p $(DISK_DIR)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

# -------------------------
# Stage 1 (boot sector)
# -------------------------
$(BIN_DIR)/$(STAGE1).bin: $(SRC_DIR)/$(STAGE1).asm | $(BIN_DIR)
	$(ASM) -f bin $(ASMFLAGS) $< -o $@

# -------------------------
# Stage 2 (flat binary, padded to STAGE2_SECTORS)
# -------------------------
$(BIN_DIR)/$(STAGE2).bin: $(SRC_DIR)/$(STAGE2).asm | $(BIN_DIR)
	$(ASM) -f bin $(ASMFLAGS) $< -o $@
	truncate -s $$(( $(SECTOR_SIZE) * $(STAGE2_SECTORS) )) $@

# -------------------------
# Kernel (ELF + flat bin, padded to KERNEL_SECTORS)
# -------------------------
$(OBJ_DIR)/kernel_entry.o: $(SRC_DIR)/kernel/kernel_entry.asm | $(OBJ_DIR)
	$(ASM) -f elf32 $(ASMFLAGS) $< -o $@

$(OBJ_DIR)/mini_kernel.o: $(SRC_DIR)/kernel/mini_kernel.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/$(KERNEL).elf: $(OBJ_DIR)/kernel_entry.o $(OBJ_DIR)/mini_kernel.o kernel.ld | $(BIN_DIR)
	$(LD) $(LDFLAGS) $(OBJ_DIR)/kernel_entry.o $(OBJ_DIR)/mini_kernel.o -o $@

$(BIN_DIR)/$(KERNEL).bin: $(BIN_DIR)/$(KERNEL).elf | $(BIN_DIR)
	$(OBJCOPY) -O binary $< $@
	truncate -s $$(( $(SECTOR_SIZE) * $(KERNEL_SECTORS) )) $@

# -------------------------
# Flash to real disk ONLY (no QEMU, no disk.img)
# Writes ONLY the first TOTAL_SECTORS sectors, leaving the rest of the disk unchanged.
# -------------------------
flash: $(BIN_DIR)/$(STAGE1).bin $(BIN_DIR)/$(STAGE2).bin $(BIN_DIR)/$(KERNEL).bin
	@echo "=== DANGER ==="
	@echo "About to write the boot image to: $(DEV)"
	@echo "This will overwrite the first $(TOTAL_SECTORS) sectors ($(shell expr $(TOTAL_SECTORS) \* $(SECTOR_SIZE)) bytes)."
	@echo "Use a whole-disk device like /dev/sdb (NOT /dev/sdb1)."
	@echo "=============="
	sudo dd if=$(BIN_DIR)/$(STAGE1).bin of=$(DEV) bs=$(SECTOR_SIZE) conv=fsync seek=0 status=progress
	sudo dd if=$(BIN_DIR)/$(STAGE2).bin of=$(DEV) bs=$(SECTOR_SIZE) conv=fsync seek=1 status=progress
	sudo dd if=$(BIN_DIR)/$(KERNEL).bin of=$(DEV) bs=$(SECTOR_SIZE) conv=fsync seek=13 status=progress
	sync

clean:
	rm -rf $(BIN_DIR) $(DISK_DIR) $(OBJ_DIR)

.PHONY: all flash clean
