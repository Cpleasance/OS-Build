# Assembler and compiler
ASM = nasm
CC = gcc

# Directories
SRC_DIR = src
TOOLS_DIR = tools
BUILD_DIR = build
TOOLS_BUILD_DIR = $(BUILD_DIR)/tools

# Floppy image settings
FLOPPY_IMG = $(BUILD_DIR)/main_floppy.img
BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
FAT_TOOL = $(TOOLS_BUILD_DIR)/fat

# Required external tools
REQUIRED_TOOLS = mkfs.fat mcopy dd $(ASM) $(CC)

# Targets that don't produce files
.PHONY: all floppy_image kernel bootloader clean tools_fat check_tools

# Default target
all: check_tools tools_fat floppy_image

# Check if required tools are installed
check_tools:
	@for t in $(REQUIRED_TOOLS); do \
		if ! command -v $$t >/dev/null 2>&1; then \
			echo "Error: $$t is not installed."; exit 1; \
		fi; \
	done

# Build full floppy image
floppy_image: $(FLOPPY_IMG)

$(FLOPPY_IMG): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	@echo "Creating empty floppy image..."
	dd if=/dev/zero of=$@ bs=512 count=2880
	@echo "Formatting image as FAT12..."
	mkfs.fat -F 12 -n "CORYOS" $@
	@echo "Writing bootloader to image..."
	dd if=$(BOOTLOADER_BIN) of=$@ conv=notrunc
	@echo "Copying kernel and test file..."
	mcopy -o -b -i $@ $(KERNEL_BIN) "::KERNEL.BIN"
	mcopy -i $@ test.txt "::test.txt"

# Build bootloader
bootloader: $(BOOTLOADER_BIN)

$(BOOTLOADER_BIN): $(SRC_DIR)/bootloader/boot.asm | $(BUILD_DIR)
	@echo "Assembling bootloader..."
	$(ASM) $< -f bin -o $@

# Build kernel
kernel: $(KERNEL_BIN)

$(KERNEL_BIN): $(SRC_DIR)/kernel/main.asm | $(BUILD_DIR)
	@echo "Assembling kernel..."
	$(ASM) $< -f bin -o $@

# Build FAT tool
tools_fat: $(FAT_TOOL)

$(FAT_TOOL): $(TOOLS_DIR)/fat/fat.c | $(TOOLS_BUILD_DIR)
	@echo "Compiling FAT tool..."
	$(CC) -Wall -Wextra -g -o $@ $<

# Create build directories if missing
$(BUILD_DIR):
	mkdir -p $@

$(TOOLS_BUILD_DIR):
	mkdir -p $@

# Clean build files
clean:
	@if [ -d $(BUILD_DIR) ]; then \
		echo "Cleaning build directory..."; \
		rm -rf $(BUILD_DIR)/*; \
	fi
