org 0x7C00
bits 16

jmp short start
nop

; ---------------------------------------
; BIOS Parameter Block (BPB)
bdb_oem:                        db 'MSWIN4.1'
bdb_bytes_per_sector:           dw 512
bdb_sectors_per_cluster:        db 1
bdb_reserved_sectors:           dw 1
bdb_fat_count:                  db 2
bdb_dir_entries_count:          dw 0E0h    
bdb_total_sectors:              dw 2880
bdb_media_descriptor_type:      db 0F0h
bdb_sectors_per_fat:            dw 9
bdb_sectors_per_track:          dw 18
bdb_heads:                      dw 2
bdb_hidden_sectors:             dd 0
bdb_large_sector_count:         dd 0

; Extended Boot Record (EBR)
ebr_drive_number:               db 0
                                db 0
ebr_signature:                  db 29h
ebr_volume_id:                  db 12h, 34h, 56h, 78h
ebr_volume_label:               db 'CORY OS   '     ; 11 bytes
ebr_system_id:                  db 'FAT12   '       ; 8 bytes

; ---------------------------------------
start:
    jmp main

; ---------------------------------------
; Print null-terminated string at SI
puts:
    cld                 ; Ensure string is read forward
    push si
    push ax
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    pop ax
    pop si
    ret

; ---------------------------------------
; Main entry point
main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [ebr_drive_number], dl   ; Store boot drive number

    mov ax, 1                    ; LBA = 1 (first sector after bootloader)
    mov bx, 0x7E00               ; Destination buffer
    mov al, 1                    ; Number of sectors to read
    call disk_read

    ; Success - show hello message
    mov si, msg_hello
    call puts

.halt:
    cli
    hlt
    jmp .halt

; ---------------------------------------
; Wait for key and reboot
wait_key_and_reboot:
    mov ah, 0
    int 16h
    jmp 0FFFFh:0

; ---------------------------------------
; Disk read failed
floppy_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

; ---------------------------------------
; Convert LBA to CHS
; Input: AX = LBA
; Output: CH = cylinder, DH = head, CL = sector
lba_to_chs:
    push ax
    push dx

    xor dx, dx
    div word [bdb_sectors_per_track] ; AX / SectorsPerTrack
    inc dx                           ; Sector number starts from 1
    mov cx, dx                       ; CL = sector

    xor dx, dx
    div word [bdb_heads]            ; AX / Heads
    mov dh, dl                      ; DH = head
    mov ch, al                      ; CH = cylinder
    shl ah, 6
    or cl, ah                       ; Set top 2 bits of cylinder into CL

    pop dx
    pop ax
    ret

; ---------------------------------------
; Disk read
; AX = LBA
; AL = number of sectors to read
; BX = buffer address
disk_read:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    call lba_to_chs

    ; DL = drive (already set)
    ; CH, CL, DH = CHS
    ; AL = number of sectors
    ; ES:BX = buffer
    mov di, 3               ; Retry count
.retry:
    pusha
    mov ah, 0x02            ; INT 13h function 02 - Read sectors
    mov dl, [ebr_drive_number]
    int 13h
    jnc .done               ; Jump if no carry (successful)

    popa
    call disk_reset
    dec di
    test di, di
    jnz .retry

.fail:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    jmp floppy_error

.done:
    popa
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ---------------------------------------
; Reset disk controller
disk_reset:
    pusha
    mov ah, 0
    mov dl, [ebr_drive_number]
    int 13h
    popa
    ret

; ---------------------------------------
; Messages
msg_hello            db 'Hello world!', 0x0D, 0x0A, 0
msg_read_failed      db 'Read from disk failed!', 0x0D, 0x0A, 0

; ---------------------------------------
; Boot signature
times 510-($-$$) db 0
dw 0xAA55
