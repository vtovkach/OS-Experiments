# kernel/Makefile
# Builds freestanding 32-bit kernel object files into kernel/obj (no linking)

KERNEL_DIR      := $(CURDIR)
OBJ_DIR         := $(KERNEL_DIR)/obj
INCLUDE_DIR     := $(KERNEL_DIR)/include

# Tools (allow override from parent make)
CC      ?= gcc
NASM    ?= nasm

# Target arch: 32-bit, freestanding, no host libs
CFLAGS  ?= -m32 -ffreestanding -fno-builtin -fno-pic -fno-pie -fno-stack-protector \
           -fno-omit-frame-pointer -O2 -Wall -Wextra -Wno-unused-parameter \
           -I$(INCLUDE_DIR)

# You can add -D flags here if needed:
CPPFLAGS ?=

# NASM output format for 32-bit ELF objects
NASMFLAGS ?= -f elf32

# --- Source discovery (recursive) ---
# Find all C and ASM sources under kernel/
C_SRCS   := $(shell find $(KERNEL_DIR) -type f -name '*.c')
ASM_SRCS := $(shell find $(KERNEL_DIR) -type f \( -name '*.asm' -o -name '*.s' \))

# Map kernel/foo/bar.c -> kernel/obj/foo/bar.o
C_OBJS   := $(patsubst $(KERNEL_DIR)/%.c,$(OBJ_DIR)/%.o,$(C_SRCS))
ASM_OBJS := $(patsubst $(KERNEL_DIR)/%.asm,$(OBJ_DIR)/%.o,$(filter %.asm,$(ASM_SRCS))) \
            $(patsubst $(KERNEL_DIR)/%.s,$(OBJ_DIR)/%.o,$(filter %.s,$(ASM_SRCS)))

OBJS := $(C_OBJS) $(ASM_OBJS)

.PHONY: all objects clean print-sources

all: objects

objects: $(OBJS)

# --- Compile rules ---
# C -> .o
$(OBJ_DIR)/%.o: $(KERNEL_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# NASM .asm -> .o
$(OBJ_DIR)/%.o: $(KERNEL_DIR)/%.asm
	@mkdir -p $(dir $@)
	$(NASM) $(NASMFLAGS) $< -o $@

# GAS-style assembly .s -> .o (optional)
$(OBJ_DIR)/%.o: $(KERNEL_DIR)/%.s
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)

print-sources:
	@echo "C sources:";   printf "  %s\n" $(C_SRCS)
	@echo "ASM sources:"; printf "  %s\n" $(ASM_SRCS)
	@echo "Objects:";     printf "  %s\n" $(OBJS)
