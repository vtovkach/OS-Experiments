ASM := nasm
ASMFLAGS :=

SRC_DIR  := src
BIN_DIR  := bin
DISK_DIR := disk

STAGE1 := boot_s1
STAGE2 := boot_s2
KERNEL := mini_kernel

# Disk layout
SECTOR_SIZE    := 512
STAGE2_SECTORS := 32
KERNEL_SECTORS := 32
TOTAL_SECTORS  := 65   # 1 + stage2(32) + kernel(32)

IMG := $(DISK_DIR)/disk.img

QEMU := qemu-system-i386

CC := gcc
LD := ld
OBJCOPY := objcopy
CFLAGS := -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -nostdlib
LDFLAGS := -m elf_i386 -T kernel.ld

all: image

# Directories
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(DISK_DIR):
	mkdir -p $(DISK_DIR)

# -------------------------
# Stage 1 (boot sector)
# -------------------------
$(BIN_DIR)/$(STAGE1).bin: $(SRC_DIR)/$(STAGE1).asm | $(BIN_DIR)
	$(ASM) -f bin $(ASMFLAGS) $< -o $@

# -------------------------
# Stage 2 (flat binary)
# -------------------------
$(BIN_DIR)/$(STAGE2).bin: $(SRC_DIR)/$(STAGE2).asm | $(BIN_DIR)
	$(ASM) -f bin $(ASMFLAGS) $< -o $@

# -------------------------
# Mini kernel (C -> ELF -> flat binary)
# -------------------------
$(BIN_DIR)/$(KERNEL).o: $(SRC_DIR)/$(KERNEL).c | $(BIN_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/$(KERNEL).elf: $(BIN_DIR)/$(KERNEL).o kernel.ld | $(BIN_DIR)
	$(LD) $(LDFLAGS) -o $@ $(BIN_DIR)/$(KERNEL).o

$(BIN_DIR)/$(KERNEL).bin: $(BIN_DIR)/$(KERNEL).elf | $(BIN_DIR)
	$(OBJCOPY) -O binary $< $@

# -------------------------
# Disk image
# -------------------------
image: $(IMG)

$(IMG): $(BIN_DIR)/$(STAGE1).bin $(BIN_DIR)/$(STAGE2).bin $(BIN_DIR)/$(KERNEL).bin | $(DISK_DIR)
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=$(TOTAL_SECTORS)
	dd if=$(BIN_DIR)/$(STAGE1).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=0
	dd if=$(BIN_DIR)/$(STAGE2).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=1 count=$(STAGE2_SECTORS)
	dd if=$(BIN_DIR)/$(KERNEL).bin of=$@ bs=$(SECTOR_SIZE) conv=notrunc seek=33 count=$(KERNEL_SECTORS)

run: image
	$(QEMU) -drive format=raw,file=$(IMG)

clean:
	rm -rf $(BIN_DIR) $(DISK_DIR)

.PHONY: all image run clean
