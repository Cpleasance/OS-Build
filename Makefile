# Assembler and compiler
ASM = nasm
CC = gcc

# Directories
SRC_DIR = src
TOOLS_DIR = tools
BUILD_DIR = build

# Floppy image settings
FLOPPY_IMG = $(BUILD_DIR)/main_floppy.img
BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
FAT_TOOL = $(BUILD_DIR)/tools/fat

# Targets that don't produce files
.PHONY: all floppy_image kernel bootloader clean tools_fat

# Default target
all: floppy_image tools_fat

# Build full floppy image
floppy_image: $(FLOPPY_IMG)

$(FLOPPY_IMG): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "CORYOS" $@
	dd if=$(BOOTLOADER_BIN) of=$@ conv=notrunc
	mcopy -o -b -i $@ $(KERNEL_BIN) "::KERNEL.BIN"

# Build bootloader
bootloader: $(BOOTLOADER_BIN)

$(BOOTLOADER_BIN): $(SRC_DIR)/bootloader/boot.asm | $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# Build kernel
kernel: $(KERNEL_BIN)

$(KERNEL_BIN): $(SRC_DIR)/kernel/main.asm | $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# Build FAT tool
tools_fat: $(FAT_TOOL)

$(FAT_TOOL): $(TOOLS_DIR)/fat/fat.c | $(BUILD_DIR)/tools
	$(CC) -Wall -Wextra -g -o $@ $<

# Create build directories if missing
$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/tools:
	mkdir -p $@

# Clean build files
clean:
	@if [ -d $(BUILD_DIR) ]; then rm -rf $(BUILD_DIR)/*; fi
