#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

typedef uint8_t bool;
#define true 1
#define false 0

// FAT Boot Sector Structure
typedef struct {
    uint8_t  jmp_instruction[3];
    uint8_t  oem_name[8];
    uint16_t bytes_per_sector;
    uint8_t  sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t  fat_count;
    uint16_t dir_entry_count;
    uint16_t total_sectors;
    uint8_t  media_descriptor_type;
    uint16_t sectors_per_fat;
    uint16_t sectors_per_track;
    uint16_t heads;
    uint32_t hidden_sectors;
    uint32_t total_sectors_large;
    uint8_t  drive_number;
    uint8_t  reserved1;
    uint8_t  boot_signature;
    uint32_t volume_id;
    uint8_t  volume_label[11];
    uint8_t  system_id[8];
} __attribute__((packed)) BootSector;

typedef struct {
    uint8_t  Name[11];  // 8.3 filename format (padded with spaces)
    uint8_t  Attributes;
    uint8_t  _Reserved;
    uint8_t  CreatedTimeTenths;
    uint16_t CreatedTime;
    uint16_t CreatedDate;
    uint16_t AccessedDate;
    uint16_t FirstClusterHigh;
    uint16_t ModifiedTime;
    uint16_t ModifiedDate;
    uint16_t FirstClusterLow;
    uint32_t Size;
} __attribute__((packed)) DirectoryEntry;

BootSector g_BootSector;
uint8_t *g_Fat = NULL;
DirectoryEntry *g_RootDirectory = NULL;

bool readBootSector(FILE *disk) {
    return fread(&g_BootSector, sizeof(g_BootSector), 1, disk) > 0;
}

// Read one or more sectors from disk image into bufferOut
bool readSectors(FILE *disk, uint32_t lba, uint32_t count, void *bufferOut) {
    bool ok = true;
    ok = ok && (fseek(disk, lba * g_BootSector.bytes_per_sector, SEEK_SET) == 0);
    ok = ok && (fread(bufferOut, g_BootSector.bytes_per_sector, count, disk) == count);
    return ok;
}

bool readFat(FILE *disk) {
    g_Fat = (uint8_t *) malloc(g_BootSector.sectors_per_fat * g_BootSector.bytes_per_sector);
    if (!g_Fat) return false;
    return readSectors(disk, g_BootSector.reserved_sectors, g_BootSector.sectors_per_fat, g_Fat);
}

bool readRootDirectory(FILE *disk) {
    uint32_t fat_size = g_BootSector.sectors_per_fat * g_BootSector.fat_count;
    uint32_t lba = g_BootSector.reserved_sectors + fat_size;

    uint32_t size = sizeof(DirectoryEntry) * g_BootSector.dir_entry_count;
    uint32_t sectors = size / g_BootSector.bytes_per_sector;
    if (size % g_BootSector.bytes_per_sector)
        sectors++;  // Round up to cover entire directory

    g_RootDirectory = (DirectoryEntry *) malloc(sectors * g_BootSector.bytes_per_sector);
    if (!g_RootDirectory) return false;

    return readSectors(disk, lba, sectors, g_RootDirectory);
}

// Find file in root directory by 11-character 8.3 format name
DirectoryEntry *findFile(const char *name) {
    for (uint32_t i = 0; i < g_BootSector.dir_entry_count; i++) {
        if (memcmp(name, g_RootDirectory[i].Name, 11) == 0) {
            return &g_RootDirectory[i];
        }
    }
    return NULL;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        printf("Syntax: %s <disk image> <file name>\n", argv[0]);
        return -1;
    }

    FILE *disk = fopen(argv[1], "rb");
    if (!disk) {
        fprintf(stderr, "Error: Could not open disk image %s\n", argv[1]);
        return -1;
    }

    if (!readBootSector(disk)) {
        fprintf(stderr, "Error: Could not read boot sector from disk image!\n");
        fclose(disk);
        return -2;
    }

    if (!readFat(disk)) {
        fprintf(stderr, "Error: Could not read FAT!\n");
        fclose(disk);
        free(g_Fat);
        return -3;
    }

    if (!readRootDirectory(disk)) {
        fprintf(stderr, "Error: Could not read root directory!\n");
        fclose(disk);
        free(g_Fat);
        free(g_RootDirectory);
        return -4;
    }

    DirectoryEntry *fileEntry = findFile(argv[2]);
    if (!fileEntry) {
        fprintf(stderr, "Could not find file %s!\n", argv[2]);
        fclose(disk);
        free(g_Fat);
        free(g_RootDirectory);
        return -5;
    }

    printf("Found file: %.11s, Size: %u bytes\n", fileEntry->Name, fileEntry->Size);

    fclose(disk);
    free(g_Fat);
    free(g_RootDirectory);
    return 0;
}
