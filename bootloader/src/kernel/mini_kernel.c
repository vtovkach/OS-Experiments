#include <stdint.h>

#define VGA_MEMORY 0xB8000
#define VGA_WIDTH  80
#define VGA_HEIGHT 25

static uint16_t* const vga = (uint16_t*) VGA_MEMORY;

static void clear_screen(void)
{
    int screen_resolution = VGA_HEIGHT * VGA_WIDTH;

    uint16_t blank = (0x0F << 8) | ' ';

    for(int i = 0; i < screen_resolution; i++)
    {
        vga[i] = blank;
    }
}

static void print(const char* str, uint8_t row, uint8_t col)
{
    uint16_t pos = row * VGA_WIDTH + col;

    while (*str)
    {
        vga[pos++] = ((uint16_t)0x0F << 8) | *str++;  
        // 0x0F = white on black
    }
}

int kernel_main(void)
{
    clear_screen();
    print("Kernel launched successfully", 12, 25);
    
    while (1)
    {
        __asm__ volatile ("hlt");
    }

    return 0;
}