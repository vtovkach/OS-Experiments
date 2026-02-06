ASM := nasm
ASMFLAGS :=

SRC_DIR  := src
BIN_DIR  := bin

STAGE1 := boot_s1
STAGE2 := boot_s2

# Disk layout
SECTOR_SIZE    := 512
STAGE2_SECTORS := 32
TOTAL_SECTORS  := 33   # 1 + stage2

# REAL TARGET DISK (DANGEROUS!)
DEV := /dev/sda

all: image

# Directories
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

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
# Write directly to disk
# -------------------------
image: $(BIN_DIR)/$(STAGE1).bin $(BIN_DIR)/$(STAGE2).bin
	# Unmount anything on the device (ignore errors)
	sudo umount $(DEV)* 2>/dev/null || true
	# Optional: wipe first 33 sectors (destroys partition table/filesystems)
	sudo dd if=/dev/zero of=$(DEV) bs=$(SECTOR_SIZE) count=$(TOTAL_SECTORS) conv=fsync
	# Stage 1 -> sector 0
	sudo dd if=$(BIN_DIR)/$(STAGE1).bin of=$(DEV) bs=$(SECTOR_SIZE) conv=notrunc,fsync seek=0
	# Stage 2 -> sectors 1..32
	sudo dd if=$(BIN_DIR)/$(STAGE2).bin of=$(DEV) bs=$(SECTOR_SIZE) conv=notrunc,fsync seek=1 count=$(STAGE2_SECTORS)
	sync

clean:
	rm -rf $(BIN_DIR)

.PHONY: all image clean
