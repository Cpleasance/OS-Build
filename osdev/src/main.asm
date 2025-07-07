; Minimal 16-bit Bootloader: prints "Hello world!" then halts
org 0x7C00
bits 16

start:
    jmp main              ; Jump to main program start

; ------------------------------------------
; puts - print null-terminated string at DS:SI
; Uses BIOS teletype output (INT 0x10, AH=0x0E)
; Preserves SI and AX registers
; ------------------------------------------
puts:
    push si
    push ax

.print_loop:
    lodsb                 ; Load byte at DS:SI into AL and increment SI
    or al, al             ; Check for zero terminator
    jz .done              ; If zero, end string output

    mov ah, 0x0E          ; BIOS teletype function
    int 0x10              ; Print character in AL
    jmp .print_loop

.done:
    pop ax
    pop si
    ret

; ------------------------------------------
; main program entry point
; Setup segments, stack, print message, then halt
; ------------------------------------------
main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00        ; Stack pointer set near code (consider moving lower)

    mov si, msg_hello
    call puts

.halt:
    cli                   ; Disable interrupts once
    hlt                   ; Halt CPU
    jmp .halt             ; Infinite loop

; ------------------------------------------
; Data section
; ------------------------------------------
msg_hello db 'Hello world!', 0x0D, 0x0A, 0

; Pad the rest of the 512-byte boot sector with zeros
times 510 - ($ - $$) db 0

; Boot signature (must be 0xAA55)
dw 0xAA55
