#include <stdio.h>
#include <stdint.h>

typedef uint8_t  bool;
#define true 1
#define false 0


typedef struct
{
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

BootSector g_BootSector;
bool readBootSector(FILE* disk, BootSector* boot)
{
    return fread(boot, sizeof(BootSector), 1, disk) > 0;
}
bool readSectors(FILE* disk, uint32_t sector, uint8_t* buffer, size_t count)
{
    if (fseek(disk, sector * g_BootSector.bytes_per_sector, SEEK_SET) != 0) {
        return false;
    }
    return fread(buffer, g_BootSector.bytes_per_sector, count, disk) == count;
}
int addFileToFAT32(const char* imagePath, const char* filePath)
{
    if (argc < 3) {
        printf("Usage: %s <fat32 image> <file to add>\n", argv[0]);
        return -1;
    }

    FILE* disk = fopen(argv[1], "rb");
    if (!disk) {
        printf("Error opening disk image: %s\n", argv[1]);
        return -1;
    }

    if (!readBootSector(disk, &g_BootSector)) {
        printf("Error reading boot sector\n");
        fclose(disk);
        return -2;
    }

    fclose(disk);
    return 0;
}

int main(int argc, char** argv)
{
    if (argc < 3){
        printf("Usage: %s <fat32 image> <file to add>\n", argv[0]);
        return -1;
    }

    FILE* disk = fopen(argv[1], "rb");

    return 0;
}
