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
DEV := /dev/sda

IMG := $(DISK_DIR)/disk.img

QEMU := qemu-system-i386

CC := gcc
LD := ld
OBJCOPY := objcopy
CFLAGS := -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -nostdlib
LDFLAGS := -m elf_i386 -T kernel.ld

# Where the kernel begins on disk
KERNEL_LBA := $$(($(STAGE2_SECTORS) + 1))

all: image

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
	# Ensure exactly 1 sector (512 bytes)
	truncate -s $(SECTOR_SIZE) $@

# -------------------------
# Stage 2 (flat binary, padded)
# -------------------------
$(BIN_DIR)/$(STAGE2).bin: $(SRC_DIR)/$(STAGE2).asm | $(BIN_DIR)
	$(ASM) -f bin $(ASMFLAGS) $< -o $@
	# Pad/trim stage2 to exactly STAGE2_SECTORS
	truncate -s $$(( $(SECTOR_SIZE) * $(STAGE2_SECTORS) )) $@

# -------------------------
# Kernel (ELF + flat bin, padded)
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
# Build the QEMU disk image file (safe)
# -------------------------
image: $(IMG)

$(IMG): $(BIN_DIR)/$(STAGE1).bin $(BIN_DIR)/$(STAGE2).bin $(BIN_DIR)/$(KERNEL).bin | $(DISK_DIR)
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(TOTAL_SECTORS)
	dd if=$(BIN_DIR)/$(STAGE1).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=0
	dd if=$(BIN_DIR)/$(STAGE2).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=1 count=$(STAGE2_SECTORS)
	dd if=$(BIN_DIR)/$(KERNEL).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=$(STAGE2_SECTORS) count=$(KERNEL_SECTORS)
	# ^ note: seek=$(STAGE2_SECTORS) means LBA = 12; but kernel should start at 1+12 = 13
	# Fix: write kernel starting at sector 1 + STAGE2_SECTORS
	dd if=$(BIN_DIR)/$(KERNEL).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=$$((1 + $(STAGE2_SECTORS))) count=$(KERNEL_SECTORS)
	sync

run: $(IMG)
	$(QEMU) -drive format=raw,file=$(IMG)

# -------------------------
# Flash to real hardware (DANGEROUS)
# -------------------------
flash: $(BIN_DIR)/$(STAGE1).bin $(BIN_DIR)/$(STAGE2).bin $(BIN_DIR)/$(KERNEL).bin
	@echo "=== FLASHING TO $(DEV) ==="
	@echo "Stage1 -> LBA 0"
	@echo "Stage2 -> LBA 1..$(STAGE2_SECTORS)"
	@echo "Kernel -> LBA $$((1 + $(STAGE2_SECTORS)))..$$(( $(TOTAL_SECTORS) - 1 ))"
	# Unmount anything on the device (ignore errors)
	sudo umount $(DEV)* 2>/dev/null || true
	# Optional wipe of just our occupied sectors (DESTROYS partition table / FS on that disk)
	sudo dd if=/dev/zero of=$(DEV) bs=$(SECTOR_SIZE) count=$(TOTAL_SECTORS) conv=fsync status=progress
	# Stage 1 -> sector 0
	sudo dd if=$(BIN_DIR)/$(STAGE1).bin of=$(DEV) bs=$(SECTOR_SIZE) conv=notrunc,fsync seek=0 status=progress
	# Stage 2 -> sectors 1..(1+STAGE2_SECTORS-1)
	sudo dd if=$(BIN_DIR)/$(STAGE2).bin of=$(DEV) bs=$(SECTOR_SIZE) conv=notrunc,fsync seek=1 count=$(STAGE2_SECTORS) status=progress
	# Kernel -> starts at sector 1 + STAGE2_SECTORS
	sudo dd if=$(BIN_DIR)/$(KERNEL).bin of=$(DEV) bs=$(SECTOR_SIZE) conv=notrunc,fsync seek=$$((1 + $(STAGE2_SECTORS))) count=$(KERNEL_SECTORS) status=progress
	sync

clean:
	rm -rf $(BIN_DIR) $(DISK_DIR) $(OBJ_DIR)

.PHONY: all image run flash clean
