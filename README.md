# OS-Build: Simple Operating System from Scratch

![Assembly](https://img.shields.io/badge/language-Assembly-blue)
![C](https://img.shields.io/badge/language-C-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

This project documents the step-by-step creation of a simple operating system from scratch, inspired by [nanobyte's tutorial series](https://www.youtube.com/playlist?list=PLFjM7v6KGMpiH2G-kT781ByCNC_0pKpPN). It covers bootloader development, kernel implementation in assembly, FAT file system utilities in C, and testing in emulators.

> **⚠️ Important:** All files are located inside the `\OS-Build` directory. You must navigate there before running any commands:
>
> cd D:\OS-Build

## Quick Start

**Step 1:** Navigate to the project directory

```
cd \OS-Build
```

**Step 2:** Build the OS

```
make all
```

**Step 3:** Run the OS in Bochs

```
./run.sh
```

**Optional:** Clean previous builds

```
make clean
```

> **Note:** Run each command separately. Do not chain multiple commands together.

---

## Project Structure

OS-Build
│   .gitignore          # Git ignore rules
│   bochs_config        # Bochs emulator configuration
│   debug.sh            # Debugging helper script
│   LICENSE             # Project license
│   Makefile            # Top-level build script
│   README.md           # This file
│   run.sh              # Run OS in emulator
│   test.txt            # Temporary test file
│
├───osdev
│   │   Makefile        # Build script for OS components
│   │
│   ├───build
│   │       main.bin            # Compiled OS binary
│   │       main_floppy.img     # Bootable floppy image
│   │
│   └───src
│           main.asm     # Entry point assembly code
│
├───src
│   ├───bootloader
│   │       boot.asm     # Bootloader code
│   │
│   └───kernel
│           main.asm     # Kernel code
│
└───tools
└───fat
fat.c        # FAT filesystem utility

---

## Installation / Prerequisites

This project assumes a Linux-based environment (native or WSL) and the following tools:

* `nasm` – assembler for x86 code
* `dd` or `bximage` – for creating floppy images
* `bochs` or `qemu` – for emulator testing
* `make` – for build automation

### Optional: Install dependencies on Ubuntu/WSL

```
sudo apt update
sudo apt install nasm bochs qemu make gcc
```

---

## Usage

All commands assume you are in `D:\OS-Build`.

### Build the OS

```
make all
```

This performs:

* Assembly of bootloader and kernel
* Compilation of FAT utilities
* Creation of bootable floppy image in `osdev/build/main_floppy.img`

### Run in Emulator

```
./run.sh
```

* Starts Bochs with the configured floppy image
* Use `debug.sh` to help diagnose kernel or bootloader issues

### Clean Build Artifacts

```
make clean
```

Removes binaries, floppy images, and temporary build files.

---

## Modular Components

### 1. Bootloader (`src/bootloader/boot.asm`)

* Entry point of the OS
* Initializes CPU and memory
* Loads kernel into memory

### 2. Kernel (`src/kernel/main.asm`)

* Handles basic OS functionality
* Outputs messages to screen
* Prepares system for further extensions

### 3. FAT Utility (`tools/fat/fat.c`)

* Reads/writes FAT filesystem
* Used for loading data/files from disk

### 4. OSDev Build (`osdev/Makefile`)

* Handles compilation of assembly and C components
* Generates binary and bootable floppy images

### 5. Emulator Scripts

* `run.sh` – launches Bochs
* `debug.sh` – assists with debugging and logging

---

## Design Decisions

* **Assembly + C:** Bootloader and kernel in assembly, file utilities in C for readability and portability.
* **Modular Makefiles:** Each folder has its own Makefile to simplify compilation.
* **Floppy-first design:** Using floppy image ensures compatibility with Bochs and QEMU.
* **Debugging-ready:** Scripts and logs simplify troubleshooting.

---

## Troubleshooting

* **Bochs fails to start:** Verify `bochs` installation and config in `bochs_config`.
* **File not found:** Ensure you are in `D:\OS-Build` before executing scripts.
* **Kernel crashes/loops:** Use `debug.sh` and check `osdev/build/main.bin` for compilation issues.
* **Permissions errors:** On Linux, make scripts executable:

  chmod +x run.sh debug.sh

---

## License

This project is licensed under the MIT License. See `LICENSE` for details.
