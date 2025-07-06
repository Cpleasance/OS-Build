# Assembler
ASM = nasm

# Directories
SRC_DIR = src
BUILD_DIR = build

# Targets that don't produce files
.PHONY: all floppy_image kernel bootloader clean always

# Default target
all: floppy_image

# Build full floppy image
floppy_image: $(BUILD_DIR)/main_floppy.img

# Rule to build the floppy image
$(BUILD_DIR)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "CORYOS" $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main_floppy.img conv=notrunc
	mcopy -o -b -i $(BUILD_DIR)/main_floppy.img $(BUILD_DIR)/kernel.bin "::KERNEL.BIN"

# Build bootloader
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin

# Build kernel
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/kernel/main.asm -f bin -o $(BUILD_DIR)/kernel.bin

# Ensure build directory exists
always:
	mkdir -p $(BUILD_DIR)

# Clean build files
clean:
	rm -rf $(BUILD_DIR)/*
