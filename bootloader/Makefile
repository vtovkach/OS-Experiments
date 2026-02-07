ASM := nasm
CC := gcc
LD := ld
OBJCOPY := objcopy

SRC := src
BIN := bin
DISK := disk

S1 := boot_s1
S2 := boot_s2
K  := mini_kernel

BS := 512
S2_SECT := 10
K_SECT  := 12
IMG := $(DISK)/disk.img
LDS := kernel.ld

CFLAGS := -m32 -ffreestanding -fno-pie -fno-pic -fno-stack-protector -O2
LDFLAGS := -m elf_i386 -T $(LDS) -nostdlib

all: image

$(BIN) $(DISK):
	mkdir -p $@

$(BIN)/$(S1).bin: $(SRC)/$(S1).asm | $(BIN)
	$(ASM) -f bin $< -o $@

$(BIN)/$(S2).bin: $(SRC)/$(S2).asm | $(BIN)
	$(ASM) -f bin $< -o $@

$(BIN)/$(K).o: $(SRC)/$(K).c | $(BIN)
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN)/$(K).elf: $(BIN)/$(K).o $(LDS)
	$(LD) $(LDFLAGS) -o $@ $<

$(BIN)/$(K).bin: $(BIN)/$(K).elf
	$(OBJCOPY) -O binary $< $@

image: $(IMG)

$(IMG): $(BIN)/$(S1).bin $(BIN)/$(S2).bin $(BIN)/$(K).bin | $(DISK)
	dd if=/dev/zero of=$@ bs=$(BS) count=$$((1+$(S2_SECT)+$(K_SECT)))
	dd if=$(BIN)/$(S1).bin of=$@ bs=$(BS) conv=notrunc seek=0
	dd if=$(BIN)/$(S2).bin of=$@ bs=$(BS) conv=notrunc seek=1 count=$(S2_SECT)
	dd if=$(BIN)/$(K).bin  of=$@ bs=$(BS) conv=notrunc seek=$$((1+$(S2_SECT))) count=$(K_SECT)

run: image
	qemu-system-i386 -drive format=raw,file=$(IMG)

clean:
	rm -rf $(BIN) $(DISK)

.PHONY: all image run clean
