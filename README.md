# OS-Build: Simple Operating System from Scratch

![Assembly](https://img.shields.io/badge/language-Assembly-blue)
![C](https://img.shields.io/badge/language-C-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

A step-by-step guide to building a simple operating system from scratch — inspired by [nanobyte’s tutorial series](https://www.youtube.com/playlist?list=PLFjM7v6KGMpiH2G-kT781ByCNC_0pKpPN).  
This project walks through bootloader development, kernel implementation in Assembly, FAT filesystem utilities in C, and testing in emulators.

> **⚠️ Important:** All files are located inside the `\OS-Build` directory.  
> Before running any commands, navigate there:
>
> ```bash
> cd D:\OS-Build
> ```

---

## Quick Start

**Step 1:** Navigate to the project directory  
```bash
cd \OS-Build
```

**Step 2:** Build the OS  
```bash
make all
```

**Step 3:** Run the OS in Bochs  
```bash
./run.sh
```

**Optional:** Clean previous builds  
```bash
make clean
```

> **Note:** Run each command separately — don’t chain multiple commands together.

---

## Project Structure

```
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
```

---

## Installation & Prerequisites

This project assumes a Linux-based environment (native or WSL) with the following tools installed:

* `nasm` – assembler for x86 code  
* `dd` or `bximage` – for creating floppy images  
* `bochs` or `qemu` – for emulator testing  
* `make` – for build automation  

### Optional: Install Dependencies on Ubuntu/WSL
```bash
sudo apt update
sudo apt install nasm bochs qemu make gcc
```

---

## Usage

All commands assume you’re in `D:\OS-Build`.

### Build the OS
```bash
make all
```
This performs:
* Assembly of bootloader and kernel  
* Compilation of FAT utilities  
* Creation of a bootable floppy image (`osdev/build/main_floppy.img`)

### Run in Emulator
```bash
./run.sh
```
* Starts Bochs with the configured floppy image  
* Use `debug.sh` for troubleshooting kernel or bootloader issues

### Clean Build Artifacts
```bash
make clean
```
Removes binaries, floppy images, and temporary build files.

---

## Modular Components

### 1. Bootloader (`src/bootloader/boot.asm`)
* Entry point of the OS  
* Initializes CPU and memory  
* Loads the kernel into memory  

### 2. Kernel (`src/kernel/main.asm`)
* Handles basic OS functionality  
* Outputs messages to the screen  
* Prepares system for further extensions  

### 3. FAT Utility (`tools/fat/fat.c`)
* Reads and writes FAT filesystem structures  
* Used for loading data/files from disk  

### 4. OSDev Build (`osdev/Makefile`)
* Compiles assembly and C components  
* Generates binary and bootable floppy images  

### 5. Emulator Scripts
* `run.sh` – launches Bochs  
* `debug.sh` – assists with debugging and logging  

---

## Design Decisions

* **Assembly + C:** Bootloader and kernel in Assembly, filesystem utilities in C for clarity and portability.  
* **Modular Makefiles:** Each directory has its own Makefile for maintainability.  
* **Floppy-first design:** Ensures compatibility with Bochs and QEMU.  
* **Debugging-ready:** Includes scripts and logs for troubleshooting.  

---

## Troubleshooting

| Issue | Possible Fix |
|-------|---------------|
| **Bochs fails to start** | Verify `bochs` installation and `bochs_config` settings |
| **File not found** | Ensure you’re in `D:\OS-Build` before running scripts |
| **Kernel crashes/loops** | Use `debug.sh` and check `osdev/build/main.bin` |
| **Permissions errors** | Make scripts executable:<br>`chmod +x run.sh debug.sh` |

---

## License

This project is licensed under the MIT License.  
See `LICENSE` for details.
